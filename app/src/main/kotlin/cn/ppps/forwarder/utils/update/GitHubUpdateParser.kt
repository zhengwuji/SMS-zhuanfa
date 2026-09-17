package cn.ppps.forwarder.utils.update

import android.text.TextUtils
import com.xuexiang.xupdate.entity.UpdateEntity
import com.xuexiang.xupdate.proxy.impl.AbstractUpdateParser
import org.json.JSONArray
import org.json.JSONObject

/**
 * GitHub Releases 版本更新信息解析器
 *
 * 将 GitHub Releases API 的响应转换为 XUpdate 所需的 UpdateEntity。
 *
 * 支持两种响应：
 *  ① /releases/latest      → 单个 Release 对象（正式版）
 *  ② /releases?per_page=1  → Release 数组（预览版，含预发布）
 *
 * APK 选择策略（按架构优先级）：
 *   arm64-v8a > armeabi-v7a > universal
 *
 * @author SMS-zhuanfa
 */
@Suppress("unused")
class GitHubUpdateParser : AbstractUpdateParser() {

    companion object {
        /** APK 文件名中架构的优先级（越靠前越优先） */
        private val ABI_PRIORITY = listOf("arm64-v8a", "armeabi-v7a", "universal")

        /** 更新的强制程度 */
        private const val STATUS_NO_UPDATE = 0        // 无更新
        private const val STATUS_HAS_UPDATE = 1       // 有更新（可忽略）
        private const val STATUS_FORCE_UPDATE = 2     // 强制更新
        private const val STATUS_IGNORABLE = 3        // 可忽略的更新
    }

    @Throws(Exception::class)
    override fun parseJson(json: String): UpdateEntity? {
        if (TextUtils.isEmpty(json)) {
            return null
        }

        val release = parseReleaseObject(json) ?: return null

        // tag_name 形如 v3.5.1 → 3.5.1
        val tagName = release.optString("tag_name", "")
        val versionName = tagName.removePrefix("v").trim()
        if (versionName.isEmpty()) {
            return null
        }

        // 更新说明来自 Release body
        var modifyContent = release.optString("body", "").trim()
        if (modifyContent.isEmpty()) {
            modifyContent = "请前往 Release 页面查看更新详情"
        }

        // 挑选最合适的 APK 附件
        val asset = pickBestApk(release.optJSONArray("assets"))
        val downloadUrl = asset?.optString("browser_download_url", "")
            ?: release.optString("html_url", "")

        if (downloadUrl.isEmpty()) {
            return null
        }

        val entity = UpdateEntity()
        entity.setHasUpdate(true)
        entity.setUpdateContent(modifyContent)
        entity.setVersionCode(versionNameToCode(versionName))
        entity.setVersionName(versionName)
        entity.setDownloadUrl(downloadUrl)
        entity.setIsIgnorable(true)   // 允许用户忽略本次更新
        entity.setForce(false)        // 不强制更新

        // APK 大小与 MD5（GitHub 不提供 MD5，留空即可）
        asset?.let {
            val size = it.optLong("size", 0L)
            if (size > 0) {
                entity.setSize(size)
            }
        }

        return entity
    }

    /**
     * 解析 Release 对象，兼容数组与单对象两种响应格式
     */
    private fun parseReleaseObject(json: String): JSONObject? {
        val trimmed = json.trim()
        return try {
            when {
                trimmed.startsWith("[") -> {
                    val array = JSONArray(trimmed)
                    if (array.length() == 0) null else array.getJSONObject(0)
                }
                trimmed.startsWith("{") -> JSONObject(trimmed)
                else -> null
            }
        } catch (e: Exception) {
            null
        }
    }

    /**
     * 从附件列表中挑选最适合当前设备的 APK
     *
     * 先排除非 APK 附件（如 SHA256SUMS.txt），再按架构优先级选择。
     */
    private fun pickBestApk(assets: JSONArray?): JSONObject? {
        if (assets == null || assets.length() == 0) {
            return null
        }

        val apks = mutableListOf<JSONObject>()
        for (i in 0 until assets.length()) {
            val a = assets.optJSONObject(i) ?: continue
            val name = a.optString("name", "")
            if (name.endsWith(".apk", ignoreCase = true)) {
                apks.add(a)
            }
        }

        if (apks.isEmpty()) {
            return null
        }

        // 按架构优先级挑选
        for (abi in ABI_PRIORITY) {
            apks.firstOrNull { it.optString("name", "").contains(abi, ignoreCase = true) }
                ?.let { return it }
        }

        // 未匹配到已知架构，返回第一个
        return apks.first()
    }

    /**
     * 版本名转数字 versionCode
     *
     * "3.5.1" → 30501（major*10000 + minor*100 + patch）
     */
    private fun versionNameToCode(versionName: String): Int {
        return try {
            val parts = versionName.split(".").take(3)
            val major = parts.getOrNull(0)?.toIntOrNull() ?: 0
            val minor = parts.getOrNull(1)?.toIntOrNull() ?: 0
            val patch = parts.getOrNull(2)?.toIntOrNull() ?: 0
            major * 10000 + minor * 100 + patch
        } catch (e: Exception) {
            0
        }
    }
}
