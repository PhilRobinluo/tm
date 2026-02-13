#!/bin/zsh
# ================================================================
# tm - tmux 超简单管理工具 🎮
# ================================================================
# 专为零基础用户设计，全程选择题操作，不用记任何命令
# 安装：mv tm.sh ~/.local/bin/tm && chmod +x ~/.local/bin/tm
# 使用：终端输入 tm 回车即可
# ================================================================

# ── 颜色 ──
G='\033[0;32m'    # 绿色-成功
Y='\033[1;33m'    # 黄色-提醒
B='\033[0;34m'    # 蓝色
C='\033[0;36m'    # 青色-命令
R='\033[0;31m'    # 红色-警告
GR='\033[0;90m'   # 灰色-注释
BD='\033[1m'      # 加粗
NC='\033[0m'      # 恢复

# ── 工具函数 ──

# 教学提示：每次操作都告诉你"如果不用菜单，原本该输什么"
teach() {
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
    echo "  ${BD}${G}🎮 tmux 管理菜单${NC}"
    show_status
    line
    echo ""

    local count=$(session_count)

    echo "  你想做什么？"
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
    echo "  ${BD}[0]${NC} 👋 退出菜单"
    echo ""
    line
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

    echo ""
    if [[ -z "$name" ]]; then
        if in_tmux; then
            teach "tmux new-session -d" "新建一个会话并在后台运行"
            tmux new-session -d
            local new_name=$(tmux list-sessions | tail -1 | cut -d: -f1)
            echo "  ${G}✅ 新工作空间已创建！名字是: ${BD}$new_name${NC}"
            echo ""
            echo "  你想现在就切换过去吗？"
            echo ""
            echo "  ${BD}[y]${NC} 是的，切过去"
            echo "  ${BD}[n]${NC} 先不用，待在这里"
            echo ""
            echo -n "  选择: "
            read -k1 go
            echo ""
            if [[ "$go" == "y" ]]; then
                tmux switch-client -t "$new_name"
                return
            fi
        else
            teach "tmux new-session" "创建并进入一个新会话"
            echo "  ${G}✅ 正在进入新的工作空间...${NC}"
            sleep 1
            tmux new-session
        fi
    else
        # 检查名字是否已存在
        if tmux has-session -t "$name" 2>/dev/null; then
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

        if in_tmux; then
            teach "tmux new-session -d -s $name" "-s 是指定名字，-d 是后台创建"
            tmux new-session -d -s "$name"
            echo "  ${G}✅ 工作空间 ${BD}$name${G} 已创建！${NC}"
            echo ""
            echo "  你想现在就切换过去吗？"
            echo ""
            echo "  ${BD}[y]${NC} 是的，切过去"
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
            teach "tmux new-session -s $name" "-s 就是 session（会话）的意思"
            echo "  ${G}✅ 正在进入工作空间 ${BD}$name${G}...${NC}"
            sleep 1
            tmux new-session -s "$name"
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

    local i=1
    echo "$sessions" | while IFS= read -r s; do
        local name=$(echo "$s" | cut -d: -f1)
        local windows=$(echo "$s" | grep -o '[0-9]* windows' || echo "$s" | grep -o '[0-9]* window')
        local attached=""
        if echo "$s" | grep -q "(attached)"; then
            attached=" ${G}← 当前在这里${NC}"
        fi
        echo "  ${BD}[$i]${NC} 📂 ${BD}$name${NC}  ${GR}($windows)${NC}$attached"
        i=$((i + 1))
    done

    echo ""
    echo "  ${BD}[0]${NC} 返回主菜单"
    echo ""
    echo -n "  选择编号: "
    read choice

    if [[ "$choice" == "0" ]] || [[ -z "$choice" ]]; then
        return
    fi

    local target=$(tmux list-sessions | sed -n "${choice}p" | cut -d: -f1)
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
    echo "  ${C}tm ls${NC} 查看全部        ${C}tm${NC}     打开管理菜单"
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

# ================================================================
# 主程序入口
# ================================================================

# 检查 tmux 是否安装
if ! command -v tmux &> /dev/null; then
    echo "  ${R}❌ 还没有安装 tmux${NC}"
    echo "  ${GR}请运行: ${C}brew install tmux${NC}"
    exit 1
fi

# 快捷参数（给熟练后用的）
case "$1" in
    -h|--help|help)
        echo ""
        echo "  ${BD}tm - tmux 管理工具${NC}"
        echo ""
        echo "  ${C}tm${NC}            打开交互菜单"
        echo "  ${C}tm a${NC}          秒回最近的会话"
        echo "  ${C}tm new${NC}        快速新建会话"
        echo "  ${C}tm new work${NC}   新建并命名为 work"
        echo "  ${C}tm d${NC}          快速脱离当前会话"
        echo "  ${C}tm ls${NC}         列出所有会话"
        echo "  ${C}tm keys${NC}       快捷键速查"
        echo "  ${C}tm startup${NC}    启动信息面板"
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
    keys)    do_learn; exit 0 ;;
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
        1) do_new ;;
        2) do_attach ;;
        3) do_list ;;
        4) do_detach ;;
        5) do_new_window ;;
        6) do_kill ;;
        7) do_learn ;;
        0|q)
            echo ""
            echo "  ${G}👋 下次见！记住，直接输入 ${C}tm${G} 就能回来${NC}"
            echo ""
            break
            ;;
        *)
            echo "  ${Y}输入 0-7 的数字就行哦${NC}"
            sleep 1
            ;;
    esac
done
