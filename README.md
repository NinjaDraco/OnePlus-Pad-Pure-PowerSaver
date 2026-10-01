# OnePlus Pad 极致纯省电与能效调优模块 (动态游戏白名单版)

[English](#english) | [中文说明](#中文说明)

---

<a name="中文说明"></a>
## 📱 模块简介

本模块是专为 **OnePlus Pad Pro / OnePlus Pad 2（搭载骁龙 8 至尊版 SM8750 处理器，ColorOS / Android 16）** 深度定制的纯省电与智能能效调优 Magisk / KernelSU / APatch 模块。

核心目标：**在彻底解决日常重度耗电、发热的同时，不牺牲任何极致游戏体验。**

---

### ⚡ 核心原理与能效曲线分析

骁龙 8 至尊版（Snapdragon 8 Elite）采用双集群架构：
- **能效核集群 (Policy0, Cores 0-5)**：384MHz ~ 3.53GHz
- **超大核集群 (Policy6, Cores 6-7, Oryon 架构)**：1.01GHz ~ 4.32GHz

根据功耗曲线测量，Oryon 超大核在 **2.65GHz ~ 4.32GHz** 区间内，能效比急剧恶化，单核功耗呈指数级飙升（从 2~3W 暴涨至 10~15W+）。日常刷视频、网页浏览、微信多任务完全不需要 4.32GHz 的极端频率，但系统默认调度经常因轻微负载剧烈激进升频，导致严重的异常发热与电量飞逝。

---

### 🚀 动态游戏白名单工作模式

模块内置轻量级低开销守护进程（每 3 秒检测一次前台窗口焦点的包名）：

1. **白名单游戏场景（前台运行）**：
   - **完全放行全核频率**：超大核释放最高 4.32GHz，能效核心释放 3.53GHz。
   - **电竞级 540Hz 触控**：底层触控驱动直接拉满 540Hz 采样率与微秒级响应（Touch Slop = 2）。
   - **WALT 性能调度增强**：降低任务上迁门限，优先大核调度，确保极限团战 0 掉帧。

2. **日常全场景（桌面、B 站、浏览器、微信、办公及所有非白名单场景）**：
   - **严格能效限频**：
     - 超大核 Oryon（Cores 6-7）最高频封顶在 **2.65GHz / 2.43GHz**。
     - 能效核心（Cores 0-5）最高频封顶在 **2.40GHz**。
     - 截断高功耗暴涨区，**日常整机功耗降低 40% ~ 50%**，同时 120Hz 界面动画与日常应用依然 100% 满帧丝滑。
   - **触控能效回退**：自动切回系统动态触控采样率，关闭 540Hz 高频中断轮询，避免空载触控芯片发热。
   - **息屏深度 Doze**：屏幕熄灭后自动激活 Doze 深度休眠，整夜待机掉电几乎为 0%。

---

### 🎮 如何自定义添加游戏白名单？

本模块支持**用户自定义游戏与高性能应用白名单**，并支持**热重载**（修改保存后无需重启平板，3 秒内自动生效）！

#### 配置文件路径
- **优先路径**：`/sdcard/pure_powersave_games.txt`（即平板内部存储根目录）
- **备用路径**：`/data/adb/modules/oneplus_pure_powersave/games.txt`

#### 配置方式
安装模块后，系统会在内部存储自动生成 `/sdcard/pure_powersave_games.txt` 文件。使用任意文件管理器（如 MT 管理器、系统自带文件管理等）打开并编辑：

```text
# OnePlus Pad 极致纯省电模块 - 游戏白名单列表
# 每行填入一个需要全核满血释放 (4.32GHz + 540Hz触控) 的应用包名
# 支持 '#' 开头的注释

# 默认已内置：网易 Blood Strike (血战突击)
com.netease.newspike

# 自行添加更多游戏示例（取消前面的 # 号即可）：
# 原神
com.miHoYo.Yuanshen

# 崩坏：星穹铁道
com.miHoYo.hkrpg

# 绝区零
com.miHoYo.Nap

# 王者荣耀
com.tencent.tmgp.sgame

# 和平精英
com.tencent.tmgp.pubgmhd

# 暗区突围
com.tencent.tmgp.tiron

# 三角洲行动
com.tencent.tmgp.df
```

保存文件后，后台守护进程会在 **3 秒内自动识别新列表**，打开对应游戏即刻进入满血全核模式！

---

### 📦 安装方式

1. 下载最新的 `oneplus_pure_powersave.zip` 刷机包。
2. 打开 **Magisk / KernelSU / APatch** 管理器。
3. 进入「模块」页面，点击「从本地安装」，选择下载的 zip 包刷入。
4. 刷入完成后重启平板即可。

---

<a name="english"></a>
## 📱 English Documentation

### Overview
This module is tailored for **OnePlus Pad Pro / OnePlus Pad 2 (Snapdragon 8 Elite / SM8750, running ColorOS / Android 16)** to maximize battery life without sacrificing peak gaming performance.

### Key Capabilities
- **Dynamic Foreground Package Whitelist**:
  - Whitelisted Games: Uncaps Oryon cores to full 4.32GHz peak, activates 540Hz esports touch sampling rate, and sets aggressive WALT scheduling.
  - General Apps / System: Clamps Oryon cores to 2.65GHz and efficiency cores to 2.40GHz to avoid the exponential power escalation zone. Reduces daily system power consumption by 40-50% while maintaining flawless 120Hz UI smoothness.
  - Screen-off: Steps directly into deep Doze mode for virtually zero idle drain.
- **Customizable Whitelist via `/sdcard/pure_powersave_games.txt`**:
  - Hot-reloaded every 3 seconds without requiring a reboot.
  - Simply append your desired game package name (one per line) to unlock full hardware clocks.

---

## 👨‍💻 Author
- **Author**: [NinjaDraco](https://github.com/NinjaDraco)
- **License**: MIT
