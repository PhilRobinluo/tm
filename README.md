<div align="center">

# `tm` — 终端导航菜单

**打开菜单，按数字操作。用着用着，命令就会了。**

<p>
  <img src="https://img.shields.io/github/v/tag/PhilRobinluo/terminal-mentor?label=version&color=blue" />
  <img src="https://img.shields.io/github/license/PhilRobinluo/terminal-mentor" />
  <img src="https://img.shields.io/badge/platform-macOS%20%7C%20Linux-blue" />
  <img src="https://img.shields.io/badge/shell-zsh-green" />
  <img src="https://img.shields.io/badge/dependencies-0-brightgreen" />
</p>

</div>

---

> tm 是你的命令行拐杖。它不要求你背任何命令 — 打开导航菜单，按 1234 就能操作。
>
> 但它的目的不是让你依赖它，而是你在操作的同时，顺便把专业命令学会了。
>
> 有一天你扔掉拐杖，直接敲命令 — 那就是它最成功的时候。

## 安装

**Homebrew（推荐）：**

```bash
brew install PhilRobinluo/tap/tm
```

**手动安装：**

```bash
git clone https://github.com/PhilRobinluo/terminal-mentor.git && cd terminal-mentor && bash install.sh
```

自动完成：检测/安装 tmux → 部署 `tm` 命令 → 配置终端。已有配置自动备份。

**更新到最新版：**

```bash
tm update
```

## 它是怎么工作的

输入 `tm`，弹出导航菜单：

```
  🖥️  欢迎使用 tmux 管理工具！
  ──────────────────────────────────────
  [0] 🚀 项目导航        [5] ➕ 新窗口
  [1] 🆕 创建工作空间     [6] 🗑️  关掉空间
  [2] 🔗 进入工作空间     [7] 📖 快捷键学习
  [3] 👀 查看所有空间     [8] 🧰 工具箱
  [4] 🚪 暂时离开

  按数字选择 →
```

按 `1`，创建一个工作空间。按 `8`，进入工具箱。**不用记任何命令，全程选择题。**

每次操作完，它会"顺手"告诉你原始命令：

```
  ┌─────────────────────────────────────────┐
  │ 📚 学一招：不用菜单的话，你可以直接输入：│
  │    tmux new-session -s work             │
  │ 💬 -s 就是 session（会话）的意思          │
  └─────────────────────────────────────────┘
```

你不需要记住它。但看 20 次之后，你自然就会了。

## 已集成的功能

### tmux 会话管理

| 按键 | 干什么 |
|------|--------|
| `[1]` 创建工作空间 | 新建一个 tmux 会话，关掉终端也不会丢 |
| `[2]` 进入工作空间 | 列出所有后台会话，选一个接入 |
| `[3]` 查看所有空间 | 一览所有在跑的会话和进程 |
| `[4]` 暂时离开 | 离开当前会话，任务继续在后台跑 |
| `[5]` 新窗口 | 在当前空间里多开一个窗口 |
| `[6]` 关掉空间 | 彻底关闭一个会话（有确认） |
| `[7]` 快捷键学习 | 交互式学 tmux 快捷键，带联想记忆法 |

### 工具箱（按 `[8]` 进入）

| 工具 | 能干什么 |
|------|---------|
| 🔌 端口管理 | 谁占了 3000 端口？一键释放 |
| ⚙️ 进程管理 | 找进程、杀进程、看谁最吃资源 |
| 🔍 快速搜索 | 按文件名搜、在代码里搜内容 |
| 🌐 网络诊断 | 查内网/公网 IP、ping、DNS |
| 🚀 项目导航 | 快速跳转到常用目录 |
| 📦 Git 操作中心 | 9 大分类，覆盖 99% 日常 Git 操作 |
| 🔐 文件权限 | 查权限、加执行权限、权限解读 |
| 📦 压缩/解压 | tar.gz / zip 自动识别 |
| 📊 系统状态 | CPU / 内存 / 磁盘 / IP / 运行时间 |

