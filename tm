#!/bin/zsh
# ================================================================
# tm - Terminal Mentor 终端导航菜单 🎮
# ================================================================
# 专为零基础用户设计，全程选择题操作，不用记任何命令
# 安装：bash install.sh 或 brew install PhilRobinluo/tap/tm
# 使用：终端输入 tm 回车即可
# ================================================================

VERSION="1.0.0"

# ── 配置加载 ──
TM_CONFIG_DIR="$HOME/.config/tm"
TM_PLUGIN_DIR="$HOME/.tm/plugins"

load_config() {
    # 默认值
    TM_SHOW_TEACH=${TM_SHOW_TEACH:-true}
    TM_SHOW_STARTUP=${TM_SHOW_STARTUP:-true}
    TM_SESSION_LIMIT=${TM_SESSION_LIMIT:-8}
    # 加载用户配置
    if [[ -f "$HOME/.tmrc" ]]; then
        source "$HOME/.tmrc"
    fi
}

# ── 颜色 ──
G='\033[0;32m'    # 绿色-成功
Y='\033[1;33m'    # 黄色-提醒
B='\033[0;34m'    # 蓝色
C='\033[0;36m'    # 青色-命令
R='\033[0;31m'    # 红色-警告
GR='\033[0;90m'   # 灰色-注释
BD='\033[1m'      # 加粗
NC='\033[0m'      # 恢复

# ── 插件注册表 ──
# 插件可以注册：菜单项、快捷命令
# 用法（在插件 .sh 文件中）：
#   tm_register_toolbox_item "s" "🐱 我的SSH" "do_my_ssh"
#   tm_register_shortcut "myssh" "do_my_ssh"
typeset -a TM_PLUGIN_TOOLBOX_KEYS TM_PLUGIN_TOOLBOX_LABELS TM_PLUGIN_TOOLBOX_FUNCS
typeset -a TM_PLUGIN_SHORTCUT_NAMES TM_PLUGIN_SHORTCUT_FUNCS

tm_register_toolbox_item() {
    TM_PLUGIN_TOOLBOX_KEYS+=("$1")
    TM_PLUGIN_TOOLBOX_LABELS+=("$2")
    TM_PLUGIN_TOOLBOX_FUNCS+=("$3")
}

tm_register_shortcut() {
    TM_PLUGIN_SHORTCUT_NAMES+=("$1")
    TM_PLUGIN_SHORTCUT_FUNCS+=("$2")
}

