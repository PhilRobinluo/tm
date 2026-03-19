#!/bin/zsh
# 描述: SSH 连接管理导航菜单
# ================================================================
# tm 官方插件 — SSH 连接管理
# 安装：tm plugin install ssh
# ================================================================

do_ssh_menu() {
    while true; do
        clear
        echo ""
        echo "  ${BD}🔐 SSH 连接管理${NC}"
        line
        echo ""
        echo "  ${BD}[1]${NC} 📋 查看已配置的 SSH 主机"
        echo "  ${BD}[2]${NC} 🔗 快速连接（选择主机）"
        echo "  ${BD}[3]${NC} 🔑 查看本地 SSH 密钥"
        echo "  ${BD}[4]${NC} 🆕 生成新的 SSH 密钥"
        echo "  ${BD}[5]${NC} 📋 复制公钥（用于粘贴到服务器）"
        echo "  ${BD}[6]${NC} 🧪 测试连接"
        echo "  ${BD}[0]${NC} 返回"
        echo ""
        echo -n "  选择: "
        read -k1 pick
        echo ""

        case $pick in
            1)
                echo ""
                echo "  ${BD}~/.ssh/config 中的主机：${NC}"
                echo ""
                grep -E '^Host ' ~/.ssh/config 2>/dev/null | grep -v '\*' | sed 's/Host /  /' || echo "  ${GR}没有配置文件或没有主机${NC}"
                teach "grep '^Host ' ~/.ssh/config" "从 SSH 配置文件提取主机别名"
                pause
                ;;
            2)
                echo ""
                echo "  ${BD}可用主机：${NC}"
                local hosts=($(grep -E '^Host ' ~/.ssh/config 2>/dev/null | grep -v '\*' | sed 's/Host //'))
                local idx=1
                for h in $hosts; do
                    echo "  [$idx] $h"
                    idx=$((idx + 1))
                done
                echo ""
                echo -n "  输入编号或主机名: "
                read choice
                local target=""
                if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -le ${#hosts[@]} ]]; then
                    target="${hosts[$choice]}"
                elif [[ -n "$choice" ]]; then
                    target="$choice"
                fi
                if [[ -n "$target" ]]; then
                    echo "  ${G}→ 连接 $target...${NC}"
                    ssh "$target"
                    teach "ssh $target" "连接到 SSH 主机"
                fi
                ;;
            3)
                echo ""
                echo "  ${BD}本地密钥：${NC}"
                echo ""
                ls -la ~/.ssh/id_* 2>/dev/null | awk '{print "  " $NF " (" $5 " bytes)"}' || echo "  ${GR}没有找到密钥${NC}"
                teach "ls ~/.ssh/id_*" "列出所有 SSH 密钥文件"
                pause
                ;;
            4)
                echo ""
                echo -n "  密钥类型 [ed25519/rsa] (默认 ed25519): "
                read keytype
                keytype=${keytype:-ed25519}
                echo -n "  备注（比如邮箱）: "
                read comment
                echo ""
                ssh-keygen -t "$keytype" -C "${comment:-$(whoami)@$(hostname)}"
                teach "ssh-keygen -t $keytype -C \"$comment\"" "-t 指定算法，ed25519 比 rsa 更安全更短"
                pause
                ;;
            5)
                echo ""
                local pubkeys=($(ls ~/.ssh/*.pub 2>/dev/null))
                if [[ ${#pubkeys[@]} -eq 0 ]]; then
                    echo "  ${Y}没有找到公钥，先用 [4] 生成一个${NC}"
                else
                    echo "  ${BD}选择公钥：${NC}"
                    local idx=1
                    for k in $pubkeys; do
                        echo "  [$idx] $(basename $k)"
                        idx=$((idx + 1))
                    done
                    echo ""
                    echo -n "  选择: "
                    read choice
                    if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -le ${#pubkeys[@]} ]]; then
                        cat "${pubkeys[$choice]}" | pbcopy 2>/dev/null || cat "${pubkeys[$choice]}" | xclip -sel clip 2>/dev/null
                        echo "  ${G}✅ 公钥已复制到剪贴板${NC}"
                        teach "pbcopy < ~/.ssh/id_ed25519.pub" "把公钥复制到剪贴板"
                    fi
                fi
                pause
                ;;
            6)
                echo ""
                echo -n "  输入主机名: "
                read host
                if [[ -n "$host" ]]; then
                    echo "  ${C}→ 测试连接 $host...${NC}"
                    ssh -o ConnectTimeout=5 -o BatchMode=yes "$host" echo "连接成功" 2>&1
                    teach "ssh -o ConnectTimeout=5 $host" "-o ConnectTimeout=5 最多等 5 秒"
                fi
                pause
                ;;
            0|*) return ;;
        esac
    done
}

# 注册到 tm
tm_register_toolbox_item "x" "🔐 SSH 连接管理" "do_ssh_menu"
tm_register_shortcut "ssh" "do_ssh_menu"
