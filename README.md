# SMS-zhuanfa · 短信转发器

> 监控 Android 手机短信、来电、APP 通知，按规则自动转发到其他设备。
> 备用机必备神器，也让你的旧手机重新焕发价值。

[![Build Release APK](https://github.com/zhengwuji/SMS-zhuanfa/actions/workflows/release.yml/badge.svg)](https://github.com/zhengwuji/SMS-zhuanfa/actions/workflows/release.yml)
[![GitHub release](https://img.shields.io/github/v/release/zhengwuji/SMS-zhuanfa)](https://github.com/zhengwuji/SMS-zhuanfa/releases)
[![GitHub license](https://img.shields.io/github/license/zhengwuji/SMS-zhuanfa)](https://github.com/zhengwuji/SMS-zhuanfa/blob/main/LICENSE)

---

## 目录

- [它能做什么](#它能做什么)
- [功能特性](#功能特性)
- [支持的转发渠道](#支持的转发渠道)
- [快速开始](#快速开始)
- [使用教程](#使用教程)
- [从源码编译](#从源码编译)
- [自动构建与发布](#自动构建与发布)
- [常见问题](#常见问题)
- [免责声明](#免责声明)

---

## 它能做什么

把闲置的 Android 手机变成一台「信息中转站」：

```
┌──────────────┐        ┌─────────────────────┐        ┌──────────────┐
│  备用机       │        │   SMS-zhuanfa       │        │  主力机 /     │
│  (插 SIM 卡)  │        │                     │        │  服务器       │
├──────────────┤        ├─────────────────────┤        ├──────────────┤
│ 📨 收到短信   │──────▶│  ① 监听短信/来电     │──────▶│ 钉钉机器人    │
│ 📞 来电       │        │  ② 按规则匹配        │        │ 企业微信      │
│ 🔔 APP 通知   │        │  ③ 转发到渠道        │        │ Telegram     │
└──────────────┘        └─────────────────────┘        │ 邮箱 / Webhook│
                                                       └──────────────┘
```

**典型场景**：

| 场景 | 说明 |
|---|---|
| 双卡分流 | 工作号插备用机，重要短信转发到主力机 |
| 验证码中转 | 备用机收验证码，实时推送到电脑/平板 |
| 服务器告警 | 短信告警转发到钉钉群、企业微信 |
| 家庭通知 | 老人手机来电/短信转发给子女 |
| 旧机复活 | 淘汰的 Android 机当专职转发网关 |

---

## 功能特性

### 📨 消息监听

- **短信**：按发送者、内容关键词、SIM 卡槽过滤
- **来电**：来电通知、未接来电提醒
- **APP 通知**：抓取任意 APP 的通知栏消息
- **电量变化**：低电量、充电状态提醒

### 🔍 规则引擎

- 多条件组合：发送者 / 内容正则 / SIM 卡 / 时间范围
- 正则表达式匹配，支持复杂提取与替换
- 多条规则并行，一条消息可转发到多个渠道
- 规则启用/禁用开关，随时调整

### 📡 主动控制（V3.0+）

内置 HTTP Server，无需第三方服务即可远程操作备用机：

- **远程发短信**：通过 API 用备用机的卡发短信
- **查询短信**：拉取备用机短信记录
- **查询通话**：拉取通话记录
- **查询通讯录**：拉取联系人
- **查询电量**：获取设备电量状态
- **位置查询**：获取设备定位

### ⚙️ 自动任务 · 快捷指令（V3.3+）

- 定时任务：按 Cron 表达式周期执行
- 事件触发：收到短信 / 来电 / 通知时自动触发动作
- 快捷指令：一键执行预设动作序列
- 条件判断：满足特定条件才执行

### 🛡️ 稳定运行

- 多种保活措施，防止被系统杀后台
- 开机自启
- 断网重试、失败重发队列
- 转发日志完整记录，可追溯每次转发结果

---

## 支持的转发渠道

| 渠道 | 类型 | 说明 |
|---|---|---|
| **钉钉** | 群机器人 | 自定义机器人 Webhook |
| **钉钉** | 企业内机器人 | 企业内部应用机器人 |
| **企业微信** | 群机器人 | 群聊 Webhook |
| **企业微信** | 应用消息 | 企业应用推送 |
| **飞书** | 群机器人 | 自定义机器人 |
| **飞书** | 企业应用 | 企业自建应用 |
| **Telegram** | Bot | Telegram 机器人推送 |
| **邮箱** | SMTP | 任意 SMTP 邮箱 |
| **Bark** | iOS 推送 | Bark 服务推送 |
| **Server 酱** | 微信推送 | ServerChan 推送 |
| **PushPlus** | 微信推送 | PushPlus 推送 |
| **Webhook** | 通用 | 自定义 HTTP 请求 |
| **URL Scheme** | 通用 | 自定义 URL 跳转 |
| **短信** | 手机短信 | 转发到另一张 SIM 卡 |
| **Gotify** | 自建推送 | 自托管推送服务 |
| **Socket** | 套接字 | 自定义 TCP 通信 |

---

## 快速开始

### 第一步：下载安装

前往 [Releases](https://github.com/zhengwuji/SMS-zhuanfa/releases) 下载最新 APK。

**选择哪个包？**

| APK 文件 | 适用设备 | 建议 |
|---|---|---|
| `*_universal_release.apk` | 所有设备 | ✅ **不知道选哪个就选这个** |
| `*_arm64-v8a_release.apk` | 现代手机（2016 年后） | 体积小，推荐 |
| `*_armeabi-v7a_release.apk` | 老机型（32 位 ARM） | 5 年以上旧机 |
| `*_x86_release.apk` | x86 模拟器 | 仅模拟器 |
| `*_x86_64_release.apk` | x86_64 模拟器 | 仅模拟器 |

> 💡 不确定 CPU 架构？用 `universal` 包，它包含全部架构，兼容性最好。

### 第二步：授予权限

首次启动需授予以下权限，**缺一不可**：

| 权限 | 用途 | 必须 |
|---|---|---|
| 短信（读取/发送） | 监听与转发短信 | ✅ |
| 电话（读取状态/通话记录） | 来电监听、通话记录查询 | ✅ |
| 通讯录 | 联系人查询 | 按需 |
| 通知使用权 | 抓取 APP 通知 | ✅（要转发通知时） |
| 位置信息 | 位置查询 | 按需 |
| 后台运行 / 自启动 | 保活 | ✅ |
| 电池优化白名单 | 防止被系统杀后台 | ✅ |

### 第三步：关闭电池优化（**关键步骤**）

Android 系统会限制后台应用，**必须**关闭电池优化：

1. 进入 **设置 → 应用 → SMS-zhuanfa → 电池**
2. 选择 **无限制 / 不受限制**
3. 进入 **设置 → 电池 → 电池优化**
4. 找到 SMS-zhuanfa，设为 **不优化**

国产 ROM（小米/华为/OPPO/vivo）还需额外设置：

- **小米**：设置 → 应用管理 → SMS-zhuanfa → 自启动 → 开启；省电策略 → 无限制
- **华为**：设置 → 应用启动管理 → SMS-zhuanfa → 手动管理 → 全部开启
- **OPPO/vivo**：设置 → 电池 → 应用耗电管理 → 允许后台高耗电

---

## 使用教程

### 教程一：转发短信到钉钉群

**1. 创建钉钉机器人**

- 打开钉钉群 → 群设置 → 智能群助手 → 添加机器人 → 自定义
- 安全设置勾选 **加签**，复制 `Webhook` 地址和 `加签密钥`

**2. 在 APP 中配置**

```
发送通道 → 新增 → 选择「钉钉群机器人」
  ├─ 名称：钉钉通知
  ├─ Webhook：https://oapi.dingtalk.com/robot/send?access_token=XXXXXX
  └─ 加签密钥：SECxxxxxx
点击「测试」确认能收到消息
```

**3. 配置转发规则**

```
转发规则 → 新增
  ├─ 规则名称：所有短信转发
  ├─ 匹配条件：短信 → 全部
  ├─ 转发通道：勾选「钉钉通知」
  └─ 保存并启用
```

**4. 验证**

发送一条测试短信到备用机，钉钉群应立即收到转发消息。

---

### 教程二：验证码转发到主力机

**1. 配置转发通道**

```
发送通道 → 新增 → 选择「短信」
  ├─ 名称：主力机
  └─ 接收号码：13800138000
```

**2. 配置规则（只转发验证码）**

```
转发规则 → 新增
  ├─ 规则名称：验证码转发
  ├─ 匹配条件：短信 → 内容 → 正则匹配
  │   正则：验证码|校验码|动态码|\d{4,6}
  ├─ 转发通道：主力机
  └─ 保存并启用
```

> 💡 正则 `\d{4,6}` 匹配 4~6 位数字，覆盖绝大多数验证码格式。

---

### 教程三：远程用备用机发短信

**1. 开启 HTTP Server**

```
设置 → 主动控制 → 开启 HTTP Server
  ├─ 监听端口：8080（可自定义）
  └─ 记录下显示的访问地址与 Token
```

**2. 调用 API 发短信**

```bash
curl -X POST "http://备用机IP:8080/sms/send" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "YOUR_TOKEN",
    "phone": "13800138000",
    "msg": "Hello from SMS-zhuanfa"
  }'
```

**3. 查询短信记录**

```bash
curl "http://备用机IP:8080/sms/query?token=YOUR_TOKEN&limit=10"
```

> ⚠️ 确保备用机与调用方在同一局域网，或已做端口映射。公网暴露请务必设置强 Token。

---

### 教程四：自动任务定时汇报

**1. 创建自动任务**

```
自动任务 → 新增
  ├─ 任务名称：每日电量汇报
  ├─ 触发方式：定时 → Cron 表达式
  │   Cron：0 0 9 * * ?     （每天 9:00）
  ├─ 执行动作：发送短信 → 内容含 [电量]
  └─ 保存并启用
```

**2. 常用 Cron 示例**

| 表达式 | 含义 |
|---|---|
| `0 0 9 * * ?` | 每天 9:00 |
| `0 0 */2 * * ?` | 每 2 小时 |
| `0 30 8 ? * MON-FRI` | 工作日 8:30 |
| `0 0 0 1 * ?` | 每月 1 号 0:00 |

---

### 教程五：APP 通知转发

**1. 授予通知使用权**

```
设置 → 通知与状态栏 → 通知使用权 → 找到 SMS-zhuanfa → 开启
```

**2. 配置转发规则**

```
转发规则 → 新增
  ├─ 规则名称：微信消息转发
  ├─ 匹配条件：APP 通知 → 应用选择「微信」
  ├─ 转发通道：钉钉通知
  └─ 保存并启用
```

---

## 从源码编译

### 环境要求

| 组件 | 版本 | 说明 |
|---|---|---|
| JDK | **17** | AGP 7.2.2 要求 JDK 11+ |
| Android SDK | Platform 33 | compileSdk 33 |
| Build Tools | 33.0.1 | — |
| Gradle | 7.3.3 | 已含 Wrapper，无需手动安装 |

### 编译步骤

```bash
# 1. 克隆仓库
git clone https://github.com/zhengwuji/SMS-zhuanfa.git
cd SMS-zhuanfa

# 2. 配置 SDK 路径
echo "sdk.dir=/path/to/android-sdk" > local.properties

# 3. 生成签名（首次编译必需）
mkdir -p keystore
keytool -genkeypair -v -keystore keystore/pppscn.jks \
  -alias pppscn -keyalg RSA -keysize 2048 -validity 10950 \
  -storepass pppscn -keypass pppscn \
  -dname "CN=pppscn, OU=Dev, O=local, L=Beijing, ST=Beijing, C=CN"

# 4. 创建签名配置
cat > keystore/keystore.properties <<'EOF'
storeFile=../keystore/pppscn.jks
storePassword=pppscn
keyAlias=pppscn
keyPassword=pppscn
EOF

# 5. 编译
./gradlew assembleRelease
```

**产物位置**：

```
build/app/outputs/apk/release/
├── SmsF_3.5.0.XXXXXX_100055_universal_release.apk
├── SmsF_3.5.0.XXXXXX_200055_armeabi-v7a_release.apk
├── SmsF_3.5.0.XXXXXX_300055_arm64-v8a_release.apk
├── SmsF_3.5.0.XXXXXX_400055_x86_release.apk
└── SmsF_3.5.0.XXXXXX_500055_x86_64_release.apk
```

### 编译加速建议

```properties
# gradle.properties
org.gradle.parallel=true
org.gradle.caching=true
org.gradle.jvmargs=-Xmx6g -XX:MaxMetaspaceSize=1g -XX:+UseParallelGC
kotlin.daemon.keepAlive=10m
kotlin.incremental=true
```

> ⚠️ **注意**：本项目**无法**使用 GPU 编译。Kotlin/Java 编译、R8 混淆、aapt2 资源处理全是纯 CPU 任务，没有 GPU 后端。加速只能靠多核并行 + 增量编译。

编译完成后回收内存：

```bash
./gradlew --stop
```

---

## 自动构建与发布

本仓库配置了 GitHub Actions，**推送代码即自动出包并发布 Release**。

### 触发条件

| 动作 | 结果 |
|---|---|
| Push 到 `main` / `master` | 自动编译，发布 **Pre-release**（预发布） |
| 推送 Tag（如 `v3.5.0`） | 自动编译，发布 **正式 Release** |
| 手动触发（Actions 页面） | 自动编译，按输入决定发布类型 |

### Release 说明自动生成

每次发布，Release 正文会**自动写入**：

- 📝 本次更新内容（自动从 commit 记录汇总）
- 🔀 提交明细（`feat:` / `fix:` / `docs:` 等分类展示）
- 📊 代码变更统计（文件数、增删行数）
- 📦 APK 下载列表与 SHA256 校验值
- 🔗 完整变更对比链接（`Full Changelog`）

### 使用方式

**方式一：日常开发推送**

```bash
git add .
git commit -m "feat: 新增飞书机器人支持"
git push origin main
# → 自动编译并发布 Pre-release
```

**方式二：发布正式版**

```bash
git tag v3.5.1
git push origin v3.5.1
# → 自动编译并发布正式 Release
```

**方式三：手动触发**

进入仓库 **Actions → Build Release APK → Run workflow**，选择发布类型后执行。

### 工作流文件

配置位于 `.github/workflows/release.yml`，核心流程：

```
Checkout 代码
   ↓
配置 JDK 17 + Android SDK
   ↓
生成临时签名
   ↓
Gradle 编译 Release APK
   ↓
收集 APK + 计算 SHA256
   ↓
提取 commit 变更记录
   ↓
创建 Release 并上传 APK
```

---

## 常见问题

<details>
<summary><b>Q1：安装后收不到转发，怎么办？</b></summary>

按顺序排查：

1. **权限是否给全** —— 短信、电话、通知使用权必须授予
2. **电池优化是否关闭** —— 这是最常见原因，见[第三步](#第三步关闭电池优化关键步骤)
3. **自启动是否开启** —— 国产 ROM 必须手动开
4. **查看转发日志** —— APP 内「转发日志」页面会记录每次转发的结果和失败原因
5. **测试通道** —— 在通道配置页点「测试」，确认通道本身可用

</details>

<details>
<summary><b>Q2：编译报错 "Keystore file not found"</b></summary>

`keystore.properties` 中的 `storeFile` 路径是**相对 app 模块**解析的，必须写成 `../keystore/pppscn.jks`，不能写 `pppscn.jks`。

</details>

<details>
<summary><b>Q3：编译报错 "file not found" 一堆 PNG/XML 资源</b></summary>

这是 `img-optimizer` 插件把 vector xml 光栅化成 png 后，源 xml 未排除导致 aapt2 同名资源冲突。本项目已在 `app/build.gradle` 的 `sourceSets.main.res` 中配置好排除规则，若新增图标资源需同步添加排除项。

</details>

<details>
<summary><b>Q4：编译后内存占用很高不释放</b></summary>

Gradle 守护进程和 Kotlin 编译守护进程是**故意常驻**的（换取下次编译提速），Kotlin 守护进程默认存活 2 小时，Gradle 守护进程默认 3 小时。

需要立即释放：

```bash
./gradlew --stop
```

或改 `gradle.properties`：`kotlin.daemon.keepAlive=10m`

</details>

<details>
<summary><b>Q5：能不能用 GPU 加速编译？</b></summary>

**不能。** Android 编译全链路（kotlinc / javac / R8 / D8 / aapt2）均为纯 CPU 实现，无 GPU 后端。唯一的加速手段是 CPU 多核并行 + 增量编译 + 只编译目标 ABI。

</details>

<details>
<summary><b>Q6：支持哪些 Android 版本？</b></summary>

minSdk 19（Android 4.4）～ targetSdk 33（Android 13）。Android 4.4 的旧设备同样可用。

</details>

<details>
<summary><b>Q7：转发会不会泄露隐私？</b></summary>

所有转发**不经任何第三方服务器**，APP 直接向你自己配置的渠道（钉钉/邮箱/Telegram 等）发送数据。消息内容不经过本项目作者。

但请注意：转发渠道本身（如钉钉服务器）会经手消息内容，敏感场景建议自建 Gotify 或使用 Webhook 直连自己的服务器。

</details>

---

## 项目结构

```
SMS-zhuanfa/
├── app/
│   ├── src/main/
│   │   ├── kotlin/cn/ppps/forwarder/
│   │   │   ├── activity/      界面
│   │   │   ├── fragment/      功能页
│   │   │   ├── receiver/      短信/来电/通知监听
│   │   │   ├── service/       常驻服务
│   │   │   ├── server/        内置 HTTP Server
│   │   │   ├── workers/       自动任务
│   │   │   ├── database/      Room 数据层
│   │   │   ├── core/http/     网络层与各转发渠道
│   │   │   └── utils/         工具类
│   │   ├── res/               资源文件
│   │   └── AndroidManifest.xml
│   ├── libs/                  frpclib（内网穿透）
│   └── build.gradle
├── keystore/                  签名（需自行生成）
├── .github/workflows/
│   └── release.yml            自动构建发布
├── build.gradle
├── versions.gradle            依赖版本管理
└── gradle.properties
```

---

## 致谢

本项目基于 [pppscn/SmsForwarder](https://github.com/pppscn/SmsForwarder) 开源项目构建。

### 依赖的开源项目

- [XUI](https://github.com/xuexiangjys/XUI) — UI 框架
- [XUpdate](https://github.com/xuexiangjys/XUpdate) — 在线升级
- [XXPermissions](https://github.com/getActivity/XXPermissions) — 权限请求
- [AndServer](https://github.com/yanzhenjie/AndServer) — HTTP Server
- [frpc_android](https://github.com/mainfunx/frpc_android) — 内网穿透
- [Cactus](https://github.com/gyf-dev/Cactus) — 保活措施
- [kmnkt](https://gitee.com/xuankaicat/kmnkt) — socket 通信

---

## 免责声明

- 本项目代码与 APK 仅用于**学习研究**，请勿用于商业用途或任何违法活动。
- 使用者应自行确保使用行为符合所在国家或地区法律法规。
- 转发他人短信/通话内容可能涉及隐私与法律问题，请确保已获得相关方授权。
- 作者不对使用本项目产生的任何后果负责（包括但不限于隐私泄露、数据丢失）。
- 若任何单位或个人认为本项目侵犯其权利，请及时通知，我们将配合处理。

---

## License

[BSD-2-Clause](LICENSE)

---

<p align="center">
  <b>如果这个项目对你有帮助，欢迎 Star ⭐</b>
</p>
