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
    echo "  ${BD}${G}🎮 Terminal Mentor${NC}"
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
    echo "  ${BD}[8]${NC} 🧰 终端工具箱"
    echo "       ${GR}（端口、进程、搜索、网络、系统状态...）${NC}"
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

# ── 功能8：工具箱 ──

# 端口管理
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
            if [[ "$(uname)" == "Darwin" ]]; then
                lsof -iTCP -sTCP:LISTEN -P -n 2>/dev/null | awk 'NR==1 || /LISTEN/' | head -20
            else
                ss -tlnp 2>/dev/null | head -20
            fi
            echo ""
            if [[ "$(uname)" == "Darwin" ]]; then
                teach "lsof -iTCP -sTCP:LISTEN -P -n" "-P 显示端口号，-n 不解析主机名"
            else
                teach "ss -tlnp" "-t TCP, -l 监听, -n 数字, -p 进程"
            fi
            ;;
        0|*) return ;;
    esac
    pause
}

# 进程管理
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
            ps aux --sort=-%cpu 2>/dev/null | head -11 || ps aux | sort -nrk 3 | head -10
            echo ""
            teach "ps aux --sort=-%cpu | head -10" "按 CPU 使用率倒序排列"
            ;;
        0|*) return ;;
    esac
    pause
}

# 快速搜索
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

# 网络诊断
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
            if [[ "$(uname)" == "Darwin" ]]; then
                local lip=$(ifconfig en0 2>/dev/null | grep "inet " | awk '{print $2}')
                echo "    ${G}${lip:-未连接}${NC} (en0/Wi-Fi)"
            else
                local lip=$(hostname -I 2>/dev/null | awk '{print $1}')
                echo "    ${G}${lip:-未连接}${NC}"
            fi
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
            echo "  ${GR}正在 ping $addr ...（按 Ctrl+C 停止）${NC}"
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

# 系统状态
do_sys_status() {
    clear
    echo ""
    echo "  ${BD}📊 系统状态${NC}"
    line
    echo ""

    # OS
    if [[ "$(uname)" == "Darwin" ]]; then
        local os_ver=$(sw_vers -productVersion 2>/dev/null)
        echo "  🖥️  系统: ${BD}macOS $os_ver${NC}"
    else
        local os_ver=$(cat /etc/os-release 2>/dev/null | grep PRETTY_NAME | cut -d'"' -f2)
        echo "  🖥️  系统: ${BD}${os_ver:-Linux}${NC}"
    fi

    # CPU
    if [[ "$(uname)" == "Darwin" ]]; then
        local cpu_brand=$(sysctl -n machdep.cpu.brand_string 2>/dev/null | sed 's/(R)//g; s/(TM)//g')
        local cpu_cores=$(sysctl -n hw.ncpu 2>/dev/null)
    else
        local cpu_brand=$(grep "model name" /proc/cpuinfo 2>/dev/null | head -1 | cut -d':' -f2 | xargs)
        local cpu_cores=$(nproc 2>/dev/null)
    fi
    echo "  💻 CPU:  ${BD}${cpu_cores:-?} 核${NC} ${GR}(${cpu_brand:-未知})${NC}"

    # Memory
    if [[ "$(uname)" == "Darwin" ]]; then
        local mem_total=$(($(sysctl -n hw.memsize 2>/dev/null) / 1073741824))
        local top_out=$(top -l 1 -n 0 2>/dev/null)
        local mem_used=$(echo "$top_out" | grep "PhysMem" | awk '{print $2}')
        echo "  🧠 内存: ${BD}${mem_used:-?} / ${mem_total}G${NC}"
    else
        local mem_info=$(free -h 2>/dev/null | grep Mem)
        local mem_used=$(echo "$mem_info" | awk '{print $3}')
        local mem_total=$(echo "$mem_info" | awk '{print $2}')
        echo "  🧠 内存: ${BD}${mem_used:-?} / ${mem_total:-?}${NC}"
    fi

    # Disk
    local disk_info=$(df -h / 2>/dev/null | tail -1)
    local disk_used=$(echo "$disk_info" | awk '{print $3}')
    local disk_total=$(echo "$disk_info" | awk '{print $2}')
    local disk_pct=$(echo "$disk_info" | awk '{print $5}')
    echo "  💾 磁盘: ${BD}${disk_used} / ${disk_total}${NC} (${disk_pct})"

    # IP
    if [[ "$(uname)" == "Darwin" ]]; then
        local ip=$(ifconfig en0 2>/dev/null | grep "inet " | awk '{print $2}')
    else
        local ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    fi
    echo "  🌐 IP:   ${BD}${ip:-未连接}${NC}"

    # Uptime
    if [[ "$(uname)" == "Darwin" ]]; then
        local boot_sec=$(sysctl -n kern.boottime 2>/dev/null | sed 's/.*sec = //;s/,.*//')
        local now=$(date +%s)
        if [[ -n "$boot_sec" ]] && [[ "$boot_sec" =~ ^[0-9]+$ ]]; then
            local up_sec=$((now - boot_sec))
            local up_days=$((up_sec / 86400))
            local up_hours=$(( (up_sec % 86400) / 3600 ))
            echo "  ⏱️  运行: ${BD}${up_days}天 ${up_hours}小时${NC}"
        fi
    else
        local up=$(uptime -p 2>/dev/null)
        echo "  ⏱️  运行: ${BD}${up:-$(uptime | awk -F'up ' '{print $2}' | awk -F',' '{print $1}')}${NC}"
    fi

    echo ""
    teach "top -l 1 | head -10  # macOS\nhtop  # 推荐安装" "top 查看实时系统状态，htop 是更好用的替代"
    pause
}

# 工具箱子菜单
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
        echo "  ${BD}[5]${NC} 📊 系统状态"
        echo "       ${GR}（CPU、内存、磁盘、IP 一览）${NC}"
        echo ""
        echo "  ${BD}[0]${NC} 返回主菜单"
        echo ""
        echo -n "  选择: "
        read -k1 pick
        echo ""

        case $pick in
            1) do_port ;;
            2) do_process ;;
            3) do_search ;;
            4) do_network ;;
            5) do_sys_status ;;
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

# 快捷参数（给熟练后用的）
case "$1" in
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
        echo "  ${C}tm tools${NC}      打开工具箱菜单"
        echo ""
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
    tools|toolbox) do_toolbox; exit 0 ;;
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
        if [[ "$(uname)" == "Darwin" ]]; then
            local lip=$(ifconfig en0 2>/dev/null | grep "inet " | awk '{print $2}')
        else
            local lip=$(hostname -I 2>/dev/null | awk '{print $1}')
        fi
        echo "  🏠 内网: ${G}${lip:-未连接}${NC}"
        local pip=$(curl -s --connect-timeout 3 ifconfig.me 2>/dev/null)
        echo "  🌍 公网: ${G}${pip:-获取失败}${NC}"
        teach "curl ifconfig.me" "一条命令查公网 IP"
        exit 0
        ;;
    sys|status)
        do_sys_status; exit 0
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
        1) do_new ;;
        2) do_attach ;;
        3) do_list ;;
        4) do_detach ;;
        5) do_new_window ;;
        6) do_kill ;;
        7) do_learn ;;
        8) do_toolbox ;;
        0|q)
            echo ""
            echo "  ${G}👋 下次见！记住，直接输入 ${C}tm${G} 就能回来${NC}"
            echo ""
            break
            ;;
        *)
            echo "  ${Y}输入 0-8 的数字就行哦${NC}"
            sleep 1
            ;;
    esac
done
