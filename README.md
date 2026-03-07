<div align="center">

# tm

**Terminal Mentor — 终端操作教练。一个工具搞定所有命令行操作。**

<p>
  <img src="https://img.shields.io/github/license/PhilRobinluo/terminal-mentor" />
  <img src="https://img.shields.io/badge/platform-macOS%20%7C%20Linux-blue" />
  <img src="https://img.shields.io/badge/shell-zsh-green" />
  <img src="https://img.shields.io/badge/dependencies-0-brightgreen" />
</p>

</div>

---

tm 不是某个工具的替代品，而是你的**终端教练**。

不管是 tmux、端口管理、进程排查、文件搜索还是网络诊断——tm 把常用操作包装成中文菜单，按数字就能操作。每次操作后，自动弹出对应的原始命令：

```
  ┌─────────────────────────────────────────┐
  │ 📚 学一招：不用菜单的话，你可以直接输入：│
  │    lsof -i :3000                        │
  │ 💬 lsof = list open files，-i 表示网络   │
  └─────────────────────────────────────────┘
```

用着用着，你就不需要它了。**教练会退休，但你已经学会了。**

## 安装

```bash
git clone https://github.com/PhilRobinluo/terminal-mentor.git
cd terminal-mentor
bash install.sh
```

自动完成：检查/安装 tmux + 安装 `tm` 命令 + 配置 tmux + 终端启动提示。已有配置会自动备份。

## 能做什么

### tmux 会话管理

```bash
tm          # 打开交互式菜单
tm new      # 创建新的工作空间
tm a        # 快速进入已有空间
tm ls       # 查看所有工作空间
tm d        # 离开当前空间（后台保持运行）
tm keys     # 快捷键速查
```

### 终端工具箱

```bash
tm port 3000       # 查看端口 3000 被谁占用
tm kill-port 3000  # 一键释放端口
tm ps node         # 查找 node 相关进程
tm find "*.js"     # 按文件名搜索
tm grep TODO       # 在代码里搜索内容
tm ip              # 查看内网/公网 IP
tm sys             # 系统状态一览（CPU/内存/磁盘）
tm tools           # 打开工具箱菜单
```

所有操作都会告诉你**背后的原始命令**，下次你可以直接用。

## 三个阶段

```
阶段一：菜单操作   →  tm 回车，按数字
阶段二：快捷命令   →  tm port 3000 / tm ps node / tm a
阶段三：原生命令   →  lsof -i :3000 / ps aux | grep node / tmux attach
         ↑
       教练退休，你已经学会了
```

| 阶段 | 你会怎么用 |
|------|-----------|
| 刚开始 | `tm` 打开菜单，按数字操作，什么都不用记 |
| 用了一周 | `tm port`、`tm ps`、`tm a` 快捷命令 |
| 用了一个月 | 直接 `lsof`、`ps aux`、`tmux attach`，教练退休 |

## 终端启动提示

安装后每次打开终端，会看到当前 tmux 状态：

```
  🖥️  tmux: 2 个工作空间在运行  (main, code)
  ──────────────────────────────────────────
  tm a  进入空间     tm new  创建新空间
  tm ls 查看全部     tm      打开管理菜单
```

## 名字的故事

`tm` 最初是 **t**mux **m**anager — 一个 tmux 会话管理器。

用着用着发现，管理只是表面，**教会用户**才是真正的价值。于是 `tm` 变成了 **T**erminal **M**entor — 一个会在合适的时候退出的终端教练。

tmux 是起点，不是边界。只要跟终端打交道的事，tm 都能帮你一键搞定。

## License

MIT