### Git 操作中心（9 大分类菜单）

也是导航菜单。不用背 git 命令，按数字一步步操作：

```
  [1] 📋 状态 & 改动      → status / diff / blame
  [2] ✏️  提交变更         → add / commit / amend
  [3] 🌿 分支管理         → 创建 / 切换 / 删除 / 合并
  [4] 🔗 远程操作         → pull / push / fetch / clone
  [5] 📦 暂存区           → stash push / pop / list
  [6] ⏪ 撤销 & 恢复      → reset / restore / revert
  [7] 🏷️  标签管理         → 创建 / 删除 / 推送
  [8] 📖 查看历史         → 树形日志
  [9] 🔧 初始化           → init / clone
```

每一步都会告诉你对应的 git 原始命令。

### 快捷键学习模式

不是死记硬背。是**联想记忆法**：

```
  d = Detach（脱离）     →  人走了，茶不凉
  c = Create（创建）     →  新建一个窗口
  z = Zoom（放大）       →  放大镜看当前面板
  x = X 掉（关闭）       →  叉掉当前面板
```

## 三个阶段

```
第 1 天：tm 回车，按数字        ← 导航菜单带你走
第 7 天：tm port / tm gs       ← 开始记住快捷命令
第 30 天：lsof / git status     ← 直接用原始命令
          ↑
        拐杖扔了。你已经会走了。
```

| 阶段 | 你怎么用 | tm 在干什么 |
|------|---------|------------|
| 刚开始 | 打开菜单，按数字 | 帮你操作 + 偷偷教你命令 |
| 一周后 | `tm port`、`tm gs` | 你开始跳过菜单了 |
| 一个月后 | `lsof`、`git status` | 拐杖退休 |

## 自定义

### 配置文件

复制示例配置，按需修改：

```bash
cp .tmrc.example ~/.tmrc
```

可配置项：
- `TM_SHOW_TEACH` — 是否显示"学一招"教学提示（学会后可关掉）
- `TM_SHOW_STARTUP` — 是否在终端启动时显示 tmux 状态
- `TM_SESSION_LIMIT` — 最大会话数限制

### 插件系统

把 `.sh` 文件扔到 `~/.tm/plugins/` 目录，自动加载：

```bash
mkdir -p ~/.tm/plugins
cp plugins/example.sh ~/.tm/plugins/
```

可以用插件扩展工具箱 — 比如加 Docker 管理、K8s 操作等。详见 `plugins/example.sh`。

## 老手模式

用熟了之后，可以跳过菜单直接用快捷命令：

<details>
<summary><b>30+ 快捷命令一览</b></summary>

```bash
# tmux
tm new work          # 创建工作空间
tm a                 # 秒回最近会话
tm ls                # 列出所有会话
tm d                 # 离开（后台继续）
tm keys              # 快捷键学习

# 工具箱
tm port 3000         # 查端口占用
tm kill-port 3000    # 释放端口
tm ps node           # 查找进程
tm find "*.log"      # 按文件名搜
tm grep "TODO"       # 在代码里搜
tm ip                # 内网/公网 IP
tm sys               # 系统状态
tm j work            # 项目跳转

# Git
tm git               # Git 完整菜单
tm gs                # git status
tm ga                # add + commit
tm gp                # 智能 push
tm gpl               # git pull
tm gco main          # 切换分支
tm gcb feat/login    # 创建+切换分支
tm gm main           # 合并分支
tm gl                # 树形日志
tm gst "备注"        # stash
tm gstp              # stash pop
tm gc https://...    # clone

# 管理
tm update            # 检查更新
tm --version         # 查看版本
```

</details>

## License

MIT

---

<div align="center">
  <sub>Terminal Mentor — 一根会教你走路的拐杖。</sub>
</div>