# 加载插件（颜色和注册函数已就绪，插件可以安全使用）
load_plugins() {
    if [[ -d "$TM_PLUGIN_DIR" ]]; then
        for plugin in "$TM_PLUGIN_DIR"/*.sh(N); do
            source "$plugin"
        done
    fi
}

load_config
load_plugins

# ── 工具函数 ──

# 教学提示：每次操作都告诉你"如果不用菜单，原本该输什么"
teach() {
    [[ "$TM_SHOW_TEACH" != "true" ]] && return
    echo ""
    echo "${GR}  ┌─────────────────────────────────────────┐${NC}"
    echo "${GR}  │ 📚 学一招：不用菜单的话，你可以直接输入：${NC}"
    echo "${GR}  │    ${C}$1${NC}"
    if [[ -n "$2" ]]; then
        echo "${GR}  │ 💬 $2${NC}"
    fi
    echo "${GR}  └─────────────────────────────────────────┘${NC}"
    echo ""
}

# 暂停等待
pause() {
    echo ""
    echo "  ${GR}👆 按回车键继续...${NC}"
    read
}

# 分隔线
line() {
    echo "${GR}  ──────────────────────────────────────────${NC}"
}

# 是否在 tmux 里
in_tmux() { [[ -n "$TMUX" ]]; }

# 有几个会话
session_count() { tmux list-sessions 2>/dev/null | wc -l | tr -d ' '; }

# ── 欢迎页面 ──
welcome() {
    clear
    echo ""
    echo "  ${BD}${G}🖥️  欢迎使用 tmux 管理工具！${NC}"
    echo ""
    line
    echo ""
    echo "  ${BD}什么是 tmux？${NC}"
    echo "  简单说，它就是一个${G}「不怕断线的终端」${NC}。"
    echo ""
    echo "  🔹 你在里面跑的任务，${BD}关掉窗口也不会停${NC}"
    echo "  🔹 手机远程连过来，能${BD}接着上次的工作继续${NC}"
    echo "  🔹 可以同时开${BD}好几个工作空间${NC}，互不干扰"
    echo ""
    echo "  ${GR}把它想象成：你的电脑里有很多个「虚拟桌面」，"
    echo "  每个桌面都在独立运行，你可以随时切换。${NC}"
    echo ""
    line
    pause
}

# ── 状态面板 ──
show_status() {
    echo ""
    echo "  ${BD}📊 当前状态${NC}"
    line

    local count=$(session_count)

    if in_tmux; then
        local current=$(tmux display-message -p '#S')
        local win_count=$(tmux list-windows | wc -l | tr -d ' ')
        echo ""
        echo "  ${G}✅ 你正在 tmux 里面${NC}"
        echo "  ${G}📍 当前会话名：${BD}$current${NC}"
        echo "  ${G}🪟 这个会话里有 ${BD}$win_count${NC}${G} 个窗口${NC}"
    else
        echo ""
        echo "  ${Y}📭 你现在不在 tmux 里面${NC}"
    fi

    if [[ "$count" -gt 0 ]]; then
        echo "  ${B}💡 后台一共有 ${BD}$count${NC}${B} 个会话在运行${NC}"
    else
        echo "  ${GR}   目前没有任何会话${NC}"
    fi
    echo ""
}

# ── 主菜单 ──
main_menu() {
    clear
    echo ""
    echo "  ${BD}${G}🎮 Terminal Mentor${NC}"
    show_status
    line
    echo ""

    local count=$(session_count)

    echo "  你想做什么？"
    echo ""
    echo "  ${BD}[0]${NC} 🚀 项目导航"
    echo "       ${GR}（快速跳转常用目录，搭配 zoxide）${NC}"
    echo ""
    echo "  ${BD}[1]${NC} 🆕 创建一个新的工作空间"
    echo "       ${GR}（就像打开一个新的终端窗口，但更强大）${NC}"
    echo ""

    if [[ "$count" -gt 0 ]]; then
        echo "  ${BD}[2]${NC} 🔗 进入一个已有的工作空间"
        echo "       ${GR}（回到之前的工作，一切都还在）${NC}"
        echo ""
        echo "  ${BD}[3]${NC} 👀 看看都有哪些工作空间在运行"
        echo "       ${GR}（列个清单，心里有数）${NC}"
        echo ""
    fi

    if in_tmux; then
        echo "  ${BD}[4]${NC} 🚪 暂时离开（工作空间保持运行）"
        echo "       ${GR}（相当于「最小化」，任务不会停）${NC}"
        echo ""
        echo "  ${BD}[5]${NC} ➕ 在当前空间里多开一个窗口"
        echo "       ${GR}（就像浏览器开新标签页一样）${NC}"
        echo ""
    fi

    if [[ "$count" -gt 0 ]]; then
        echo "  ${BD}[6]${NC} 🗑️  关掉某个工作空间"
        echo "       ${GR}（彻底关闭，里面的任务也会停止）${NC}"
        echo ""
    fi

    echo "  ${BD}[7]${NC} 📖 学习 tmux 快捷键"
    echo "       ${GR}（掌握这些，以后不用菜单也行）${NC}"
    echo ""
    echo "  ${BD}[8]${NC} 🧰 工具箱（端口、进程、搜索、网络、系统...）"
    echo "       ${GR}（一站式终端工具，每个操作都教你原始命令）${NC}"
    echo ""
    echo "  ${BD}[q]${NC} 👋 退出菜单"
    echo ""
    line
}

# ── 项目选择器（创建工作空间时的硬工序）──
_pick_project_dir() {
    # 返回选中的目录路径，存入变量 PICKED_DIR
    PICKED_DIR=""
    echo ""
    echo "  ${BD}📂 选择工作目录${NC}"
    echo "  ${GR}（这个工作空间会从哪个目录开始？）${NC}"
    echo ""

    local i=1
    local -a dirs
    # 优先显示 ~/work/ 下的项目
    while IFS= read -r d; do
        dirs[$i]="$d"
        local display="${d/#$HOME/~}"
        local git_mark=""
        [[ -d "$d/.git" ]] && git_mark=" ${C}(git)${NC}"
        printf "  ${BD}[%s]${NC} %s%s\n" "$i" "$display" "$git_mark"
        ((i++))
        [[ $i -gt 9 ]] && break
    done < <(zoxide query -l 2>/dev/null | head -9)

    echo ""
    echo "  ${BD}[s]${NC} 🔍 搜索关键词"
    echo "  ${BD}[h]${NC} 🏠 就用主目录 (~)"
    echo "  ${BD}[0]${NC} 跳过（用默认目录）"
    echo ""
    echo -n "  选择: "
    read -k1 pick
    echo ""

    case $pick in
        [1-9])
            PICKED_DIR="${dirs[$pick]}"
            ;;
        s|S)
            echo ""
            echo -n "  ${BD}输入关键词${NC}: "
            read keyword
            if [[ -n "$keyword" ]]; then
                local best=$(zoxide query "$keyword" 2>/dev/null)
                [[ -n "$best" && -d "$best" ]] && PICKED_DIR="$best"
            fi
            ;;
        h|H)
            PICKED_DIR="$HOME"
            ;;
        *)
            PICKED_DIR=""
            ;;
    esac
}

# ── 功能1：新建会话 ──
do_new() {
    clear
    echo ""
    echo "  ${BD}🆕 创建新的工作空间${NC}"
    line
    echo ""
    echo "  给这个工作空间起个名字吧！"
    echo "  ${GR}（比如：work、code、test... 方便你以后认出它）${NC}"
    echo "  ${GR}（不想起名字？直接按回车，系统会自动编号）${NC}"
    echo ""
    echo -n "  名字: "
    read name

    # 校验会话名（只保留字母、数字、下划线、短横线）
    if [[ -n "$name" ]]; then
        local clean=$(echo "$name" | tr -cd 'a-zA-Z0-9_-')
        if [[ "$name" != "$clean" ]]; then
            echo "  ${Y}⚠️  名字有特殊字符，已过滤为: ${BD}$clean${NC}"
        fi
        name="$clean"
    fi

    # 检查名字是否已存在
    if [[ -n "$name" ]] && tmux has-session -t "$name" 2>/dev/null; then
        echo ""
        echo "  ${R}⚠️  名字 '$name' 已经被用了！${NC}"
        echo ""
        echo "  ${BD}[1]${NC} 直接进入这个已有的空间"
        echo "  ${BD}[2]${NC} 换个名字重新创建"
        echo "  ${BD}[0]${NC} 算了，回主菜单"
        echo ""
        echo -n "  选择: "
        read -k1 pick
        echo ""
        case $pick in
            1)
                if in_tmux; then
                    tmux switch-client -t "$name"
                else
                    tmux attach -t "$name"
                fi
                ;;
            2) do_new ;;
            *) return ;;
        esac
        return
    fi

    # ── 硬工序：选择项目目录 ──
    _pick_project_dir
    local start_dir="${PICKED_DIR:-$HOME}"
    if [[ -n "$PICKED_DIR" ]]; then
        echo "  ${G}📂 工作目录: ${PICKED_DIR/#$HOME/~}${NC}"
    fi

    echo ""
    if [[ -z "$name" ]]; then
        if in_tmux; then
            teach "tmux new-session -d -c \"$start_dir\"" "新建会话并设置工作目录"
            tmux new-session -d -c "$start_dir"
            local new_name=$(tmux list-sessions | tail -1 | cut -d: -f1)
            echo "  ${G}✅ 新工作空间已创建！名字是: ${BD}$new_name${NC}"
            echo ""
            echo "  ${BD}[y]${NC} 切换过去"
            echo "  ${BD}[n]${NC} 先不用"
            echo ""
            echo -n "  选择: "
            read -k1 go
            echo ""
            if [[ "$go" == "y" ]]; then
                tmux switch-client -t "$new_name"
                return
            fi
        else
            teach "tmux new-session -c \"$start_dir\"" "创建会话并设置工作目录"
            echo "  ${G}✅ 正在进入新的工作空间...${NC}"
            sleep 1
            tmux new-session -c "$start_dir"
        fi
    else
        if in_tmux; then
            teach "tmux new-session -d -s $name -c \"$start_dir\"" "-s 指定名字，-c 指定工作目录"
            tmux new-session -d -s "$name" -c "$start_dir"
            echo "  ${G}✅ 工作空间 ${BD}$name${G} 已创建！${NC}"
            echo ""
            echo "  ${BD}[y]${NC} 切换过去"
            echo "  ${BD}[n]${NC} 先不用"
            echo ""
            echo -n "  选择: "
            read -k1 go
            echo ""
            if [[ "$go" == "y" ]]; then
                tmux switch-client -t "$name"
                return
            fi
        else
            teach "tmux new-session -s $name -c \"$start_dir\"" "-s 指定名字，-c 指定工作目录"
            echo "  ${G}✅ 正在进入工作空间 ${BD}$name${G}...${NC}"
            sleep 1
            tmux new-session -s "$name" -c "$start_dir"
        fi
    fi
    pause
}

# ── 功能2：接入会话 ──
do_attach() {
    clear
    echo ""
    echo "  ${BD}🔗 进入已有的工作空间${NC}"
    line
    echo ""

    local sessions=$(tmux list-sessions 2>/dev/null)
    if [[ -z "$sessions" ]]; then
        echo "  ${Y}😅 还没有任何工作空间呢${NC}"
        echo "  ${GR}要不先创建一个？回主菜单按 1${NC}"
        pause
        return
    fi

    echo "  以下是正在运行的工作空间，选一个进去吧："
    echo ""

    # 构建排序数据，用 session name 排序（数字编号自然排在前面）
    # 格式：session_name（一行一个），按 session name 字母序排
    tmux list-sessions -F '#{session_name}' 2>/dev/null | sort -f > /tmp/tm_sorted_sessions.tmp

    local i=1
    while IFS= read -r name; do
        local pane_info=$(tmux list-windows -t "$name" -F '#{pane_current_command}|#{pane_title}' 2>/dev/null | head -1)
        local pane_cmd=$(echo "$pane_info" | cut -d'|' -f1)
        local pane_title=$(echo "$pane_info" | cut -d'|' -f2)
        local attached=""
        local is_attached=$(tmux display-message -t "$name" -p '#{session_attached}' 2>/dev/null)
        [[ "$is_attached" == "1" ]] && attached=" ${G}← 在用${NC}"
        local status_icon="" title_display=""
        if [[ "$pane_cmd" =~ ^[0-9]+\.[0-9]+ ]]; then
            status_icon="🤖"
            if [[ -n "$pane_title" ]]; then
                local clean_title=$(echo "$pane_title" | sed 's/^[✳⠂⠄⠇⠋⠙⠸⠴⠦⠖] //')
                # 只在标题和 session name 不同时才额外显示标题
                if [[ "$clean_title" != "$name" ]]; then
                    # 标题太长时截断显示
                    local short_title=$(echo "$clean_title" | cut -c1-50)
                    [[ ${#clean_title} -gt 50 ]] && short_title="${short_title}..."
                    title_display=" ${C}${short_title}${NC}"
                fi
            fi
        else
            status_icon="💤"
            title_display=" ${GR}(空闲 shell)${NC}"
        fi
        echo "  ${BD}[$i]${NC} ${status_icon} ${BD}$name${NC}${title_display}${attached}"
        i=$((i + 1))
    done < /tmp/tm_sorted_sessions.tmp

    echo ""
    echo "  ${BD}[0]${NC} 返回主菜单"
    echo ""
    echo -n "  选择编号: "
    read choice

    if [[ "$choice" == "0" ]] || [[ -z "$choice" ]]; then
        return
    fi

    local target=$(sed -n "${choice}p" /tmp/tm_sorted_sessions.tmp)
    if [[ -z "$target" ]]; then
        echo "  ${R}⚠️  没有这个编号哦，再试试？${NC}"
        pause
        return
    fi

    if in_tmux; then
        teach "tmux switch-client -t $target" "switch-client 是「切换到另一个会话」"
        tmux switch-client -t "$target"
    else
        teach "tmux attach -t $target" "attach 就是「接入、连上去」的意思"
        echo "  ${G}✅ 正在进入 ${BD}$target${G}...${NC}"
        sleep 1
        tmux attach -t "$target"
    fi
}

# ── 功能3：列出会话 ──
do_list() {
    clear
    echo ""
    echo "  ${BD}👀 所有工作空间一览${NC}"
    line

    teach "tmux ls" "ls 是 list-sessions 的缩写，就是「列出所有会话」"

    local sessions=$(tmux list-sessions 2>/dev/null)
    if [[ -z "$sessions" ]]; then
        echo "  ${GR}📭 空空如也，还没创建任何工作空间${NC}"
        echo ""
        echo "  ${GR}💡 小贴士：回主菜单按 1 就能创建一个${NC}"
    else
        echo ""
        local i=1
        echo "$sessions" | while IFS= read -r s; do
            local name=$(echo "$s" | cut -d: -f1)
            local detail=$(echo "$s" | cut -d: -f2-)
            local attached=""
            if echo "$s" | grep -q "(attached)"; then
                attached=" ${G}👈 你在这里${NC}"
            fi
            echo "  ${BD}$i.${NC} ${G}$name${NC} $detail$attached"
            i=$((i + 1))
        done
    fi
    echo ""
    pause
}

# ── 功能4：断开会话 ──
do_detach() {
    clear
    echo ""
    echo "  ${BD}🚪 暂时离开当前工作空间${NC}"
    line
    echo ""

    if ! in_tmux; then
        echo "  ${Y}你现在不在 tmux 里面，不需要离开哦${NC}"
        pause
        return
    fi

    local current=$(tmux display-message -p '#S')
    echo "  你当前在: ${BD}$current${NC}"
    echo ""
    echo "  离开后会怎样？"
    echo "  ${G}✅ 里面的任务会继续运行${NC}"
    echo "  ${G}✅ 随时可以回来接着用${NC}"
    echo "  ${G}✅ 手机远程连过来也能看到${NC}"
    echo ""
    echo "  确定要暂时离开吗？"
    echo ""
    echo "  ${BD}[y]${NC} 是的，先离开"
    echo "  ${BD}[n]${NC} 算了，我继续待着"
    echo ""
    echo -n "  选择: "
    read -k1 confirm
    echo ""

    if [[ "$confirm" == "y" ]]; then
        teach "Ctrl+B 然后按 d" "这是最常用的快捷键，记住它以后就不用进菜单了"
        echo "  ${G}✅ 正在离开...你的工作空间在后台安全运行着${NC}"
        sleep 1
        tmux detach
    fi
}

# ── 功能5：新建窗口 ──
do_new_window() {
    clear
    echo ""
    echo "  ${BD}➕ 在当前工作空间里开一个新窗口${NC}"
    line
    echo ""

    if ! in_tmux; then
        echo "  ${Y}需要先进入一个 tmux 工作空间才能开新窗口哦${NC}"
        echo "  ${GR}回主菜单按 1 创建，或按 2 进入一个已有的${NC}"
        pause
        return
    fi

    echo "  ${GR}这就像在浏览器里开一个新标签页一样${NC}"
    echo "  ${GR}你可以在不同窗口里做不同的事情${NC}"
    echo ""

    teach "Ctrl+B 然后按 c" "c 就是 create（创建）的意思"

    echo "  ${G}✅ 新窗口已打开！${NC}"
    echo ""
    echo "  ${GR}💡 以后切换窗口可以用：${NC}"
    echo "  ${C}Ctrl+B → n${NC}  下一个窗口（n = next）"
    echo "  ${C}Ctrl+B → p${NC}  上一个窗口（p = previous）"
    echo "  ${C}Ctrl+B → 0-9${NC} 直接跳到第几个窗口"

    sleep 1
    tmux new-window
}

# ── 功能6：关闭会话 ──
do_kill() {
    clear
    echo ""
    echo "  ${BD}🗑️  关闭工作空间${NC}"
    line
    echo ""

    local sessions=$(tmux list-sessions 2>/dev/null)
    if [[ -z "$sessions" ]]; then
        echo "  ${GR}没有需要关闭的工作空间${NC}"
        pause
        return
    fi

    echo "  ${R}⚠️  注意：关闭后，里面正在运行的任务也会停止！${NC}"
    echo ""
    echo "  选择要关闭哪一个："
    echo ""

    local i=1
    echo "$sessions" | while IFS= read -r s; do
        local name=$(echo "$s" | cut -d: -f1)
        local attached=""
        if echo "$s" | grep -q "(attached)"; then
            attached=" ${G}← 你正在这里面${NC}"
        fi
        echo "  ${BD}[$i]${NC} $name$attached"
        i=$((i + 1))
    done
    echo ""
    echo "  ${BD}[0]${NC} 还是算了，回主菜单"
    echo ""
    echo -n "  选择编号: "
    read choice

    if [[ "$choice" == "0" ]] || [[ -z "$choice" ]]; then
        return
    fi

    local target=$(tmux list-sessions | sed -n "${choice}p" | cut -d: -f1)
    if [[ -z "$target" ]]; then
        echo "  ${R}没有这个编号${NC}"
        pause
        return
    fi

    echo ""
    echo "  你选择了: ${BD}$target${NC}"
    echo ""
    echo "  ${Y}真的要关掉它吗？这个操作不能撤回${NC}"
    echo ""
    echo "  ${BD}[y]${NC} 确定关掉"
    echo "  ${BD}[n]${NC} 手滑了，不关了"
    echo ""
    echo -n "  选择: "
    read -k1 confirm
    echo ""

    if [[ "$confirm" == "y" ]]; then
        teach "tmux kill-session -t $target" "kill-session 就是「终止会话」"
        tmux kill-session -t "$target"
        echo "  ${G}✅ 工作空间 ${BD}$target${G} 已关闭${NC}"
    else
        echo "  ${G}👌 好的，保留不动${NC}"
    fi
    pause
}

# ── 功能7：快捷键学习 ──
do_learn() {
    clear
    echo ""
    echo "  ${BD}📖 tmux 快捷键学习${NC}"
    line
    echo ""
    echo "  ${BD}${Y}🔑 核心规则：所有快捷键都是两步操作${NC}"
    echo ""
    echo "  ${BD}第一步${NC}：按 ${C}Ctrl+B${NC}（同时按住 Ctrl 和 B）"
    echo "  ${BD}第二步${NC}：${BD}松开${NC}，再按下一个键"
    echo ""
    echo "  ${GR}就像打电话的「区号 + 号码」一样，"
    echo "  Ctrl+B 是区号，后面的字母是号码${NC}"
    echo ""
    line
    echo ""
    echo "  想学哪一类？"
    echo ""
    echo "  ${BD}[1]${NC} 🏠 会话管理（最基础，先学这个）"
    echo "  ${BD}[2]${NC} 🪟 窗口管理（开新窗口、切换窗口）"
    echo "  ${BD}[3]${NC} 📜 翻页滚动（看历史输出）"
    echo "  ${BD}[4]${NC} 🔲 分屏操作（一个屏幕干两件事）"
    echo "  ${BD}[0]${NC} 返回主菜单"
    echo ""
    echo -n "  选择: "
    read -k1 topic
    echo ""

    case $topic in
        1)
            clear
            echo ""
            echo "  ${BD}🏠 会话管理快捷键${NC}"
            line
            echo ""
            echo "  ${C}Ctrl+B → d${NC}     ${BD}离开（detach）${NC}"
            echo "  ${GR}                 会话在后台继续运行"
            echo "                 这是你最该记住的第一个快捷键！${NC}"
            echo ""
            echo "  ${C}Ctrl+B → s${NC}     ${BD}会话列表（sessions）${NC}"
            echo "  ${GR}                 弹出所有会话，上下选择后回车切换${NC}"
            echo ""
            echo "  ${C}Ctrl+B → \$${NC}    ${BD}重命名当前会话${NC}"
            echo "  ${GR}                 给会话起个好记的名字${NC}"
            echo ""
            echo "  ${BD}💡 命令行操作：${NC}"
            echo "  ${C}tmux ls${NC}        查看所有会话"
            echo "  ${C}tmux a${NC}         接入最近的会话（a = attach）"
            echo "  ${C}tmux a -t 名字${NC} 接入指定会话"
            ;;
        2)
            clear
            echo ""
            echo "  ${BD}🪟 窗口管理快捷键${NC}"
            line
            echo ""
            echo "  ${GR}窗口就像浏览器的标签页一样${NC}"
            echo ""
            echo "  ${C}Ctrl+B → c${NC}     ${BD}新建窗口${NC}（create）"
            echo "  ${C}Ctrl+B → n${NC}     ${BD}下一个窗口${NC}（next）"
            echo "  ${C}Ctrl+B → p${NC}     ${BD}上一个窗口${NC}（previous）"
            echo "  ${C}Ctrl+B → 0-9${NC}   ${BD}跳到第 N 个窗口${NC}"
            echo "  ${C}Ctrl+B → ,${NC}     ${BD}重命名窗口${NC}"
            echo "  ${C}Ctrl+B → &${NC}     ${BD}关闭当前窗口${NC}"
            echo "  ${C}Ctrl+B → w${NC}     ${BD}窗口列表${NC}（选择切换）"
            ;;
        3)
            clear
            echo ""
            echo "  ${BD}📜 翻页滚动${NC}"
            line
            echo ""
            echo "  ${G}✅ 你已经开启了鼠标模式（mouse on）${NC}"
            echo "  ${G}   所以：直接用手指/鼠标滑动就能翻页！${NC}"
            echo ""
            echo "  ${BD}如果手指滑动不好使，还有手动方式：${NC}"
            echo ""
            echo "  ${C}Ctrl+B → [${NC}     ${BD}进入滚动模式${NC}"
            echo "  ${GR}                 然后用上下方向键翻页"
            echo "                 按 ${C}q${GR} 退出滚动模式${NC}"
            echo ""
            echo "  ${BD}在滚动模式里：${NC}"
            echo "  ${C}上下方向键${NC}     一行一行翻"
            echo "  ${C}PageUp/Down${NC}   一页一页翻"
            echo "  ${C}g${NC}             跳到最顶部"
            echo "  ${C}G${NC}             跳到最底部"
            echo "  ${C}q${NC}             退出滚动模式"
            ;;
        4)
            clear
            echo ""
            echo "  ${BD}🔲 分屏操作${NC}"
            line
            echo ""
            echo "  ${GR}把一个窗口分成多个区域，同时看多个终端${NC}"
            echo ""
            echo "  ${C}Ctrl+B → %${NC}     ${BD}左右分屏${NC}"
            echo "  ${GR}                 屏幕从中间竖着切一刀${NC}"
            echo ""
            echo "  ${C}Ctrl+B → \"${NC}     ${BD}上下分屏${NC}"
            echo "  ${GR}                 屏幕从中间横着切一刀${NC}"
            echo ""
            echo "  ${C}Ctrl+B → 方向键${NC} ${BD}在分屏间移动${NC}"
            echo "  ${C}Ctrl+B → x${NC}     ${BD}关闭当前分屏${NC}"
            echo "  ${C}Ctrl+B → z${NC}     ${BD}全屏/还原当前分屏${NC}"
            echo "  ${GR}                 再按一次恢复${NC}"
            ;;
        0|*) return ;;
    esac
    pause
}

# ── 会话名校验 ──
# tmux 会话名只允许字母、数字、下划线、短横线
validate_name() {
    local raw="$1"
    local clean=$(echo "$raw" | tr -cd 'a-zA-Z0-9_-')
    if [[ "$raw" != "$clean" ]]; then
        echo "  ${Y}⚠️  名字里有特殊字符，已自动过滤为: ${BD}$clean${NC}"
    fi
    echo "$clean"
}

# ── 启动信息面板（.zshrc 调用，纯展示不阻塞）──
do_startup() {
    local sessions=$(tmux list-sessions 2>/dev/null)
    local count=0
    if [[ -n "$sessions" ]]; then
        count=$(echo "$sessions" | wc -l | tr -d ' ')
    fi

    echo ""

    if [[ "$count" -gt 0 ]]; then
        # 收集会话名
        local names=""
        while IFS= read -r s; do
            local n=$(echo "$s" | cut -d: -f1)
            if [[ -n "$names" ]]; then
                names="$names, $n"
            else
                names="$n"
            fi
        done <<< "$sessions"

        echo "  ${BD}${G}🖥️  tmux: ${count} 个工作空间在运行${NC}  ${GR}($names)${NC}"
    else
        echo "  ${BD}${GR}🖥️  tmux: 没有工作空间在运行${NC}"
    fi

    line
    echo "  ${C}tm a${NC} 进入已有空间    ${C}tm new${NC} 创建新空间"
    echo "  ${C}tm ls${NC} 查看全部        ${C}tm${NC}     打开 Terminal Mentor"
    echo ""
}

# ── 首次使用检测 ──
first_time_check() {
    local flag="$HOME/.tm_welcomed"
    if [[ ! -f "$flag" ]]; then
        welcome
        touch "$flag"
    fi
}

# ── 功能8a：系统状态 ──
do_sys_status() {
    clear
    echo ""
    echo "  ${BD}📊 系统状态${NC}"
    line
    echo ""

    # CPU
    local cpu_brand=$(sysctl -n machdep.cpu.brand_string 2>/dev/null | sed 's/(R)//g; s/(TM)//g')
    local cpu_cores=$(sysctl -n hw.ncpu 2>/dev/null)
    local top_out=$(top -l 1 -n 0 2>/dev/null)
    local cpu_idle=$(echo "$top_out" | grep "CPU usage" | awk -F',' '{print $3}' | awk '{print $1}' | tr -d '%')
    local cpu_used=""
    if [[ -n "$cpu_idle" ]]; then
        cpu_used=$(awk "BEGIN {printf \"%.1f\", 100 - $cpu_idle}")
    fi
    echo "  💻 CPU:  ${BD}${cpu_used:-?}%${NC} (${cpu_cores}核 ${cpu_brand})"

    # 内存（从 top 输出解析 PhysMem 行）
    local mem_total_bytes=$(sysctl -n hw.memsize 2>/dev/null)
    local mem_total_gb=$((mem_total_bytes / 1073741824))
    local mem_used=$(echo "$top_out" | grep "PhysMem" | awk '{print $2}')
    echo "  🧠 内存: ${BD}${mem_used:-?} / ${mem_total_gb}G${NC}"

    # 磁盘
    local disk_info=$(df -h / 2>/dev/null | tail -1)
    local disk_used=$(echo "$disk_info" | awk '{print $3}')
    local disk_total=$(echo "$disk_info" | awk '{print $2}')
    local disk_pct=$(echo "$disk_info" | awk '{print $5}')
    echo "  💾 磁盘: ${BD}${disk_used} / ${disk_total}${NC} (${disk_pct})"

    # IP
    local ip=$(ifconfig en0 2>/dev/null | grep "inet " | awk '{print $2}')
    echo "  🌐 IP:   ${BD}${ip:-未连接}${NC} (en0)"

    # 运行时间
    local boot_sec=$(sysctl -n kern.boottime 2>/dev/null | sed 's/.*sec = //;s/,.*//')
    local now=$(date +%s)
    if [[ -n "$boot_sec" ]] && [[ "$boot_sec" =~ ^[0-9]+$ ]]; then
        local uptime_sec=$((now - boot_sec))
        local up_days=$((uptime_sec / 86400))
        local up_hours=$(( (uptime_sec % 86400) / 3600 ))
        echo "  ⏱️  运行: ${BD}${up_days}天 ${up_hours}小时${NC}"
    fi

    echo ""
    teach "top -l 1 | head -10" "查看 CPU 和内存使用情况"
    pause
}

