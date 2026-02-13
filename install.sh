#!/bin/bash
# ================================================================
# tm 一键安装脚本
# ================================================================
# 使用方法：
#   curl -sL https://你的链接/install.sh | bash
#   或者下载后运行：bash install.sh
# ================================================================

set -e

# 颜色
G='\033[0;32m'
Y='\033[1;33m'
C='\033[0;36m'
R='\033[0;31m'
GR='\033[0;90m'
BD='\033[1m'
NC='\033[0m'

echo ""
echo "  ${BD}${G}🎮 tm - tmux 交互式教学管理工具${NC}"
echo "  ${GR}────────────────────────────────────────${NC}"
echo ""

# ── 第 1 步：检查 tmux ──
echo "  ${BD}[1/4]${NC} 检查 tmux..."

if command -v tmux &> /dev/null; then
    TMUX_VER=$(tmux -V | cut -d' ' -f2)
    echo "  ${G}✅ tmux $TMUX_VER 已安装${NC}"
else
    echo "  ${Y}⚠️  tmux 未安装${NC}"

    if command -v brew &> /dev/null; then
        echo "  ${C}→ 正在通过 Homebrew 安装 tmux...${NC}"
        brew install tmux
        echo "  ${G}✅ tmux 安装完成${NC}"
    elif command -v apt-get &> /dev/null; then
        echo "  ${C}→ 正在通过 apt 安装 tmux...${NC}"
        sudo apt-get update && sudo apt-get install -y tmux
        echo "  ${G}✅ tmux 安装完成${NC}"
    else
        echo "  ${R}❌ 无法自动安装 tmux${NC}"
        echo "  ${GR}请手动安装后重新运行此脚本：${NC}"
        echo "  ${C}  Mac:   brew install tmux${NC}"
        echo "  ${C}  Linux: sudo apt install tmux${NC}"
        exit 1
    fi
fi

# ── 第 2 步：安装 tm 命令 ──
echo ""
echo "  ${BD}[2/4]${NC} 安装 tm 命令..."

INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

if [[ -f "$SCRIPT_DIR/tm" ]]; then
    cp "$SCRIPT_DIR/tm" "$INSTALL_DIR/tm"
else
    # 如果是通过 curl 管道运行的，从网络下载
    echo "  ${C}→ 下载 tm 脚本...${NC}"
    curl -sL "https://raw.githubusercontent.com/你的用户名/tm/main/tm" -o "$INSTALL_DIR/tm"
fi

chmod +x "$INSTALL_DIR/tm"
echo "  ${G}✅ tm 已安装到 $INSTALL_DIR/tm${NC}"

# 检查 PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo ""
    echo "  ${Y}⚠️  $INSTALL_DIR 不在你的 PATH 里${NC}"
    echo "  ${GR}→ 正在自动添加...${NC}"

    SHELL_RC=""
    if [[ -f "$HOME/.zshrc" ]]; then
        SHELL_RC="$HOME/.zshrc"
    elif [[ -f "$HOME/.bashrc" ]]; then
        SHELL_RC="$HOME/.bashrc"
    fi

    if [[ -n "$SHELL_RC" ]]; then
        if ! grep -q "$INSTALL_DIR" "$SHELL_RC" 2>/dev/null; then
            echo "" >> "$SHELL_RC"
            echo "# tm - tmux 管理工具" >> "$SHELL_RC"
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
            echo "  ${G}✅ 已添加到 $SHELL_RC${NC}"
        fi
    fi
fi

# ── 第 3 步：配置 tmux ──
echo ""
echo "  ${BD}[3/4]${NC} 配置 tmux..."

TMUX_CONF="$HOME/.tmux.conf"
TM_MARKER="# [tm-managed] 以下配置由 tm 自动添加"

if [[ -f "$TMUX_CONF" ]] && grep -q "$TM_MARKER" "$TMUX_CONF" 2>/dev/null; then
    echo "  ${GR}⏭️  tmux 已配置过，跳过${NC}"
