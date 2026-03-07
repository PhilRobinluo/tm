<div align="center">

# tm

**Terminal Mentor — 不背命令也能用 tmux。用着用着，就把命令学会了。**

<p>
  <img src="https://img.shields.io/github/license/PhilRobinluo/terminal-mentor" />
  <img src="https://img.shields.io/badge/platform-macOS%20%7C%20Linux-blue" />
  <img src="https://img.shields.io/badge/shell-zsh-green" />
  <img src="https://img.shields.io/badge/dependencies-0-brightgreen" />
</p>

</div>

---

tm 不是 tmux 的替代品，而是 tmux 的**教练**。

它把常用操作包装成中文菜单，让你按数字就能操作。每次操作后，自动弹出对应的原始命令——用着用着，你就不需要它了。

```
用了 10 次 → 不知不觉记住了命令
用了 30 次 → 直接输命令，教练退休
```

## 为什么需要它

终端工具的学习曲线问题不在于工具本身，而在于**没有一个循序渐进的过渡**。

大多数教程的做法是：丢给你一张快捷键表，祝你好运。

tm 的做法不一样——每次你用菜单完成操作，它会顺手告诉你「原来直接输这个命令就行」：

```
  ┌─────────────────────────────────────────┐
  │ 📚 学一招：不用菜单的话，你可以直接输入：│
  │    tmux new-session -s work             │
  │ 💬 -s 就是 session（会话）的意思         │
  └─────────────────────────────────────────┘
```

这个「学一招」提示框，就是从菜单到原生命令的桥梁。

## 安装

```bash
git clone https://github.com/PhilRobinluo/terminal-mentor.git
cd terminal-mentor
bash install.sh
```

一条命令自动完成 4 件事：

- 检查 tmux，没装帮你装（支持 Mac / Linux）
- 安装 `tm` 命令到 PATH
- 配置 tmux（鼠标支持、历史记录、快捷键速查）
- 添加终端启动提示

> 已有配置会自动备份，重复运行不会搞乱。

## 使用

```bash
tm          # 打开交互式菜单
tm new      # 创建新的工作空间
tm a        # 快速进入已有空间
tm ls       # 查看所有工作空间
tm d        # 离开当前空间（后台保持运行）
tm keys     # 快捷键速查
tm help     # 查看所有命令
```

## 三个阶段

```
阶段一：菜单操作        →  tm 回车，按数字
阶段二：快捷命令        →  tm a / tm new / tm ls
阶段三：原生命令        →  tmux attach / tmux new -s work
         ↑
       教练退休，你已经学会了
```

| 阶段 | 你会怎么用 |
|------|-----------|
| 刚开始 | `tm` 打开菜单，按数字操作 |
| 用了一周 | `tm a`、`tm new`、`tm ls` 快捷命令 |
| 用了一个月 | 直接 `tmux attach`、`tmux new -s work`，教练退休 |

## 终端启动提示

安装后每次打开终端，会看到当前 tmux 状态：

```
  🖥️  tmux: 2 个工作空间在运行  (main, code)
  ──────────────────────────────────────────
  tm a  进入空间     tm new  创建新空间
  tm ls 查看全部     tm      打开管理菜单
```

不阻塞、不强制，只是告诉你当前状态。

## 快捷键速查

在 tmux 里按 `Ctrl+B → h` 弹出速查浮窗（安装时自动配置）。

或者在终端输入 `tm keys` 查看分区速查卡。

## 名字的故事

`tm` 最初是 **t**mux **m**anager — 一个 tmux 会话管理器。

用着用着发现，管理只是表面，**教会用户**才是真正的价值。于是 `tm` 变成了 **T**erminal **M**entor — 一个会在合适的时候退出的终端教练。

名字没变，含义进化了。

## Terminal Mentor 系列

tm 是这个系列的第一个。同样的思路——**菜单引导 → 快捷命令 → 原生命令 → 教练退休**——会应用到更多工具：

- **gm** (git mentor) — 提交、分支、撤销
- **dm** (docker mentor) — 容器、镜像、日志
- **sm** (ssh mentor) — 连接、密钥、端口转发
- **bm** (brew mentor) — 安装、更新、清理

## License

MIT