# ── 功能8b：定时任务一览 ──
do_cron() {
    clear
    echo ""
    echo "  ${BD}⏰ 定时任务一览${NC}"
    line
    echo ""

    # launchd 任务
    echo "  ${BD}launchd 任务：${NC}"
    echo ""
    printf "  ${GR}%-40s %-14s %s${NC}\n" "任务名" "状态" "脚本"
    echo "  ${GR}$(printf '─%.0s' {1..65})${NC}"

    local found_any=false
    local plist_dir="$HOME/Library/LaunchAgents"

    if [[ -d "$plist_dir" ]]; then
        for plist in "$plist_dir"/*.plist(N); do
            [[ -f "$plist" ]] || continue
            local label=$(/usr/libexec/PlistBuddy -c "Print :Label" "$plist" 2>/dev/null)
            [[ -z "$label" ]] && continue

            local loaded=""
            if launchctl list "$label" &>/dev/null; then
                loaded="${G}✅ 已加载${NC}"
            else
                loaded="${Y}⏸️  未加载${NC}"
            fi

            local script=$(/usr/libexec/PlistBuddy -c "Print :ProgramArguments:0" "$plist" 2>/dev/null)
            [[ -z "$script" ]] && script=$(/usr/libexec/PlistBuddy -c "Print :Program" "$plist" 2>/dev/null)
            script=$(basename "$script" 2>/dev/null)

            printf "  %-40s %b  %s\n" "$label" "$loaded" "${script:-?}"
            found_any=true
        done
    fi

    if [[ "$found_any" == false ]]; then
        echo "  ${GR}（没有找到 launchd 任务）${NC}"
    fi

    echo ""

    # crontab
    echo "  ${BD}crontab：${NC}"
    echo ""
    local cron_entries=$(crontab -l 2>/dev/null | grep -v '^#' | grep -v '^$')
    if [[ -n "$cron_entries" ]]; then
        echo "$cron_entries" | while IFS= read -r entry; do
            echo "  ${C}$entry${NC}"
        done
    else
        echo "  ${GR}（无）${NC}"
    fi

    echo ""
    teach "launchctl list" "查看所有已加载的 launchd 任务"
    pause
}

# ── 工具箱：端口管理 ──
do_port() {
    clear
    echo ""
    echo "  ${BD}🔌 端口管理${NC}"
    line
    echo ""
    echo "  ${BD}[1]${NC} 查看某个端口被谁占用了"
    echo "  ${BD}[2]${NC} 释放某个端口（杀掉占用进程）"
    echo "  ${BD}[3]${NC} 查看所有正在监听的端口"
    echo "  ${BD}[0]${NC} 返回"
    echo ""
    echo -n "  选择: "
    read -k1 pick
    echo ""
    echo ""

    case $pick in
        1)
            echo -n "  输入端口号（比如 3000）: "
            read port
            port=$(echo "$port" | tr -cd '0-9')
            if [[ -z "$port" ]]; then
                echo "  ${Y}请输入数字端口号${NC}"
                pause; return
            fi
            echo ""
            local result=$(lsof -i :$port 2>/dev/null | grep LISTEN)
            if [[ -n "$result" ]]; then
                echo "  ${G}端口 $port 被以下进程占用：${NC}"
                echo ""
                echo "$result" | while read line; do
                    echo "  $line"
                done
            else
                echo "  ${G}✅ 端口 $port 没有被占用${NC}"
            fi
            teach "lsof -i :$port" "lsof = list open files，-i 表示网络连接"
            ;;
        2)
            echo -n "  输入要释放的端口号: "
            read port
            port=$(echo "$port" | tr -cd '0-9')
            if [[ -z "$port" ]]; then
                echo "  ${Y}请输入数字端口号${NC}"
                pause; return
            fi
            local pids=$(lsof -ti :$port 2>/dev/null)
            if [[ -z "$pids" ]]; then
                echo "  ${G}✅ 端口 $port 没有被占用，不需要释放${NC}"
            else
                echo "  ${Y}即将杀掉占用端口 $port 的进程: PID=$pids${NC}"
                echo -n "  确定吗？(y/n): "
                read -k1 confirm
                echo ""
                if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                    echo "$pids" | xargs kill -9 2>/dev/null
                    echo "  ${G}✅ 端口 $port 已释放${NC}"
                else
                    echo "  ${GR}已取消${NC}"
                fi
            fi
            teach "lsof -ti :$port | xargs kill -9" "-t 只输出 PID，xargs 把它传给 kill"
            ;;
        3)
            echo "  ${BD}当前所有监听中的端口：${NC}"
            echo ""
            lsof -iTCP -sTCP:LISTEN -P -n 2>/dev/null | awk 'NR==1 || /LISTEN/' | head -20
            echo ""
            teach "lsof -iTCP -sTCP:LISTEN -P -n" "-P 显示端口号，-n 不解析主机名"
            ;;
        0|*) return ;;
    esac
    pause
}

# ── 工具箱：进程管理 ──
do_process() {
    clear
    echo ""
    echo "  ${BD}⚙️  进程管理${NC}"
    line
    echo ""
    echo "  ${BD}[1]${NC} 按名字查找进程"
    echo "  ${BD}[2]${NC} 按名字杀掉进程"
    echo "  ${BD}[3]${NC} 查看最占资源的进程（Top 10）"
    echo "  ${BD}[0]${NC} 返回"
    echo ""
    echo -n "  选择: "
    read -k1 pick
    echo ""
    echo ""

    case $pick in
        1)
            echo -n "  输入进程名（比如 node、python）: "
            read pname
            if [[ -z "$pname" ]]; then
                echo "  ${Y}请输入进程名${NC}"
                pause; return
            fi
            echo ""
            local result=$(ps aux | grep -i "$pname" | grep -v "grep")
            if [[ -n "$result" ]]; then
                echo "  ${G}找到以下进程：${NC}"
                echo ""
                echo "$result" | awk '{printf "  PID=%-6s CPU=%-5s MEM=%-5s %s\n", $2, $3, $4, $11}' | head -15
            else
                echo "  ${GR}没有找到包含 \"$pname\" 的进程${NC}"
            fi
            teach "ps aux | grep $pname" "ps aux 列出所有进程，grep 按名字过滤"
            ;;
        2)
            echo -n "  输入要杀掉的进程名: "
            read pname
            if [[ -z "$pname" ]]; then
                echo "  ${Y}请输入进程名${NC}"
                pause; return
            fi
            local result=$(ps aux | grep -i "$pname" | grep -v "grep")
            if [[ -z "$result" ]]; then
                echo "  ${GR}没有找到包含 \"$pname\" 的进程${NC}"
            else
                echo "  ${Y}将要杀掉以下进程：${NC}"
                echo ""
                echo "$result" | awk '{printf "  PID=%-6s %s\n", $2, $11}' | head -10
                echo ""
                echo -n "  确定吗？(y/n): "
                read -k1 confirm
                echo ""
                if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                    pkill -f "$pname" 2>/dev/null
                    echo "  ${G}✅ 已发送终止信号${NC}"
                else
                    echo "  ${GR}已取消${NC}"
                fi
            fi
            teach "pkill -f $pname" "pkill 按名字杀进程，-f 匹配完整命令行"
            ;;
        3)
            echo "  ${BD}最占 CPU 的 10 个进程：${NC}"
            echo ""
            ps aux -r 2>/dev/null | head -11
            echo ""
            teach "ps aux -r | head -10" "按 CPU 使用率倒序排列（macOS 用 -r）"
            ;;
        0|*) return ;;
    esac
    pause
}

# ── 工具箱：快速搜索 ──
do_search() {
    clear
    echo ""
    echo "  ${BD}🔍 快速搜索${NC}"
    line
    echo ""
    echo "  ${BD}[1]${NC} 按文件名搜索"
    echo "  ${BD}[2]${NC} 按文件内容搜索（在代码里找某个词）"
    echo "  ${BD}[0]${NC} 返回"
    echo ""
    echo -n "  选择: "
    read -k1 pick
    echo ""
    echo ""

    case $pick in
        1)
            echo -n "  输入文件名（支持通配符，比如 *.js）: "
            read fname
            if [[ -z "$fname" ]]; then
                echo "  ${Y}请输入文件名${NC}"
                pause; return
            fi
            echo ""
            echo "  ${GR}在当前目录下搜索...${NC}"
            echo ""
            find . -name "$fname" -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | head -20
            echo ""
            teach "find . -name \"$fname\"" "find 从当前目录(.)递归搜索，-name 按名字匹配"
            ;;
        2)
            echo -n "  输入要搜索的内容: "
            read keyword
            if [[ -z "$keyword" ]]; then
                echo "  ${Y}请输入搜索内容${NC}"
                pause; return
            fi
            echo ""
            echo "  ${GR}在当前目录下搜索...${NC}"
            echo ""
            grep -rn --include="*" --exclude-dir={node_modules,.git,dist,.next} "$keyword" . 2>/dev/null | head -20
            echo ""
            teach "grep -rn \"$keyword\" ." "-r 递归搜索，-n 显示行号"
            ;;
        0|*) return ;;
    esac
    pause
}

# ── 工具箱：网络诊断 ──
do_network() {
    clear
    echo ""
    echo "  ${BD}🌐 网络诊断${NC}"
    line
    echo ""
    echo "  ${BD}[1]${NC} 查看我的 IP（内网 + 公网）"
    echo "  ${BD}[2]${NC} 测试能不能连上某个地址"
    echo "  ${BD}[3]${NC} DNS 查询"
    echo "  ${BD}[0]${NC} 返回"
    echo ""
    echo -n "  选择: "
    read -k1 pick
    echo ""
    echo ""

    case $pick in
        1)
            echo "  ${BD}内网 IP：${NC}"
            local lip=$(ifconfig en0 2>/dev/null | grep "inet " | awk '{print $2}')
            echo "    ${G}${lip:-未连接}${NC} (en0/Wi-Fi)"
            echo ""
            echo "  ${BD}公网 IP：${NC}"
            local pip=$(curl -s --connect-timeout 3 ifconfig.me 2>/dev/null)
            echo "    ${G}${pip:-获取失败（可能没联网）}${NC}"
            echo ""
            teach "curl ifconfig.me" "一条命令查公网 IP，记住这个网址就行"
            ;;
        2)
            echo -n "  输入地址（比如 google.com 或 192.168.1.1）: "
            read addr
            if [[ -z "$addr" ]]; then
                echo "  ${Y}请输入地址${NC}"
                pause; return
            fi
            echo ""
            echo "  ${GR}正在 ping $addr ...${NC}"
            echo ""
            ping -c 4 "$addr" 2>/dev/null
            echo ""
            teach "ping -c 4 $addr" "-c 4 表示只 ping 4 次就停，不加 -c 会一直 ping"
            ;;
        3)
            echo -n "  输入域名（比如 github.com）: "
            read domain
            if [[ -z "$domain" ]]; then
                echo "  ${Y}请输入域名${NC}"
                pause; return
            fi
            echo ""
            nslookup "$domain" 2>/dev/null || dig "$domain" 2>/dev/null
            echo ""
            teach "nslookup $domain" "查询域名对应的 IP 地址"
            ;;
        0|*) return ;;
    esac
    pause
}

# ── Git 工具函数 ──

# 检查是否在 git 仓库内
require_git_repo() {
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        echo "  ${R}❌ 当前目录不是 Git 仓库${NC}"
        echo "  ${GR}先 cd 到项目目录，或用「初始化/克隆」${NC}"
        return 1
    fi
    return 0
}

# Git 状态概览面板
git_status_panel() {
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        local branch=$(git branch --show-current 2>/dev/null)
        local changes=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
        local repo=$(basename $(git rev-parse --show-toplevel 2>/dev/null))
        echo "  ${GR}仓库: ${BD}${repo}${NC}  ${GR}分支: ${C}${branch}${NC}  ${GR}变更: ${changes} 个文件${NC}"
        local ab=$(git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)
        if [[ -n "$ab" ]]; then
            local ahead=$(echo "$ab" | awk '{print $1}')
            local behind=$(echo "$ab" | awk '{print $2}')
            local info=""
            [[ "$ahead" -gt 0 ]] && info="${info}${G}↑${ahead}待推送${NC} "
            [[ "$behind" -gt 0 ]] && info="${info}${Y}↓${behind}待拉取${NC} "
            [[ -n "$info" ]] && echo "  ${GR}同步: ${NC}${info}"
        fi
    else
        echo "  ${Y}⚠️  不在 Git 仓库内${NC}"
    fi
    echo ""
}

# ── Git 子菜单：状态 & 改动 ──
do_git_status() {
    clear
    echo ""
    echo "  ${BD}📋 状态 & 改动${NC}"
    line
    echo ""
    git_status_panel

    echo "  ${BD}[1]${NC} 查看状态         ${GR}git status${NC}"
    echo "  ${BD}[2]${NC} 改动摘要         ${GR}git diff --stat${NC}"
    echo "  ${BD}[3]${NC} 详细改动         ${GR}git diff${NC}"
    echo "  ${BD}[4]${NC} 已暂存的改动      ${GR}git diff --staged${NC}"
    echo "  ${BD}[5]${NC} 谁改了哪行       ${GR}git blame${NC}"
    echo "  ${BD}[0]${NC} 返回"
    echo ""
    echo -n "  选择: "
    read -k1 pick
    echo ""

    case $pick in
        1)
            require_git_repo || { pause; return; }
            echo ""
            git status
            teach "git status" "查看哪些文件被修改、哪些未跟踪"
            ;;
        2)
            require_git_repo || { pause; return; }
            echo ""
            git diff --stat
            teach "git diff --stat" "只看摘要，不看具体内容"
            ;;
        3)
            require_git_repo || { pause; return; }
            echo ""
            git diff
            teach "git diff" "查看未暂存的详细修改"
            ;;
        4)
            require_git_repo || { pause; return; }
            echo ""
            git diff --staged
            teach "git diff --staged" "查看已 add 但未 commit 的改动"
            ;;
        5)
            require_git_repo || { pause; return; }
            echo -n "  输入文件路径: "
            read filepath
            if [[ -z "$filepath" ]]; then
                echo "  ${Y}已取消${NC}"
            elif [[ ! -f "$filepath" ]]; then
                echo "  ${R}文件不存在: $filepath${NC}"
            else
                echo ""
                git blame "$filepath" 2>/dev/null | head -30
                echo ""
                echo "  ${GR}(显示前 30 行，完整版: git blame $filepath)${NC}"
            fi
            teach "git blame 文件名" "逐行显示谁在什么时候改了这行"
            ;;
        0|*) return ;;
    esac
    pause
}

# ── Git 子菜单：提交变更 ──
do_git_commit() {
    clear
    echo ""
    echo "  ${BD}✏️  提交变更${NC}"
    line
    echo ""
    git_status_panel

    echo "  ${BD}[1]${NC} 添加全部 + 提交   ${GR}git add -A && commit${NC}"
    echo "  ${BD}[2]${NC} 选择文件添加      ${GR}git add <文件>${NC}"
    echo "  ${BD}[3]${NC} 修改上次提交说明   ${GR}git commit --amend${NC}"
    echo "  ${BD}[4]${NC} 追加到上次提交     ${GR}git commit --amend --no-edit${NC}"
    echo "  ${BD}[0]${NC} 返回"
    echo ""
    echo -n "  选择: "
    read -k1 pick
    echo ""

    case $pick in
        1)
            require_git_repo || { pause; return; }
            local changes=$(git status --porcelain 2>/dev/null)
            if [[ -z "$changes" ]]; then
                echo "  ${G}✅ 没有需要提交的变更${NC}"; pause; return
            fi
            echo ""
            echo "  ${GR}变更文件：${NC}"
            git status --short
            echo ""
            echo -n "  ${BD}提交说明${NC}（一句话描述改了什么）: "
            read msg
            if [[ -z "$msg" ]]; then
                echo "  ${Y}取消提交（没有输入说明）${NC}"
            else
                git add -A && git commit -m "$msg"
                echo ""
                echo "  ${G}✅ 已提交${NC}"
            fi
            teach "git add -A && git commit -m \"说明\"" "add -A 添加全部，-m 写提交说明"
            ;;
        2)
            require_git_repo || { pause; return; }
            echo ""
            echo "  ${GR}未跟踪/已修改的文件：${NC}"
            git status --short
            echo ""
            echo -n "  ${BD}输入要添加的文件${NC}（多个用空格分开，. 表示全部）: "
            read files
            if [[ -z "$files" ]]; then
                echo "  ${Y}已取消${NC}"
            else
                git add ${=files}
                echo "  ${G}✅ 已添加${NC}"
                echo ""
                echo "  ${GR}当前暂存区：${NC}"
                git diff --staged --stat
            fi
            teach "git add 文件1 文件2" "只添加你指定的文件，比 add -A 更精确"
            ;;
        3)
            require_git_repo || { pause; return; }
            local last=$(git log --oneline -1 2>/dev/null)
            if [[ -z "$last" ]]; then
                echo "  ${Y}还没有任何提交${NC}"; pause; return
            fi
            echo "  ${GR}当前提交：${NC} $last"
            echo -n "  ${BD}新的提交说明${NC}: "
            read newmsg
            if [[ -z "$newmsg" ]]; then
                echo "  ${Y}已取消${NC}"
            else
                git commit --amend -m "$newmsg"
                echo "  ${G}✅ 提交说明已修改${NC}"
            fi
            teach "git commit --amend -m \"新说明\"" "修改最近一次提交的说明文字"
            ;;
        4)
            require_git_repo || { pause; return; }
            local changes=$(git status --porcelain 2>/dev/null)
            if [[ -z "$changes" ]]; then
                echo "  ${Y}没有新的变更可以追加${NC}"; pause; return
            fi
            echo ""
            echo "  ${GR}将以下变更追加到上次提交：${NC}"
            git status --short
            echo ""
            echo -n "  ${BD}确认追加？${NC}（y/n）: "
            read -k1 yn
            echo ""
            if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
                git add -A && git commit --amend --no-edit
                echo "  ${G}✅ 已追加到上次提交${NC}"
            else
                echo "  ${GR}已取消${NC}"
            fi
            teach "git add -A && git commit --amend --no-edit" "追加修改到上次提交，不改说明"
            ;;
        0|*) return ;;
    esac
    pause
}

# ── Git 子菜单：分支管理 ──
do_git_branch() {
    clear
    echo ""
    echo "  ${BD}🌿 分支管理${NC}"
    line
    echo ""
    git_status_panel

    echo "  ${BD}[1]${NC} 列出所有分支      ${GR}git branch -a${NC}"
    echo "  ${BD}[2]${NC} 创建新分支        ${GR}git checkout -b${NC}"
    echo "  ${BD}[3]${NC} 切换分支          ${GR}git switch${NC}"
    echo "  ${BD}[4]${NC} 删除分支          ${GR}git branch -d${NC}"
    echo "  ${BD}[5]${NC} 重命名当前分支     ${GR}git branch -m${NC}"
    echo "  ${BD}[6]${NC} 合并分支到当前     ${GR}git merge${NC}"
    echo "  ${BD}[0]${NC} 返回"
    echo ""
    echo -n "  选择: "
    read -k1 pick
    echo ""

    case $pick in
        1)
            require_git_repo || { pause; return; }
            echo ""
            echo "  ${BD}本地分支：${NC}"
            git branch --list 2>/dev/null | while read -r b; do
                if [[ "$b" == \** ]]; then
                    echo "  ${G}$b${NC}  ← 当前"
                else
                    echo "  $b"
                fi
            done
            echo ""
            local remotes=$(git branch -r 2>/dev/null)
            if [[ -n "$remotes" ]]; then
                echo "  ${BD}远程分支：${NC}"
                echo "$remotes" | while read -r b; do echo "  ${GR}$b${NC}"; done
            fi
            teach "git branch -a" "-a 显示所有分支（包括远程的）"
            ;;
        2)
            require_git_repo || { pause; return; }
            echo -n "  ${BD}新分支名${NC}: "
            read bname
            bname=$(echo "$bname" | tr -cd 'a-zA-Z0-9_-/')
            if [[ -z "$bname" ]]; then
                echo "  ${Y}已取消${NC}"
            else
                git checkout -b "$bname"
                echo "  ${G}✅ 已创建并切换到 ${BD}$bname${NC}"
            fi
            teach "git checkout -b $bname" "-b 表示创建新分支并自动切过去"
            ;;
        3)
            require_git_repo || { pause; return; }
            echo ""
            echo "  ${GR}可用分支：${NC}"
            git branch --list 2>/dev/null
            echo ""
            echo -n "  ${BD}切换到哪个分支${NC}: "
            read target
            if [[ -z "$target" ]]; then
                echo "  ${Y}已取消${NC}"
            else
                git switch "$target" 2>/dev/null || git checkout "$target" 2>/dev/null
                if [[ $? -eq 0 ]]; then
                    echo "  ${G}✅ 已切换到 ${BD}$target${NC}"
                else
                    echo "  ${R}切换失败，检查分支名是否正确${NC}"
                fi
            fi
            teach "git switch 分支名" "switch 比 checkout 更安全，专门用来切分支"
            ;;
        4)
            require_git_repo || { pause; return; }
            echo ""
            echo "  ${GR}可用分支：${NC}"
            git branch --list 2>/dev/null
            echo ""
            echo -n "  ${BD}删除哪个分支${NC}: "
            read del_branch
            if [[ -z "$del_branch" ]]; then
                echo "  ${Y}已取消${NC}"
            else
                local current=$(git branch --show-current)
                if [[ "$del_branch" == "$current" ]]; then
                    echo "  ${R}不能删除当前所在的分支${NC}"
                else
                    echo -n "  ${Y}确认删除分支 ${BD}$del_branch${Y}？${NC}（y/n）: "
                    read -k1 yn
                    echo ""
                    if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
                        git branch -d "$del_branch" 2>/dev/null
                        if [[ $? -ne 0 ]]; then
                            echo -n "  ${Y}分支未合并。强制删除？${NC}（y/n）: "
                            read -k1 yn2
                            echo ""
                            if [[ "$yn2" == "y" || "$yn2" == "Y" ]]; then
                                git branch -D "$del_branch"
                                echo "  ${G}✅ 已强制删除${NC}"
                            else
                                echo "  ${GR}已取消${NC}"
                            fi
                        else
                            echo "  ${G}✅ 已删除${NC}"
                        fi
                    else
                        echo "  ${GR}已取消${NC}"
                    fi
                fi
            fi
            teach "git branch -d 分支名" "-d 安全删除（已合并的），-D 强制删除"
            ;;
        5)
            require_git_repo || { pause; return; }
            local current=$(git branch --show-current 2>/dev/null)
            echo "  ${GR}当前分支: ${C}$current${NC}"
            echo -n "  ${BD}新名字${NC}: "
            read newname
            newname=$(echo "$newname" | tr -cd 'a-zA-Z0-9_-/')
            if [[ -z "$newname" ]]; then
                echo "  ${Y}已取消${NC}"
            else
                git branch -m "$newname"
                echo "  ${G}✅ 已重命名为 ${BD}$newname${NC}"
            fi
            teach "git branch -m 新名字" "-m 就是 move（重命名）的意思"
            ;;
        6)
            require_git_repo || { pause; return; }
            local current=$(git branch --show-current 2>/dev/null)
            echo "  ${GR}当前分支: ${C}$current${NC}"
            echo ""
            echo "  ${GR}可用分支：${NC}"
            git branch --list 2>/dev/null
            echo ""
            echo -n "  ${BD}合并哪个分支到 ${C}$current${NC}${BD}？${NC}: "
            read merge_branch
            if [[ -z "$merge_branch" ]]; then
                echo "  ${Y}已取消${NC}"
            else
                git merge "$merge_branch"
                if [[ $? -eq 0 ]]; then
                    echo "  ${G}✅ 合并完成${NC}"
                else
                    echo ""
                    echo "  ${Y}⚠️  有冲突需要手动解决${NC}"
                    echo "  ${GR}解决后运行: ${C}git add . && git commit${NC}"
                    echo "  ${GR}放弃合并: ${C}git merge --abort${NC}"
                fi
            fi
            teach "git merge 分支名" "把指定分支的修改合并到当前分支"
            ;;
        0|*) return ;;
    esac
    pause
}

# ── Git 子菜单：远程操作 ──
do_git_remote() {
    clear
    echo ""
    echo "  ${BD}🔗 远程操作${NC}"
    line
    echo ""
    git_status_panel

    echo "  ${BD}[1]${NC} 查看远程仓库      ${GR}git remote -v${NC}"
    echo "  ${BD}[2]${NC} 添加远程仓库      ${GR}git remote add${NC}"
    echo "  ${BD}[3]${NC} 拉取更新          ${GR}git pull${NC}"
    echo "  ${BD}[4]${NC} 推送到远程        ${GR}git push${NC}"
    echo "  ${BD}[5]${NC} 推送并设置上游     ${GR}git push -u${NC}"
    echo "  ${BD}[6]${NC} 获取远程信息       ${GR}git fetch${NC}"
    echo "  ${BD}[7]${NC} 克隆仓库          ${GR}git clone${NC}"
    echo "  ${BD}[0]${NC} 返回"
    echo ""
    echo -n "  选择: "
    read -k1 pick
    echo ""

    case $pick in
        1)
            require_git_repo || { pause; return; }
            echo ""
            local remotes=$(git remote -v 2>/dev/null)
            if [[ -z "$remotes" ]]; then
                echo "  ${Y}还没有配置远程仓库${NC}"
                echo "  ${GR}用 [2] 添加一个，比如 GitHub 仓库地址${NC}"
            else
                echo "  ${BD}远程仓库列表：${NC}"
                echo "$remotes" | while read -r r; do echo "  $r"; done
            fi
            teach "git remote -v" "-v 显示详细地址，不加 -v 只显示名字"
            ;;
        2)
            require_git_repo || { pause; return; }
            echo -n "  ${BD}远程名${NC}（一般叫 origin）: "
            read rname
            rname=${rname:-origin}
            echo -n "  ${BD}仓库地址${NC}: "
            read rurl
            if [[ -z "$rurl" ]]; then
                echo "  ${Y}已取消${NC}"
            else
                git remote add "$rname" "$rurl" 2>/dev/null
                if [[ $? -eq 0 ]]; then
                    echo "  ${G}✅ 已添加远程仓库 ${BD}$rname${NC}"
                else
                    echo "  ${R}添加失败，可能 $rname 已存在${NC}"
                fi
            fi
            teach "git remote add origin 地址" "origin 是远程仓库的默认名字"
            ;;
        3)
            require_git_repo || { pause; return; }
            echo ""
            git pull 2>&1
            if [[ $? -eq 0 ]]; then
                echo "  ${G}✅ 拉取完成${NC}"
            else
                echo "  ${R}拉取失败${NC}"
                echo "  ${GR}可能原因：没设置远程仓库 / 有冲突 / 网络问题${NC}"
            fi
            teach "git pull" "从远程仓库拉取最新代码并合并到当前分支"
            ;;
        4)
            require_git_repo || { pause; return; }
            echo ""
            git push 2>&1
            if [[ $? -eq 0 ]]; then
                echo "  ${G}✅ 推送完成${NC}"
            else
                echo "  ${Y}推送失败${NC}"
                echo "  ${GR}如果是新分支，试试 [5] 推送并设置上游${NC}"
            fi
            teach "git push" "把本地提交推送到远程仓库"
            ;;
        5)
            require_git_repo || { pause; return; }
            local branch=$(git branch --show-current 2>/dev/null)
            echo ""
            git push -u origin "$branch" 2>&1
            if [[ $? -eq 0 ]]; then
                echo "  ${G}✅ 推送完成，已设置 ${C}$branch${G} 追踪远程分支${NC}"
            else
                echo "  ${R}推送失败，检查远程仓库设置${NC}"
            fi
            teach "git push -u origin $branch" "-u 设置上游追踪，以后直接 git push 就行"
            ;;
        6)
            require_git_repo || { pause; return; }
            echo ""
            git fetch --all 2>&1
            echo "  ${G}✅ 已获取远程最新信息${NC}"
            echo ""
            echo "  ${GR}fetch 只是下载信息，不会修改你的代码${NC}"
            echo "  ${GR}想合并到本地，再执行 git pull 或 git merge${NC}"
            teach "git fetch --all" "获取所有远程分支的最新信息（不改本地代码）"
            ;;
        7)
            echo -n "  ${BD}仓库地址${NC}（HTTPS 或 SSH）: "
            read clone_url
            if [[ -z "$clone_url" ]]; then
                echo "  ${Y}已取消${NC}"; pause; return
            fi
            echo -n "  ${BD}目标文件夹名${NC}（回车=默认）: "
            read clone_dir
            echo ""
            echo "  ${GR}正在克隆...${NC}"
            if [[ -n "$clone_dir" ]]; then
                git clone "$clone_url" "$clone_dir" 2>&1
            else
                git clone "$clone_url" 2>&1
            fi
            if [[ $? -eq 0 ]]; then
                echo "  ${G}✅ 克隆完成${NC}"
            else
                echo "  ${R}克隆失败，检查地址是否正确${NC}"
            fi
            teach "git clone 地址 [文件夹名]" "把远程仓库完整下载到本地"
            ;;
        0|*) return ;;
    esac
    pause
}

# ── Git 子菜单：暂存区 (Stash) ──
do_git_stash() {
    clear
    echo ""
    echo "  ${BD}📦 暂存区 (Stash)${NC}"
    line
    echo ""
    echo "  ${GR}Stash = 临时保存箱。改到一半要切分支？先 stash 存起来，回来再取出。${NC}"
    echo ""

    if git rev-parse --is-inside-work-tree &>/dev/null; then
        local stash_count=$(git stash list 2>/dev/null | wc -l | tr -d ' ')
        echo "  ${GR}暂存区里有 ${BD}${stash_count}${NC}${GR} 个保存${NC}"
        echo ""
    fi

    echo "  ${BD}[1]${NC} 保存当前修改      ${GR}git stash${NC}"
    echo "  ${BD}[2]${NC} 取出最近保存      ${GR}git stash pop${NC}"
    echo "  ${BD}[3]${NC} 查看暂存列表      ${GR}git stash list${NC}"
    echo "  ${BD}[4]${NC} 查看暂存内容      ${GR}git stash show${NC}"
    echo "  ${BD}[5]${NC} 删除最近暂存      ${GR}git stash drop${NC}"
    echo "  ${BD}[6]${NC} 清空所有暂存      ${GR}git stash clear${NC}"
    echo "  ${BD}[0]${NC} 返回"
    echo ""
    echo -n "  选择: "
    read -k1 pick
    echo ""

    case $pick in
        1)
            require_git_repo || { pause; return; }
            local changes=$(git status --porcelain 2>/dev/null)
            if [[ -z "$changes" ]]; then
                echo "  ${G}没有需要保存的修改${NC}"; pause; return
            fi
            echo -n "  ${BD}备注${NC}（方便以后认，回车跳过）: "
            read note
            if [[ -n "$note" ]]; then
                git stash push -m "$note"
            else
                git stash
            fi
            echo "  ${G}✅ 修改已保存到暂存区，工作目录已清空${NC}"
            teach "git stash push -m \"备注\"" "把当前修改存到暂存区，加 -m 写个备注"
            ;;
        2)
            require_git_repo || { pause; return; }
            local stash_count=$(git stash list 2>/dev/null | wc -l | tr -d ' ')
            if [[ "$stash_count" -eq 0 ]]; then
                echo "  ${Y}暂存区是空的${NC}"; pause; return
            fi
            echo "  ${GR}最近一条：${NC}"
            git stash list | head -1
            echo ""
            git stash pop
            if [[ $? -eq 0 ]]; then
                echo "  ${G}✅ 已取出并删除该暂存${NC}"
            else
                echo "  ${R}取出失败，可能有冲突${NC}"
                echo "  ${GR}解决冲突后手动 git stash drop 删除这条暂存${NC}"
            fi
            teach "git stash pop" "取出最近一次保存的修改，并删除该暂存记录"
            ;;
        3)
            require_git_repo || { pause; return; }
            echo ""
            local list=$(git stash list 2>/dev/null)
            if [[ -z "$list" ]]; then
                echo "  ${GR}暂存区是空的${NC}"
            else
                echo "  ${BD}暂存列表：${NC}"
                echo "$list"
            fi
            teach "git stash list" "查看所有暂存记录"
            ;;
        4)
            require_git_repo || { pause; return; }
            local stash_count=$(git stash list 2>/dev/null | wc -l | tr -d ' ')
            if [[ "$stash_count" -eq 0 ]]; then
                echo "  ${Y}暂存区是空的${NC}"; pause; return
            fi
            echo ""
            git stash show -p 2>/dev/null | head -50
            echo ""
            echo "  ${GR}(显示前 50 行，完整版: git stash show -p)${NC}"
            teach "git stash show -p" "-p 显示详细改动内容"
            ;;
        5)
            require_git_repo || { pause; return; }
            local stash_count=$(git stash list 2>/dev/null | wc -l | tr -d ' ')
            if [[ "$stash_count" -eq 0 ]]; then
                echo "  ${Y}暂存区是空的${NC}"; pause; return
            fi
            echo "  ${GR}最近一条：${NC}"
            git stash list | head -1
            echo -n "  ${Y}确认删除？${NC}（y/n）: "
            read -k1 yn
            echo ""
            if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
                git stash drop
                echo "  ${G}✅ 已删除${NC}"
            else
                echo "  ${GR}已取消${NC}"
            fi
            teach "git stash drop" "删除最近一条暂存（不恢复修改）"
            ;;
        6)
            require_git_repo || { pause; return; }
            local stash_count=$(git stash list 2>/dev/null | wc -l | tr -d ' ')
            if [[ "$stash_count" -eq 0 ]]; then
                echo "  ${Y}暂存区已经是空的${NC}"; pause; return
            fi
            echo "  ${R}⚠️  将清空所有 $stash_count 条暂存，无法恢复！${NC}"
            echo -n "  ${BD}确认清空？${NC}（输入 yes）: "
            read confirm
            if [[ "$confirm" == "yes" ]]; then
                git stash clear
                echo "  ${G}✅ 暂存区已清空${NC}"
            else
                echo "  ${GR}已取消${NC}"
            fi
            teach "git stash clear" "清空全部暂存记录（慎用！）"
            ;;
        0|*) return ;;
    esac
    pause
}

# ── Git 子菜单：撤销 & 恢复 ──
do_git_undo() {
    clear
    echo ""
    echo "  ${BD}⏪ 撤销 & 恢复${NC}"
    line
    echo ""
    git_status_panel

    echo "  ${BD}[1]${NC} 撤销上次提交（保留修改）  ${GR}git reset --soft${NC}"
    echo "  ${BD}[2]${NC} 恢复某个文件            ${GR}git restore${NC}"
    echo "  ${BD}[3]${NC} 取消暂存（add 反悔）     ${GR}git restore --staged${NC}"
    echo "  ${BD}[4]${NC} 回退某次提交             ${GR}git revert${NC}"
    echo "  ${BD}[5]${NC} 查看某次提交的内容        ${GR}git show${NC}"
    echo "  ${BD}[0]${NC} 返回"
    echo ""
    echo -n "  选择: "
    read -k1 pick
    echo ""

    case $pick in
        1)
            require_git_repo || { pause; return; }
            local last=$(git log --oneline -1 2>/dev/null)
            if [[ -z "$last" ]]; then
                echo "  ${Y}还没有任何提交${NC}"; pause; return
            fi
            echo "  ${Y}即将撤销：${NC} $last"
            echo -n "  ${BD}确认撤销？${NC}（y/n）: "
            read -k1 yn
            echo ""
            if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
                git reset --soft HEAD~1
                echo "  ${G}✅ 已撤销提交（文件改动保留在暂存区）${NC}"
            else
                echo "  ${GR}已取消${NC}"
            fi
            teach "git reset --soft HEAD~1" "--soft 撤销提交但保留修改，最安全的撤销方式"
            ;;
        2)
            require_git_repo || { pause; return; }
            echo ""
            echo "  ${GR}已修改的文件：${NC}"
            git diff --name-only 2>/dev/null
            echo ""
            echo -n "  ${BD}恢复哪个文件${NC}（输入文件路径）: "
            read filepath
            if [[ -z "$filepath" ]]; then
                echo "  ${Y}已取消${NC}"
            else
                echo "  ${Y}⚠️  将丢弃该文件的所有未提交修改！${NC}"
                echo -n "  ${BD}确认恢复？${NC}（y/n）: "
                read -k1 yn
                echo ""
                if [[ "$yn" == "y" || "$yn" == "Y" ]]; then
                    git restore "$filepath" 2>/dev/null || git checkout -- "$filepath" 2>/dev/null
                    echo "  ${G}✅ 已恢复${NC}"
                else
                    echo "  ${GR}已取消${NC}"
                fi
            fi
            teach "git restore 文件名" "把文件恢复到最后一次提交的状态"
            ;;
        3)
            require_git_repo || { pause; return; }
            echo ""
            echo "  ${GR}已暂存（add 过）的文件：${NC}"
            git diff --staged --name-only 2>/dev/null
            echo ""
            echo -n "  ${BD}取消暂存哪个文件${NC}（输入路径，. 表示全部）: "
            read filepath
            if [[ -z "$filepath" ]]; then
                echo "  ${Y}已取消${NC}"
            else
                git restore --staged "$filepath" 2>/dev/null || git reset HEAD "$filepath" 2>/dev/null
                echo "  ${G}✅ 已取消暂存（文件修改还在，只是退回到「未 add」状态）${NC}"
            fi
            teach "git restore --staged 文件名" "取消 add，文件回到「未暂存」状态"
            ;;
        4)
            require_git_repo || { pause; return; }
            echo ""
            echo "  ${GR}最近 10 次提交：${NC}"
            git log --oneline -10
            echo ""
            echo -n "  ${BD}输入要回退的提交 ID${NC}（前 7 位就行）: "
            read cid
            if [[ -z "$cid" ]]; then
                echo "  ${Y}已取消${NC}"
            else
                echo "  ${GR}revert 会创建一个新提交来撤销那次修改，很安全${NC}"
                git revert "$cid" --no-edit 2>&1
                if [[ $? -eq 0 ]]; then
                    echo "  ${G}✅ 已回退（创建了新提交）${NC}"
                else
                    echo "  ${R}回退失败，可能有冲突${NC}"
                    echo "  ${GR}解决冲突后: ${C}git revert --continue${NC}"
                    echo "  ${GR}放弃回退: ${C}git revert --abort${NC}"
                fi
            fi
            teach "git revert 提交ID" "创建新提交来撤销某次修改，不改历史，很安全"
            ;;
        5)
            require_git_repo || { pause; return; }
            echo ""
            echo "  ${GR}最近 10 次提交：${NC}"
            git log --oneline -10
            echo ""
            echo -n "  ${BD}查看哪个提交${NC}（ID 前 7 位）: "
            read cid
            if [[ -z "$cid" ]]; then
                echo "  ${Y}已取消${NC}"
            else
                echo ""
                git show "$cid" --stat 2>/dev/null
            fi
            teach "git show 提交ID" "查看某次提交的详细信息和修改内容"
            ;;
        0|*) return ;;
    esac
    pause
}

# ── Git 子菜单：标签管理 ──
do_git_tag() {
    clear
    echo ""
    echo "  ${BD}🏷️  标签管理${NC}"
    line
    echo ""
    echo "  ${GR}标签 = 给重要节点做标记，比如版本号 v1.0、v2.0${NC}"
    echo ""

    echo "  ${BD}[1]${NC} 列出所有标签      ${GR}git tag${NC}"
    echo "  ${BD}[2]${NC} 创建标签          ${GR}git tag -a${NC}"
    echo "  ${BD}[3]${NC} 删除标签          ${GR}git tag -d${NC}"
    echo "  ${BD}[4]${NC} 推送标签到远程     ${GR}git push --tags${NC}"
    echo "  ${BD}[0]${NC} 返回"
    echo ""
    echo -n "  选择: "
    read -k1 pick
    echo ""

    case $pick in
        1)
            require_git_repo || { pause; return; }
            echo ""
            local tags=$(git tag -l 2>/dev/null)
            if [[ -z "$tags" ]]; then
                echo "  ${GR}还没有标签${NC}"
            else
                echo "  ${BD}标签列表：${NC}"
                git tag -l --sort=-version:refname 2>/dev/null | head -20
            fi
            teach "git tag -l" "列出所有标签"
            ;;
        2)
            require_git_repo || { pause; return; }
            echo -n "  ${BD}标签名${NC}（比如 v1.0）: "
            read tname
            if [[ -z "$tname" ]]; then
                echo "  ${Y}已取消${NC}"
            else
                echo -n "  ${BD}标签说明${NC}（回车跳过）: "
                read tmsg
                if [[ -n "$tmsg" ]]; then
                    git tag -a "$tname" -m "$tmsg"
                else
                    git tag "$tname"
                fi
                echo "  ${G}✅ 标签 ${BD}$tname${G} 已创建${NC}"
                echo "  ${GR}别忘了用 [4] 推送到远程${NC}"
            fi
            teach "git tag -a v1.0 -m \"说明\"" "-a 创建带注释的标签，更规范"
            ;;
        3)
            require_git_repo || { pause; return; }
            echo ""
            echo "  ${GR}现有标签：${NC}"
            git tag -l 2>/dev/null | head -20
            echo ""
            echo -n "  ${BD}删除哪个标签${NC}: "
            read tname
            if [[ -z "$tname" ]]; then
                echo "  ${Y}已取消${NC}"
            else
                git tag -d "$tname" 2>/dev/null
                echo "  ${G}✅ 本地标签 ${BD}$tname${G} 已删除${NC}"
                echo "  ${GR}远程删除: ${C}git push origin --delete $tname${NC}"
            fi
            teach "git tag -d 标签名" "只删本地标签，远程要另外删"
            ;;
        4)
            require_git_repo || { pause; return; }
            echo ""
            git push --tags 2>&1
            if [[ $? -eq 0 ]]; then
                echo "  ${G}✅ 所有标签已推送到远程${NC}"
            else
                echo "  ${R}推送失败，检查远程仓库设置${NC}"
            fi
            teach "git push --tags" "把所有本地标签推送到远程"
            ;;
        0|*) return ;;
    esac
    pause
}

# ── Git 子菜单：初始化 / 克隆 ──
do_git_init() {
    clear
    echo ""
    echo "  ${BD}🔧 初始化 / 克隆${NC}"
    line
    echo ""

    echo "  ${BD}[1]${NC} 初始化新仓库      ${GR}git init${NC}"
    echo "  ${BD}[2]${NC} 克隆远程仓库      ${GR}git clone${NC}"
    echo "  ${BD}[0]${NC} 返回"
    echo ""
    echo -n "  选择: "
    read -k1 pick
    echo ""

    case $pick in
        1)
            if git rev-parse --is-inside-work-tree &>/dev/null; then
                echo "  ${Y}⚠️  当前目录已经是 Git 仓库了${NC}"
            else
                git init
                echo "  ${G}✅ Git 仓库已初始化${NC}"
            fi
            teach "git init" "在当前目录创建一个新的 Git 仓库"
            ;;
        2)
            echo -n "  ${BD}仓库地址${NC}（HTTPS 或 SSH）: "
            read clone_url
            if [[ -z "$clone_url" ]]; then
                echo "  ${Y}已取消${NC}"; pause; return
            fi
            echo -n "  ${BD}目标文件夹名${NC}（回车=默认）: "
            read clone_dir
            echo ""
            echo "  ${GR}正在克隆...${NC}"
            if [[ -n "$clone_dir" ]]; then
                git clone "$clone_url" "$clone_dir" 2>&1
            else
                git clone "$clone_url" 2>&1
            fi
            if [[ $? -eq 0 ]]; then
                echo "  ${G}✅ 克隆完成${NC}"
            else
                echo "  ${R}克隆失败，检查地址是否正确${NC}"
            fi
            teach "git clone 地址 [文件夹名]" "把远程仓库完整下载到本地"
            ;;
        0|*) return ;;
    esac
    pause
}

# ── 工具箱：Git 操作（主菜单） ──
do_git() {
    while true; do
        clear
        echo ""
        echo "  ${BD}📦 Git 操作中心${NC}"
        line
        echo ""
        git_status_panel

        echo "  ${BD}[1]${NC} 📋 状态 & 改动"
        echo "       ${GR}（查看文件变更、diff、blame）${NC}"
        echo "  ${BD}[2]${NC} ✏️  提交变更"
        echo "       ${GR}（add、commit、amend）${NC}"
        echo "  ${BD}[3]${NC} 🌿 分支管理"
        echo "       ${GR}（创建、切换、合并、删除分支）${NC}"
        echo "  ${BD}[4]${NC} 🔗 远程操作"
        echo "       ${GR}（push、pull、fetch、remote、clone）${NC}"
        echo "  ${BD}[5]${NC} 📦 暂存区 (Stash)"
        echo "       ${GR}（临时保存修改，切分支时很有用）${NC}"
        echo "  ${BD}[6]${NC} ⏪ 撤销 & 恢复"
        echo "       ${GR}（reset、restore、revert）${NC}"
        echo "  ${BD}[7]${NC} 🏷️  标签管理"
        echo "       ${GR}（打版本标记，如 v1.0）${NC}"
        echo "  ${BD}[8]${NC} 📖 查看历史"
        echo "       ${GR}（git log 图形化展示）${NC}"
        echo "  ${BD}[9]${NC} 🔧 初始化 / 克隆"
        echo "       ${GR}（新建仓库或克隆远程仓库）${NC}"
        echo "  ${BD}[0]${NC} 返回"
        echo ""
        echo -n "  选择: "
        read -k1 pick
        echo ""

        case $pick in
            1) do_git_status ;;
            2) do_git_commit ;;
            3) do_git_branch ;;
            4) do_git_remote ;;
            5) do_git_stash ;;
            6) do_git_undo ;;
            7) do_git_tag ;;
            8)
                require_git_repo || { pause; continue; }
                clear
                echo ""
                echo "  ${BD}📖 提交历史${NC}"
                line
                echo ""
                git log --oneline --graph --decorate -20 2>/dev/null
                teach "git log --oneline --graph --decorate" "--graph 画分支线，--decorate 显示标签"
                pause
                ;;
            9) do_git_init ;;
            0|q|*) return ;;
        esac
    done
}

# ── 工具箱：文件权限 ──
do_permission() {
    clear
    echo ""
    echo "  ${BD}🔐 文件权限${NC}"
    line
    echo ""
    echo "  ${BD}[1]${NC} 查看文件详细信息   ${GR}ls -la${NC}"
    echo "  ${BD}[2]${NC} 添加执行权限       ${GR}chmod +x${NC}"
    echo "  ${BD}[3]${NC} 查看谁能读写执行   ${GR}权限解读${NC}"
    echo "  ${BD}[0]${NC} 返回"
    echo ""
    echo -n "  选择: "
    read -k1 pick
    echo ""

    case $pick in
        1)
            echo -n "  ${BD}文件或目录路径${NC}（默认当前目录 .）: "
            read target
            [[ -z "$target" ]] && target="."
            echo ""
            ls -la "$target" 2>/dev/null || echo "  ${R}路径不存在${NC}"
            echo ""
            echo "  ${GR}解读：d=目录 r=读 w=写 x=执行${NC}"
            echo "  ${GR}三组权限：拥有者 / 同组 / 其他人${NC}"
            teach "ls -la" "-l 详细信息，-a 包括隐藏文件"
            ;;
        2)
            echo -n "  ${BD}要加执行权限的文件${NC}: "
            read target
            if [[ -z "$target" ]]; then
                echo "  ${Y}取消${NC}"
            elif [[ ! -e "$target" ]]; then
                echo "  ${R}文件不存在${NC}"
            else
                chmod +x "$target"
                echo "  ${G}✅ 已添加执行权限${NC}"
                ls -la "$target"
            fi
            teach "chmod +x 文件名" "+x 表示添加执行权限，脚本必须有这个才能运行"
            ;;
        3)
            echo -n "  ${BD}文件路径${NC}: "
            read target
            if [[ -z "$target" || ! -e "$target" ]]; then
                echo "  ${R}文件不存在${NC}"; pause; return
            fi
            echo ""
            local perms=$(ls -la "$target" | awk '{print $1}')
            echo "  ${BD}权限字符串: ${C}$perms${NC}"
            echo ""
            echo "  ${GR}位置含义：${NC}"
            echo "  ${C}d${NC}rwxrwxrwx  ← 第1位：d=目录，-=文件，l=链接"
            echo "  d${C}rwx${NC}rwxrwx  ← 2-4位：拥有者权限"
            echo "  drwx${C}rwx${NC}rwx  ← 5-7位：同组权限"
            echo "  drwxrwx${C}rwx${NC}  ← 8-10位：其他人权限"
            echo ""
            echo "  ${GR}r=可读(4)  w=可写(2)  x=可执行(1)${NC}"
            echo "  ${GR}例: rwx = 4+2+1 = 7，rw- = 4+2 = 6${NC}"
            teach "chmod 755 文件名" "7=rwx(拥有者) 5=r-x(同组) 5=r-x(其他人)"
            ;;
        0|*) return ;;
    esac
    pause
}

# ── 工具箱：压缩解压 ──
do_archive() {
    clear
    echo ""
    echo "  ${BD}📦 压缩 / 解压${NC}"
    line
    echo ""
    echo "  ${BD}[1]${NC} 解压文件          ${GR}自动识别格式${NC}"
    echo "  ${BD}[2]${NC} 压缩为 .tar.gz    ${GR}最通用的格式${NC}"
    echo "  ${BD}[3]${NC} 压缩为 .zip       ${GR}跨平台通用${NC}"
    echo "  ${BD}[4]${NC} 查看压缩包内容     ${GR}不解压只看${NC}"
    echo "  ${BD}[0]${NC} 返回"
    echo ""
    echo -n "  选择: "
    read -k1 pick
    echo ""

    case $pick in
        1)
            echo -n "  ${BD}压缩文件路径${NC}: "
            read target
            if [[ -z "$target" || ! -f "$target" ]]; then
                echo "  ${R}文件不存在${NC}"; pause; return
            fi
            echo ""
            case "$target" in
                *.tar.gz|*.tgz)
                    tar -xzf "$target" && echo "  ${G}✅ 解压完成${NC}"
                    teach "tar -xzf 文件名" "x=解压 z=gzip f=指定文件"
                    ;;
                *.tar.bz2)
                    tar -xjf "$target" && echo "  ${G}✅ 解压完成${NC}"
                    teach "tar -xjf 文件名" "j=bzip2 格式"
                    ;;
                *.tar)
                    tar -xf "$target" && echo "  ${G}✅ 解压完成${NC}"
                    teach "tar -xf 文件名" "纯 tar 包，没有压缩"
                    ;;
                *.zip)
                    unzip "$target" && echo "  ${G}✅ 解压完成${NC}"
                    teach "unzip 文件名" "解压 zip 文件"
                    ;;
                *.gz)
                    gunzip "$target" && echo "  ${G}✅ 解压完成${NC}"
                    teach "gunzip 文件名" "解压单个 gzip 文件"
                    ;;
                *)
                    echo "  ${Y}不认识这个格式，试试 tar -xf 或 unzip${NC}"
                    ;;
            esac
            ;;
        2)
            echo -n "  ${BD}要压缩的文件/目录${NC}: "
            read target
            if [[ -z "$target" || ! -e "$target" ]]; then
                echo "  ${R}路径不存在${NC}"; pause; return
            fi
            local outname="${target:t}.tar.gz"
            tar -czf "$outname" "$target" && echo "  ${G}✅ 已压缩为 ${BD}$outname${NC}"
            teach "tar -czf 输出名.tar.gz 源目录" "c=创建 z=gzip压缩 f=指定文件名"
            ;;
        3)
            echo -n "  ${BD}要压缩的文件/目录${NC}: "
            read target
            if [[ -z "$target" || ! -e "$target" ]]; then
                echo "  ${R}路径不存在${NC}"; pause; return
            fi
            local outname="${target:t}.zip"
            if [[ -d "$target" ]]; then
                zip -r "$outname" "$target" && echo "  ${G}✅ 已压缩为 ${BD}$outname${NC}"
            else
                zip "$outname" "$target" && echo "  ${G}✅ 已压缩为 ${BD}$outname${NC}"
            fi
            teach "zip -r 输出名.zip 源目录" "-r 表示递归（压缩整个目录）"
            ;;
        4)
            echo -n "  ${BD}压缩文件路径${NC}: "
            read target
            if [[ -z "$target" || ! -f "$target" ]]; then
                echo "  ${R}文件不存在${NC}"; pause; return
            fi
            echo ""
            case "$target" in
                *.tar.gz|*.tgz) tar -tzf "$target" | head -30; teach "tar -tzf 文件名" "t=列出内容，不解压" ;;
                *.tar.bz2)      tar -tjf "$target" | head -30; teach "tar -tjf 文件名" "t=列出内容" ;;
                *.tar)          tar -tf  "$target" | head -30; teach "tar -tf 文件名" "t=列出内容" ;;
                *.zip)          unzip -l "$target" | head -30; teach "unzip -l 文件名" "-l 只列出不解压" ;;
                *)              echo "  ${Y}不认识这个格式${NC}" ;;
            esac
            ;;
        0|*) return ;;
    esac
    pause
}

# ── 工具箱：项目导航 ──
# 核心：tmux send-keys 直接在当前 pane 执行 cd，一步到位
_jump_to() {
    local target="$1"
    if [[ ! -d "$target" ]]; then
        echo "  ${R}目录不存在${NC}"; pause; return 1
    fi
    echo "  ${G}✅ 跳转到: ${target/#$HOME/~}${NC}"
    teach "z ${target:t}" "z 会自动匹配你常去的目录，不用输完整路径"
    sleep 0.3
    if in_tmux; then
        # 直接在当前 pane 执行 cd，一步到位
        tmux send-keys "cd \"$target\"" Enter
    else
        # 不在 tmux 里，写入临时文件 + 提示 source
        echo "$target" > /tmp/.tm_jump_target
        echo ""
        echo "  ${GR}不在 tmux 里，请手动执行：${NC}"
        echo "  ${C}cd \"$target\"${NC}"
    fi
    return 0
}

do_jump() {
    clear
    echo ""
    echo "  ${BD}🚀 项目导航${NC}"
    line

    if ! command -v zoxide &>/dev/null; then
        echo ""
        echo "  ${R}❌ 还没有安装 zoxide${NC}"
        echo "  ${GR}安装方法: ${C}brew install zoxide${NC}"
        echo "  ${GR}然后在 ~/.zshrc 加: ${C}eval \"\$(zoxide init zsh)\"${NC}"
        teach "brew install zoxide" "zoxide 是更智能的 cd，会记住你常去的目录"
        pause; return
    fi

    echo ""
    echo "  ${GR}你最常去的目录（选中直接跳转）：${NC}"
    echo ""
    local i=1
    local -a dirs
    while IFS= read -r d; do
        dirs[$i]="$d"
        local display="${d/#$HOME/~}"
        local git_mark=""
        [[ -d "$d/.git" ]] && git_mark=" ${C}(git)${NC}"
        printf "  ${BD}[%s]${NC} %s%s\n" "$i" "$display" "$git_mark"
        ((i++))
        [[ $i -gt 9 ]] && break
    done < <(zoxide query -l 2>/dev/null | head -9)

    echo ""
    echo "  ${BD}[s]${NC} 🔍 搜索关键词直接跳转"
    echo "  ${BD}[0]${NC} 返回"
    echo ""
    echo -n "  选择: "
    read -k1 pick
    echo ""

    case $pick in
        [1-9])
            local target="${dirs[$pick]}"
            if [[ -n "$target" ]]; then
                _jump_to "$target"
            else
                echo "  ${Y}没有这个选项${NC}"; pause
            fi
            ;;
        s|S)
            echo ""
            echo -n "  ${BD}输入关键词${NC}: "
            read keyword
            if [[ -z "$keyword" ]]; then
                echo "  ${Y}取消${NC}"; pause; return
            fi
            local best=$(zoxide query "$keyword" 2>/dev/null)
            if [[ -n "$best" && -d "$best" ]]; then
                _jump_to "$best"
            else
                echo "  ${Y}没有找到匹配 \"$keyword\" 的目录${NC}"
                echo ""
                echo "  ${GR}所有包含该关键词的记录：${NC}"
                zoxide query -l "$keyword" 2>/dev/null | head -5 | while read -r d; do
                    echo "  ${d/#$HOME/~}"
                done
                pause
            fi
            ;;
        0|*) return ;;
    esac
}

# ── 功能8：工具箱子菜单 ──
do_toolbox() {
    while true; do
        clear
        echo ""
        echo "  ${BD}🧰 终端工具箱${NC}"
        line
        echo ""
        echo "  ${BD}[1]${NC} 🔌 端口管理"
        echo "       ${GR}（查端口、杀端口、看监听）${NC}"
        echo ""
        echo "  ${BD}[2]${NC} ⚙️  进程管理"
        echo "       ${GR}（找进程、杀进程、看资源占用）${NC}"
        echo ""
        echo "  ${BD}[3]${NC} 🔍 快速搜索"
        echo "       ${GR}（找文件、搜代码内容）${NC}"
        echo ""
        echo "  ${BD}[4]${NC} 🌐 网络诊断"
        echo "       ${GR}（查 IP、测连通、DNS 查询）${NC}"
        echo ""
        echo "  ${BD}[5]${NC} 🚀 项目导航"
        echo "       ${GR}（快速跳转常用目录，搭配 zoxide）${NC}"
        echo ""
        echo "  ${BD}[6]${NC} 📦 Git 操作中心"
        echo "       ${GR}（状态、提交、分支、远程、暂存、撤销、标签）${NC}"
        echo ""
        echo "  ${BD}[7]${NC} 🔐 文件权限"
        echo "       ${GR}（查看权限、加执行权限、权限解读）${NC}"
        echo ""
        echo "  ${BD}[8]${NC} 📦 压缩 / 解压"
        echo "       ${GR}（tar.gz、zip，自动识别格式）${NC}"
        echo ""
        echo "  ${BD}[9]${NC} 📊 系统状态"
        echo "       ${GR}（CPU、内存、磁盘、IP 一览）${NC}"
        echo ""
        echo "  ${BD}[t]${NC} ⏰ 定时任务"
        # 渲染插件注册的菜单项
        for i in {1..${#TM_PLUGIN_TOOLBOX_KEYS[@]}}; do
            echo "  ${BD}[${TM_PLUGIN_TOOLBOX_KEYS[$i]}]${NC} ${TM_PLUGIN_TOOLBOX_LABELS[$i]}"
        done
        echo "  ${BD}[0]${NC} 返回主菜单"
        echo ""
        echo -n "  选择: "
        read -k1 pick
        echo ""

        # 先检查是否是插件注册的快捷键
        local plugin_matched=false
        for i in {1..${#TM_PLUGIN_TOOLBOX_KEYS[@]}}; do
            if [[ "${pick:l}" == "${TM_PLUGIN_TOOLBOX_KEYS[$i]:l}" ]]; then
                ${TM_PLUGIN_TOOLBOX_FUNCS[$i]}
                plugin_matched=true
                break
            fi
        done
        $plugin_matched && continue

        case $pick in
            1) do_port ;;
            2) do_process ;;
            3) do_search ;;
            4) do_network ;;
            5) do_jump ;;
            6) do_git ;;
            7) do_permission ;;
            8) do_archive ;;
            9) do_sys_status ;;
            t|T) do_cron ;;
            0|*) return ;;
        esac
    done
}

# ================================================================
# 主程序入口
# ================================================================

# 检查 tmux 是否安装
if ! command -v tmux &> /dev/null; then
    echo "  ${R}❌ 还没有安装 tmux${NC}"
    echo "  ${GR}请运行: ${C}brew install tmux${NC}"
    exit 1
fi

# 检查插件注册的快捷命令
for i in {1..${#TM_PLUGIN_SHORTCUT_NAMES[@]}}; do
    if [[ "$1" == "${TM_PLUGIN_SHORTCUT_NAMES[$i]}" ]]; then
        ${TM_PLUGIN_SHORTCUT_FUNCS[$i]}
        exit 0
    fi
done

# 快捷参数（给熟练后用的）
case "$1" in
    plugin)
        local PLUGIN_REPO="https://raw.githubusercontent.com/PhilRobinluo/terminal-mentor/master/plugins/official"
        mkdir -p "$TM_PLUGIN_DIR"
        case "$2" in
            list|ls|"")
                echo ""
                echo "  ${BD}📦 tm 插件管理${NC}"
                echo ""
                echo "  ${BD}已安装的插件：${NC}"
                local installed=0
                for f in "$TM_PLUGIN_DIR"/*.sh(N); do
                    local name=$(basename "$f" .sh)
                    local desc=$(grep '^# 描述:' "$f" 2>/dev/null | head -1 | sed 's/^# 描述: //')
                    echo "  ${G}✓${NC} ${BD}$name${NC}  ${GR}$desc${NC}"
                    installed=$((installed + 1))
                done
                [[ $installed -eq 0 ]] && echo "  ${GR}（还没装任何插件）${NC}"
                echo ""
                echo "  ${BD}可安装的官方插件：${NC}"
                echo "  ${C}docker${NC}     Docker 容器管理导航菜单"
                echo "  ${C}npm${NC}        npm/pnpm 包管理导航菜单"
                echo "  ${C}ssh${NC}        SSH 连接管理导航菜单"
                echo "  ${C}python${NC}     Python 虚拟环境导航菜单"
                echo "  ${C}brew${NC}       Homebrew 包管理导航菜单"
                echo ""
                echo "  ${BD}安装：${NC}${C}tm plugin install <名字>${NC}"
                echo "  ${BD}卸载：${NC}${C}tm plugin remove <名字>${NC}"
                echo ""
                ;;
            install|add)
                if [[ -z "$3" ]]; then
                    echo "  ${Y}用法: tm plugin install <插件名>${NC}"
                    echo "  ${GR}运行 tm plugin list 查看可用插件${NC}"
                    exit 1
                fi
                local name="$3"
                if [[ -f "$TM_PLUGIN_DIR/$name.sh" ]]; then
                    echo "  ${Y}⚠️  $name 已安装${NC}"
                    exit 0
                fi
                echo "  ${C}→ 下载插件: $name...${NC}"
                local tmp=$(mktemp)
                curl -sL "$PLUGIN_REPO/$name.sh" -o "$tmp"
                if [[ -s "$tmp" ]] && head -1 "$tmp" | grep -q '#!/bin/zsh'; then
                    mv "$tmp" "$TM_PLUGIN_DIR/$name.sh"
                    chmod +x "$TM_PLUGIN_DIR/$name.sh"
                    echo "  ${G}✅ $name 安装成功！${NC}"
                    echo "  ${GR}重新运行 tm 即可使用${NC}"
                else
                    echo "  ${R}❌ 插件 $name 不存在或下载失败${NC}"
                    echo "  ${GR}运行 tm plugin list 查看可用插件${NC}"
                    rm -f "$tmp"
                fi
                ;;
            remove|rm|uninstall)
                if [[ -z "$3" ]]; then
                    echo "  ${Y}用法: tm plugin remove <插件名>${NC}"
                    exit 1
                fi
                local name="$3"
                if [[ -f "$TM_PLUGIN_DIR/$name.sh" ]]; then
                    rm "$TM_PLUGIN_DIR/$name.sh"
                    echo "  ${G}✅ $name 已卸载${NC}"
                else
                    echo "  ${Y}$name 未安装${NC}"
                fi
                ;;
            *)
                echo "  ${Y}用法: tm plugin [list|install|remove] <名字>${NC}"
                ;;
        esac
        exit 0
        ;;
    -v|--version|version)
        echo "tm version $VERSION"
        exit 0
        ;;
    update)
        echo ""
        echo "  ${BD}🔄 检查更新...${NC}"
        local latest=$(curl -sL --connect-timeout 5 "https://raw.githubusercontent.com/PhilRobinluo/terminal-mentor/master/tm" | grep '^VERSION=' | head -1 | cut -d'"' -f2)
        if [[ -z "$latest" ]]; then
            echo "  ${R}❌ 无法连接到 GitHub${NC}"
            exit 1
        fi
        if [[ "$latest" == "$VERSION" ]]; then
            echo "  ${G}✅ 已是最新版本 ($VERSION)${NC}"
        else
            echo "  ${Y}发现新版本: $latest (当前: $VERSION)${NC}"
            echo -n "  是否更新？(y/N): "
            read answer
            if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
                local tmp=$(mktemp)
                curl -sL "https://raw.githubusercontent.com/PhilRobinluo/terminal-mentor/master/tm" -o "$tmp"
                if [[ -s "$tmp" ]]; then
                    cp "$0" "$0.backup"
                    mv "$tmp" "$0"
                    chmod +x "$0"
                    echo "  ${G}✅ 更新完成！旧版本已备份为 $(basename $0).backup${NC}"
                    echo "  ${GR}请重新运行 tm 使用新版本${NC}"
                else
                    echo "  ${R}❌ 下载失败${NC}"
                    rm -f "$tmp"
                fi
            else
                echo "  ${GR}已取消${NC}"
            fi
        fi
        echo ""
        exit 0
        ;;
    -h|--help|help)
        echo ""
        echo "  ${BD}tm — Terminal Mentor${NC}"
        echo "  ${GR}终端操作教练，一个工具搞定所有命令行操作${NC}"
        echo ""
        echo "  ${BD}tmux 管理：${NC}"
        echo "  ${C}tm${NC}            打开交互菜单"
        echo "  ${C}tm a${NC}          秒回最近的会话"
        echo "  ${C}tm new${NC}        快速新建会话"
        echo "  ${C}tm new work${NC}   新建并命名为 work"
        echo "  ${C}tm d${NC}          快速脱离当前会话"
        echo "  ${C}tm ls${NC}         列出所有会话"
        echo "  ${C}tm keys${NC}       快捷键速查"
        echo ""
        echo "  ${BD}工具箱：${NC}"
        echo "  ${C}tm port 3000${NC}  查看端口 3000 被谁占用"
        echo "  ${C}tm kill-port 3000${NC} 释放端口 3000"
        echo "  ${C}tm ps node${NC}    查找 node 相关进程"
        echo "  ${C}tm find *.js${NC}  搜索文件"
        echo "  ${C}tm grep TODO${NC}  在代码中搜索内容"
        echo "  ${C}tm ip${NC}         查看内网/公网 IP"
        echo "  ${C}tm sys${NC}        系统状态一览"
        echo "  ${C}tm j${NC}          项目导航（选中直接跳转）"
        echo "  ${C}tm j code${NC}     直接跳到匹配 code 的目录"
        echo "  ${C}tm git${NC}        Git 操作中心（完整菜单）"
        echo "  ${C}tm gs${NC}         git status 快捷查看"
        echo "  ${C}tm gl${NC}         git log 图形历史"
        echo "  ${C}tm ga${NC}         git add + commit 一步完成"
        echo "  ${C}tm gd${NC}         git diff 改动摘要"
        echo "  ${C}tm gb${NC}         git branch 查看分支"
        echo "  ${C}tm gp${NC}         git push 智能推送"
        echo "  ${C}tm gpl${NC}        git pull 拉取更新"
        echo "  ${C}tm gco <分支>${NC}  切换分支"
        echo "  ${C}tm gcb <名字>${NC}  创建并切换新分支"
        echo "  ${C}tm gm <分支>${NC}   合并分支到当前"
        echo "  ${C}tm gc <地址>${NC}   克隆远程仓库"
        echo "  ${C}tm gst [备注]${NC}  暂存修改 (stash)"
        echo "  ${C}tm gstp${NC}       恢复暂存 (stash pop)"
        echo "  ${C}tm glog${NC}       图形化全分支历史"
        echo "  ${C}tm tools${NC}      打开工具箱菜单"
        echo ""
        echo "  ${BD}其他：${NC}"
        echo "  ${C}tm startup${NC}    启动信息面板"
        echo "  ${C}tm cron${NC}       定时任务一览"
        echo "  ${BD}插件管理：${NC}"
        echo "  ${C}tm plugin${NC}            查看已装/可装插件"
        echo "  ${C}tm plugin install X${NC}  安装插件"
        echo "  ${C}tm plugin remove X${NC}   卸载插件"
        echo ""
        echo "  ${BD}其他：${NC}"
        echo "  ${C}tm update${NC}     检查并更新到最新版本"
        echo "  ${C}tm --version${NC}  显示版本号"
        echo "  ${C}tm help${NC}       显示此帮助"
        echo ""
        exit 0
        ;;
    startup) do_startup; exit 0 ;;
    new)
        # tm new <name> 支持直接带名字
        if [[ -n "$2" ]]; then
            local name=$(echo "$2" | tr -cd 'a-zA-Z0-9_-')
            if [[ -z "$name" ]]; then
                echo "  ${R}⚠️  名字格式不对，只能用字母数字下划线短横线${NC}"
                exit 1
            fi
            if tmux has-session -t "$name" 2>/dev/null; then
                echo "  ${Y}⚠️  '$name' 已经存在，直接进入...${NC}"
                if in_tmux; then
                    tmux switch-client -t "$name"
                else
                    tmux attach -t "$name"
                fi
            else
                if in_tmux; then
                    tmux new-session -d -s "$name"
                    echo "  ${G}✅ 已创建 ${BD}$name${NC}"
                    tmux switch-client -t "$name"
                else
                    tmux new-session -s "$name"
                fi
            fi
            teach "tmux new-session -s $name" "以后可以直接用这条命令"
            exit 0
        fi
        do_new
        exit 0
        ;;
    d|detach)
        if in_tmux; then
            teach "Ctrl+B 然后按 d" "记住这个快捷键，比 tm d 还快"
            echo "  ${G}✅ 已脱离，工作空间在后台继续运行${NC}"
            tmux detach
        else
            echo "  ${Y}你现在不在 tmux 里，不需要脱离${NC}"
        fi
        exit 0
        ;;
    ls|list) do_list; exit 0 ;;
    a|attach)
        # tm a 秒回最近会话，不弹菜单
        local count=$(session_count)
        if [[ "$count" -eq 0 ]]; then
            echo "  ${Y}没有会话在运行，帮你创建一个...${NC}"
            sleep 1
            tmux new-session
        elif in_tmux; then
            echo "  ${GR}你已经在 tmux 里了，用 Ctrl+B → s 切换会话${NC}"
        else
            teach "tmux attach" "直接接入最近的会话"
            tmux attach
        fi
        exit 0
        ;;
    sync)
        echo ""
        echo "  ${BD}🔄 同步 session 名称${NC}"
        echo ""
        local synced=0
        tmux list-sessions -F '#{session_name}' 2>/dev/null | while read -r sess; do
            local pt=$(tmux display-message -t "$sess" -p '#{pane_title}' 2>/dev/null)
            [ -z "$pt" ] && continue
            local cl=$(echo "$pt" | sed 's/^[✳⠂⠄⠇⠋⠙⠸⠴⠦⠖] //')
            [ -z "$cl" ] && continue
            local san=$(echo "$cl" | tr '.:"\\' '----' | cut -c1-40)
            [ -z "$san" ] && continue
            [ "$san" = "$sess" ] && continue
            if tmux has-session -t "=$san" 2>/dev/null; then
                echo "  ${Y}⚠️  跳过 $sess（'$san' 已被占用）${NC}"
                continue
            fi
            tmux rename-session -t "$sess" "$san" 2>/dev/null && echo "  ${G}✅ $sess → $san${NC}"
        done
        echo ""
        echo "  ${GR}完成。以后 /rename 会自动同步，不需要手动跑。${NC}"
        exit 0
        ;;
    limit)
        local limit_file="$HOME/.config/tm/session-limit"
        if [[ -n "$2" ]]; then
            # 设置上限
            if [[ "$2" =~ ^[0-9]+$ ]] && [[ "$2" -ge 1 ]]; then
                mkdir -p "$(dirname "$limit_file")"
                echo "$2" > "$limit_file"
                echo "  ${G}✅ 窗口上限已设为 ${BD}$2${G} 个${NC}"
                local current=$(tmux list-sessions 2>/dev/null | wc -l | tr -d ' ')
                if [[ "$current" -gt "$2" ]]; then
                    echo "  ${Y}⚠️  当前有 ${current} 个，超了 $((current - $2)) 个${NC}"
                fi
            else
                echo "  ${R}⚠️  请输入一个正整数，比如：tm limit 5${NC}"
            fi
        else
            # 查看上限
            local limit=8
            [[ -f "$limit_file" ]] && limit=$(cat "$limit_file")
            local current=$(tmux list-sessions 2>/dev/null | wc -l | tr -d ' ')
            echo "  ${BD}窗口上限：${G}${limit}${NC}  ${GR}当前：${current}${NC}"
        fi
        exit 0
        ;;
    keys)    do_learn; exit 0 ;;
    cron|timer)    do_cron; exit 0 ;;
    status|sys)    do_sys_status; exit 0 ;;
    tools|toolbox) do_toolbox; exit 0 ;;
    j|jump)
        if [[ -n "$2" ]]; then
            # tm j 关键词 → 直接跳转，不进菜单
            if ! command -v zoxide &>/dev/null; then
                echo "  ${R}❌ 需要先安装 zoxide: brew install zoxide${NC}"; exit 1
            fi
            local best=$(zoxide query "$2" 2>/dev/null)
            if [[ -n "$best" && -d "$best" ]]; then
                echo "  ${G}✅ → ${best/#$HOME/~}${NC}"
                teach "z $2" "z 会自动匹配你常去的目录"
                if in_tmux; then
                    tmux send-keys "cd \"$best\"" Enter
                else
                    echo "  ${C}cd \"$best\"${NC}"
                fi
            else
                echo "  ${Y}没有找到匹配 \"$2\" 的目录${NC}"
                zoxide query -l "$2" 2>/dev/null | head -5 | while read -r d; do
                    echo "  ${d/#$HOME/~}"
                done
            fi
            exit 0
        fi
        do_jump; exit 0
        ;;
    git)  do_git; exit 0 ;;
    gs)
        echo ""
        git status 2>/dev/null || echo "  ${R}不在 Git 仓库里${NC}"
        teach "git status" "查看哪些文件被修改、哪些未跟踪"
        exit 0
        ;;
    gl)
        echo ""
        git log --oneline --graph --decorate -15 2>/dev/null || echo "  ${R}不在 Git 仓库里${NC}"
        teach "git log --oneline --graph --decorate -15" "--graph 画分支线，--decorate 显示标签"
        exit 0
        ;;
    ga)
        # tm ga — 快速 add + commit
        if ! git rev-parse --is-inside-work-tree &>/dev/null; then
            echo "  ${R}不在 Git 仓库里${NC}"; exit 1
        fi
        local changes=$(git status --porcelain 2>/dev/null)
        if [[ -z "$changes" ]]; then
            echo "  ${G}✅ 没有需要提交的变更${NC}"; exit 0
        fi
        echo ""
        echo "  ${GR}变更文件：${NC}"
        git status --short
        echo ""
        echo -n "  ${BD}提交说明${NC}: "
        read msg
        if [[ -z "$msg" ]]; then
            echo "  ${Y}取消（没有输入说明）${NC}"
        else
            git add -A && git commit -m "$msg"
            echo "  ${G}✅ 已提交${NC}"
        fi
        teach "git add -A && git commit -m \"说明\"" "add + commit 一步完成"
        exit 0
        ;;
    gd)
        # tm gd — 快速 diff
        echo ""
        git diff --stat 2>/dev/null || echo "  ${R}不在 Git 仓库里${NC}"
        teach "git diff --stat" "查看改动摘要，完整版: git diff"
        exit 0
        ;;
    gb)
        # tm gb — 快速看分支
        echo ""
        git branch -a 2>/dev/null || echo "  ${R}不在 Git 仓库里${NC}"
        teach "git branch -a" "-a 显示所有分支（包括远程的）"
        exit 0
        ;;
    gp)
        # tm gp — 智能推送
        if ! git rev-parse --is-inside-work-tree &>/dev/null; then
            echo "  ${R}不在 Git 仓库里${NC}"; exit 1
        fi
        echo ""
        local branch=$(git branch --show-current 2>/dev/null)
        if git rev-parse --verify --quiet @{upstream} &>/dev/null; then
            git push 2>&1
            [[ $? -eq 0 ]] && echo "  ${G}✅ 推送完成${NC}" || echo "  ${R}推送失败${NC}"
            teach "git push" "推送到远程仓库"
        else
            echo "  ${Y}新分支，自动设置上游追踪...${NC}"
            git push -u origin "$branch" 2>&1
            [[ $? -eq 0 ]] && echo "  ${G}✅ 推送完成，已设置追踪${NC}" || echo "  ${R}推送失败${NC}"
            teach "git push -u origin $branch" "-u 设置上游，以后直接 git push"
        fi
        exit 0
        ;;
    gpl)
        # tm gpl — 快速拉取
        echo ""
        git pull 2>&1 && echo "  ${G}✅ 拉取完成${NC}" || echo "  ${R}拉取失败${NC}"
        teach "git pull" "从远程拉取最新代码并合并"
        exit 0
        ;;
    gco)
        # tm gco <branch> — 快速切换分支
        if ! git rev-parse --is-inside-work-tree &>/dev/null; then
            echo "  ${R}不在 Git 仓库里${NC}"; exit 1
        fi
        if [[ -z "$2" ]]; then
            echo ""
            echo "  ${GR}可用分支：${NC}"
            git branch --list 2>/dev/null
            echo ""
            echo "  ${GR}用法: ${C}tm gco 分支名${NC}"
        else
            git switch "$2" 2>/dev/null || git checkout "$2" 2>/dev/null
            [[ $? -eq 0 ]] && echo "  ${G}✅ 已切换到 ${BD}$2${NC}" || echo "  ${R}切换失败${NC}"
        fi
        teach "git switch 分支名" "专门用来切分支，比 checkout 更安全"
        exit 0
        ;;
    gcb)
        # tm gcb <name> — 快速创建并切换分支
        if ! git rev-parse --is-inside-work-tree &>/dev/null; then
            echo "  ${R}不在 Git 仓库里${NC}"; exit 1
        fi
        if [[ -z "$2" ]]; then
            echo "  ${Y}用法: ${C}tm gcb 新分支名${NC}"; exit 1
        fi
        local bname=$(echo "$2" | tr -cd 'a-zA-Z0-9_-/')
        git checkout -b "$bname"
        echo "  ${G}✅ 已创建并切换到 ${BD}$bname${NC}"
        teach "git checkout -b $bname" "-b 创建新分支并自动切过去"
        exit 0
        ;;
    gm)
        # tm gm <branch> — 快速合并
        if ! git rev-parse --is-inside-work-tree &>/dev/null; then
            echo "  ${R}不在 Git 仓库里${NC}"; exit 1
        fi
        if [[ -z "$2" ]]; then
            echo "  ${Y}用法: ${C}tm gm 要合并的分支名${NC}"; exit 1
        fi
        local current=$(git branch --show-current 2>/dev/null)
        echo "  ${GR}合并 ${C}$2${GR} → ${C}$current${NC}"
        git merge "$2"
        if [[ $? -eq 0 ]]; then
            echo "  ${G}✅ 合并完成${NC}"
        else
            echo "  ${Y}⚠️  有冲突，需手动解决${NC}"
            echo "  ${GR}解决后: ${C}git add . && git commit${NC}"
            echo "  ${GR}放弃: ${C}git merge --abort${NC}"
        fi
        teach "git merge 分支名" "把指定分支合并到当前分支"
        exit 0
        ;;
    gc)
        # tm gc <url> — 快速克隆
        if [[ -z "$2" ]]; then
            echo "  ${Y}用法: ${C}tm gc 仓库地址 [目标文件夹]${NC}"; exit 1
        fi
        echo ""
        echo "  ${GR}正在克隆...${NC}"
        if [[ -n "$3" ]]; then
            git clone "$2" "$3" 2>&1
        else
            git clone "$2" 2>&1
        fi
        [[ $? -eq 0 ]] && echo "  ${G}✅ 克隆完成${NC}" || echo "  ${R}克隆失败${NC}"
        teach "git clone 地址 [文件夹名]" "完整下载远程仓库到本地"
        exit 0
        ;;
    gst)
        # tm gst — 快速 stash
        if ! git rev-parse --is-inside-work-tree &>/dev/null; then
            echo "  ${R}不在 Git 仓库里${NC}"; exit 1
        fi
        local changes=$(git status --porcelain 2>/dev/null)
        if [[ -z "$changes" ]]; then
            echo "  ${G}没有需要保存的修改${NC}"; exit 0
        fi
        if [[ -n "$2" ]]; then
            git stash push -m "$2"
        else
            git stash
        fi
        echo "  ${G}✅ 修改已暂存${NC}"
        teach "git stash push -m \"备注\"" "临时保存修改，加 -m 写备注"
        exit 0
        ;;
    gstp)
        # tm gstp — 快速 stash pop
        if ! git rev-parse --is-inside-work-tree &>/dev/null; then
            echo "  ${R}不在 Git 仓库里${NC}"; exit 1
        fi
        local sc=$(git stash list 2>/dev/null | wc -l | tr -d ' ')
        if [[ "$sc" -eq 0 ]]; then
            echo "  ${Y}暂存区是空的${NC}"; exit 0
        fi
        git stash pop
        [[ $? -eq 0 ]] && echo "  ${G}✅ 已恢复暂存的修改${NC}" || echo "  ${R}恢复失败，可能有冲突${NC}"
        teach "git stash pop" "取出最近暂存的修改"
        exit 0
        ;;
    glog)
        # tm glog — 图形化日志
        echo ""
        git log --oneline --graph --decorate --all -25 2>/dev/null || echo "  ${R}不在 Git 仓库里${NC}"
        teach "git log --oneline --graph --all" "--all 显示所有分支，--graph 画线"
        exit 0
        ;;
    port)
        if [[ -z "$2" ]]; then
            do_port; exit 0
        fi
        local p=$(echo "$2" | tr -cd '0-9')
        echo ""
        local result=$(lsof -i :$p 2>/dev/null | grep LISTEN)
        if [[ -n "$result" ]]; then
            echo "  ${G}端口 $p 被占用：${NC}"
            echo "$result" | while read line; do echo "  $line"; done
        else
            echo "  ${G}✅ 端口 $p 没有被占用${NC}"
        fi
        teach "lsof -i :$p" "lsof = list open files，-i 表示网络连接"
        exit 0
        ;;
    kill-port)
        if [[ -z "$2" ]]; then
            echo "  ${Y}用法: tm kill-port 3000${NC}"; exit 1
        fi
        local p=$(echo "$2" | tr -cd '0-9')
        local pids=$(lsof -ti :$p 2>/dev/null)
        if [[ -z "$pids" ]]; then
            echo "  ${G}✅ 端口 $p 没有被占用${NC}"
        else
            echo "$pids" | xargs kill -9 2>/dev/null
            echo "  ${G}✅ 端口 $p 已释放（PID: $pids）${NC}"
        fi
        teach "lsof -ti :$p | xargs kill -9" "-t 只输出 PID，xargs 传给 kill"
        exit 0
        ;;
    ps)
        if [[ -z "$2" ]]; then
            do_process; exit 0
        fi
        echo ""
        local result=$(ps aux | grep -i "$2" | grep -v "grep" | grep -v "tm ps")
        if [[ -n "$result" ]]; then
            echo "  ${G}包含 \"$2\" 的进程：${NC}"
            echo ""
            echo "$result" | awk '{printf "  PID=%-6s CPU=%-5s MEM=%-5s %s\n", $2, $3, $4, $11}' | head -15
        else
            echo "  ${GR}没有找到包含 \"$2\" 的进程${NC}"
        fi
        teach "ps aux | grep $2" "ps aux 列出所有进程，grep 按名字过滤"
        exit 0
        ;;
    find)
        if [[ -z "$2" ]]; then
            do_search; exit 0
        fi
        echo ""
        echo "  ${GR}搜索文件: $2${NC}"
        echo ""
        find . -name "$2" -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | head -20
        echo ""
        teach "find . -name \"$2\"" "从当前目录递归搜索文件"
        exit 0
        ;;
    grep)
        if [[ -z "$2" ]]; then
            do_search; exit 0
        fi
        echo ""
        echo "  ${GR}搜索内容: $2${NC}"
        echo ""
        grep -rn --exclude-dir={node_modules,.git,dist,.next} "$2" . 2>/dev/null | head -20
        echo ""
        teach "grep -rn \"$2\" ." "-r 递归搜索，-n 显示行号"
        exit 0
        ;;
    ip)
        echo ""
        local lip=$(ifconfig en0 2>/dev/null | grep "inet " | awk '{print $2}')
        echo "  🏠 内网: ${G}${lip:-未连接}${NC}"
        local pip=$(curl -s --connect-timeout 3 ifconfig.me 2>/dev/null)
        echo "  🌍 公网: ${G}${pip:-获取失败}${NC}"
        teach "curl ifconfig.me" "一条命令查公网 IP"
        exit 0
        ;;
esac

# 首次使用引导
first_time_check

# 主循环
while true; do
    main_menu
    echo -n "  输入数字选择: "
    read -k1 choice
    echo ""

    case $choice in
        0) do_jump ;;
        1) do_new ;;
        2) do_attach ;;
        3) do_list ;;
        4) do_detach ;;
        5) do_new_window ;;
        6) do_kill ;;
        7) do_learn ;;
        8) do_toolbox ;;
        q|Q)
            echo ""
            echo "  ${G}👋 下次见！记住，直接输入 ${C}tm${G} 就能回来${NC}"
            echo ""
            break
            ;;
        *)
            echo "  ${Y}输入对应数字或 q 退出${NC}"
            sleep 1
            ;;
    esac
done