else
    # 备份现有配置
    if [[ -f "$TMUX_CONF" ]]; then
        cp "$TMUX_CONF" "$TMUX_CONF.backup.$(date +%Y%m%d)"
        echo "  ${GR}📋 已备份原配置到 .tmux.conf.backup.$(date +%Y%m%d)${NC}"
    fi

    cat >> "$TMUX_CONF" << 'TMUX_EOF'

# [tm-managed] 以下配置由 tm 自动添加
# 如需修改请编辑，删除此标记行可让 tm 重新配置

# 鼠标支持（滚动翻页、点击切换窗口）
set -g mouse on

# 加大历史记录
set -g history-limit 50000

# 256 色支持
set -g default-terminal "screen-256color"
set -ga terminal-overrides ",xterm-256color:Tc"

# UTF-8
set -q -g status-utf8 on
set -q -g utf8 on

# 快捷键速查浮窗（Ctrl+B → h）
bind h display-popup -w 56 -h 22 -E '\
echo ""; \
echo "  ⌨️  tmux 快捷键速查（按任意键关闭）"; \
echo "  ────────────────────────────────────────"; \
echo ""; \
echo "  📌 会话"; \
echo "  d 离开(后台保持)  s 会话列表  $ 重命名"; \
echo ""; \
echo "  🪟 窗口（像浏览器标签页）"; \
echo "  c 新建  n 下一个  p 上一个  0-9 跳转"; \
echo "  , 重命名  & 关闭  w 窗口列表"; \
echo ""; \
echo "  🔲 分屏"; \
echo "  % 左右分  \" 上下分  方向键 切换"; \
echo "  x 关闭分屏  z 全屏/还原"; \
echo ""; \
echo "  📜 翻页"; \
echo "  [ 进入滚动  q 退出  g 顶部  G 底部"; \
echo ""; \
echo "  ────────────────────────────────────────"; \
echo "  所有快捷键：Ctrl+B → 松开 → 按字母"; \
echo ""; \
read -n1 -s -r'
TMUX_EOF

    echo "  ${G}✅ tmux 基础配置完成（鼠标、历史、快捷键速查）${NC}"
fi

# ── 第 4 步：添加启动提示 ──
echo ""
echo "  ${BD}[4/4]${NC} 配置终端启动提示..."

SHELL_RC=""
if [[ -f "$HOME/.zshrc" ]]; then
    SHELL_RC="$HOME/.zshrc"
elif [[ -f "$HOME/.bashrc" ]]; then
    SHELL_RC="$HOME/.bashrc"
fi

if [[ -n "$SHELL_RC" ]]; then
    if grep -q "tm startup" "$SHELL_RC" 2>/dev/null; then
        echo "  ${GR}⏭️  启动提示已配置，跳过${NC}"
    else
        cat >> "$SHELL_RC" << 'ZSHRC_EOF'

# [tm] 每次开终端显示 tmux 状态提示（不强制进入）
if command -v tmux &> /dev/null && [[ -z "$TMUX" ]]; then
    tm startup
fi
ZSHRC_EOF
        echo "  ${G}✅ 启动提示已添加（开终端会看到 tmux 状态）${NC}"
    fi
else
    echo "  ${Y}⚠️  未找到 .zshrc 或 .bashrc，跳过${NC}"
fi

# ── 完成 ──
echo ""
echo "  ${GR}────────────────────────────────────────${NC}"
echo ""
echo "  ${BD}${G}🎉 安装完成！${NC}"
echo ""
echo "  ${BD}现在你可以：${NC}"
echo "  ${C}tm${NC}        打开交互式管理菜单"
echo "  ${C}tm a${NC}      秒回 tmux 工作空间"
echo "  ${C}tm new${NC}    创建新的工作空间"
echo "  ${C}tm keys${NC}   学习快捷键"
echo "  ${C}tm help${NC}   查看所有命令"
echo ""
echo "  ${GR}💡 如果 tm 命令找不到，先运行：source ~/.zshrc${NC}"
echo ""
