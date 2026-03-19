<div align="center">

# `tm` — 两个字母，搞定终端

**记不住命令？不用记。按数字就行。**

<p>
  <img src="https://img.shields.io/github/license/PhilRobinluo/terminal-mentor" />
  <img src="https://img.shields.io/badge/platform-macOS%20%7C%20Linux-blue" />
  <img src="https://img.shields.io/badge/shell-zsh-green" />
  <img src="https://img.shields.io/badge/dependencies-0-brightgreen" />
</p>

</div>

---

你知道 `lsof -i :3000` 是干什么的吗？

不知道也没关系。输入 `tm port 3000`，它帮你查，还顺手教你：

```
  ┌─────────────────────────────────────────┐
  │ 📚 学一招：不用菜单的话，你可以直接输入：│
  │    lsof -i :3000                        │
  │ 💬 lsof = list open files，-i 表示网络   │
  └─────────────────────────────────────────┘
```

用一个月后，你会直接敲 `lsof`，然后把 `tm` 卸了。

**这就是设计目的 — 一个注定被卸载的工具。**

## 10 秒安装

```bash
git clone https://github.com/PhilRobinluo/terminal-mentor.git && cd terminal-mentor && bash install.sh
```

自动搞定一切：检测/安装 tmux → 部署 `tm` 命令 → 配置终端。已有配置自动备份，不怕搞乱。

## 它能干什么

### 终端小白？打开菜单，按数字

```bash
tm           # 弹出菜单，全是选择题，不用记任何命令
```

```
  📊 当前状态
  ──────────────────────────────────────
  [0] 🚀 项目导航        [5] ➕ 新窗口
  [1] 🆕 创建工作空间     [6] 🗑️  关掉空间
  [2] 🔗 进入工作空间     [7] 📖 快捷键学习
  [3] 👀 查看所有空间     [8] 🧰 工具箱
  [4] 🚪 暂时离开
```

### 用熟了？直接敲命令，跳过菜单

```bash
# 端口 & 进程
tm port 3000         # 谁占了 3000 端口？
tm kill-port 3000    # 一键释放
tm ps node           # 找到所有 node 进程

# 搜索
tm find "*.log"      # 按文件名搜
tm grep "TODO"       # 在代码里搜内容

# 网络 & 系统
tm ip                # 内网/公网 IP 一览
tm sys               # CPU / 内存 / 磁盘 / 运行时间

# tmux 会话
tm new project       # 创建工作空间
tm a                 # 秒回最近的会话
tm ls                # 列出所有后台会话
tm d                 # 离开（任务继续跑）
```

### Git？整个操作中心都给你包了

```bash
tm git               # 完整 Git 菜单（9 大分类）
tm gs                # 状态速看
tm ga                # add + commit 一步到位
tm gp                # 智能 push（新分支自动 -u）
tm gco main          # 秒切分支
tm gcb feature/login # 创建 + 切换新分支
tm gm main           # 合并分支
tm gl                # 全分支树形日志
tm gst "存个档"      # stash
tm gstp              # 取回来
tm gc https://...    # clone
```

每一步都会告诉你对应的原生 Git 命令。用着用着，你就不需要菜单了。

### 快捷键？它教你背

```bash
tm keys              # 进入 tmux 快捷键学习模式
```

不是死记硬背，是**联想记忆法**：

```
  d = Detach（脱离）     →  人走了，茶不凉
  c = Create（创建）     →  新建一个窗口
  z = Zoom（放大）       →  放大镜看当前面板
  x = X 掉（关闭）       →  叉掉当前面板
```

## 设计哲学

```
第 1 天：tm 回车，按数字        ← 什么都不用记
第 7 天：tm port / tm gs       ← 开始用快捷命令
第 30 天：lsof / git status     ← 直接敲原生命令
         ↑
       教练退休了。但你已经会了。
```

`tm` 不是要替代任何工具。它是你的**终端教练** — 每次帮你干活的同时，偷偷教你一招。

当你不再需要它的那天，就是它最成功的那天。

## 完整命令速查

<details>
<summary><b>点击展开 30+ 命令一览</b></summary>

| 命令 | 作用 |
|------|------|
| **tmux 管理** | |
| `tm` | 打开完整交互菜单 |
| `tm new [名字]` | 创建新工作空间 |
| `tm a` | 进入最近的工作空间 |
| `tm ls` | 列出所有工作空间 |
| `tm d` | 离开当前空间（后台继续） |
| `tm keys` | 快捷键学习模式 |
| **工具箱** | |
| `tm tools` | 打开工具箱菜单 |
| `tm port [端口]` | 查看端口占用 |
| `tm kill-port [端口]` | 释放端口 |
| `tm ps [关键词]` | 查找进程 |
| `tm find [模式]` | 按文件名搜索 |
| `tm grep [关键词]` | 在代码中搜内容 |
| `tm ip` | 查看内网/公网 IP |
| `tm sys` | 系统状态（CPU/内存/磁盘） |
| `tm j [关键词]` | 项目快速跳转（zoxide） |
| `tm cron` | 管理定时任务 |
| **Git 操作** | |
| `tm git` | Git 完整菜单 |
| `tm gs` | git status |
| `tm ga` | git add + commit |
| `tm gd` | git diff --stat |
| `tm gb` | 列出所有分支 |
| `tm gp` | git push（智能） |
| `tm gpl` | git pull |
| `tm gco [分支]` | 切换分支 |
| `tm gcb [分支]` | 创建+切换分支 |
| `tm gm [分支]` | 合并分支 |
| `tm gc [地址]` | git clone |
| `tm gl` | 树形提交日志 |
| `tm gst [备注]` | git stash |
| `tm gstp` | git stash pop |

</details>

## 谁适合用

- **终端新手** → 全中文菜单，不用记命令，按数字就行
- **日常开发者** → 端口/进程/搜索/Git，高频操作一键搞定
- **Git 苦手** → 9 个分类菜单覆盖 99% 的 Git 操作
- **想学命令行的人** → 每次操作都教你原始命令，用着用着就学会了

## 不适合谁

- 终端老手，闭眼能敲 `awk '{print $2}'` 的人 — 你不需要教练
- 用 Fish / Bash 的人 — 目前只支持 zsh

## License

MIT — 随便用，随便改。

---

<div align="center">
  <sub>一个注定被卸载的工具，但在那之前，它会陪你走过最难的部分。</sub>
</div>
