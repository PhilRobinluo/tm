#!/bin/zsh
# 描述: Docker 容器管理导航菜单
# ================================================================
# tm 官方插件 — Docker 管理
# 安装：tm plugin install docker
# ================================================================

do_docker_menu() {
    while true; do
        clear
        echo ""
        echo "  ${BD}🐳 Docker 管理${NC}"
        echo ""

        # 状态面板
        if command -v docker &>/dev/null; then
            local running=$(docker ps -q 2>/dev/null | wc -l | tr -d ' ')
            local total=$(docker ps -aq 2>/dev/null | wc -l | tr -d ' ')
            echo "  ${GR}容器: ${G}$running 运行中${GR} / $total 总计${NC}"
        else
            echo "  ${R}Docker 未安装${NC}"
        fi
        line
        echo ""
        echo "  ${BD}[1]${NC} 📋 查看运行中的容器"
        echo "  ${BD}[2]${NC} 📋 查看所有容器（含停止的）"
        echo "  ${BD}[3]${NC} 🚀 启动一个停止的容器"
        echo "  ${BD}[4]${NC} 🛑 停止一个运行中的容器"
        echo "  ${BD}[5]${NC} 📜 查看容器日志"
        echo "  ${BD}[6]${NC} 🖥️  进入容器终端"
        echo "  ${BD}[7]${NC} 🖼️  查看本地镜像"
        echo "  ${BD}[8]${NC} 🧹 清理（删除停止的容器和悬空镜像）"
        echo "  ${BD}[0]${NC} 返回"
        echo ""
        echo -n "  选择: "
        read -k1 pick
        echo ""

        case $pick in
            1)
                echo ""
                docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null
                teach "docker ps" "列出运行中的容器"
                pause
                ;;
            2)
                echo ""
                docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Image}}" 2>/dev/null
                teach "docker ps -a" "-a = all，包括停止的容器"
                pause
                ;;
            3)
                echo ""
                echo "  ${GR}停止的容器：${NC}"
                docker ps -a --filter "status=exited" --format "  {{.Names}} ({{.Image}})" 2>/dev/null
                echo ""
                echo -n "  输入容器名: "
                read name
                [[ -n "$name" ]] && docker start "$name" 2>/dev/null && echo "  ${G}✅ $name 已启动${NC}"
                teach "docker start $name" "启动一个停止的容器"
                pause
                ;;
            4)
                echo ""
                echo "  ${GR}运行中的容器：${NC}"
                docker ps --format "  {{.Names}} ({{.Image}})" 2>/dev/null
                echo ""
                echo -n "  输入容器名: "
                read name
                [[ -n "$name" ]] && docker stop "$name" 2>/dev/null && echo "  ${G}✅ $name 已停止${NC}"
                teach "docker stop $name" "优雅停止容器（发 SIGTERM）"
                pause
                ;;
            5)
                echo ""
                echo "  ${GR}运行中的容器：${NC}"
                docker ps --format "  {{.Names}}" 2>/dev/null
                echo ""
                echo -n "  输入容器名: "
                read name
                [[ -n "$name" ]] && docker logs --tail 30 "$name" 2>/dev/null
                teach "docker logs --tail 30 $name" "--tail 30 只看最后 30 行"
                pause
                ;;
            6)
                echo ""
                echo "  ${GR}运行中的容器：${NC}"
                docker ps --format "  {{.Names}}" 2>/dev/null
                echo ""
                echo -n "  输入容器名: "
                read name
                [[ -n "$name" ]] && docker exec -it "$name" /bin/sh 2>/dev/null
                teach "docker exec -it $name /bin/sh" "exec = 在容器里执行命令，-it = 交互式终端"
                ;;
            7)
                echo ""
                docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" 2>/dev/null
                teach "docker images" "列出本地所有镜像"
                pause
                ;;
            8)
                echo ""
                echo -n "  ${Y}确认清理停止的容器和悬空镜像？(y/N): ${NC}"
                read answer
                if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
                    docker container prune -f 2>/dev/null
                    docker image prune -f 2>/dev/null
                    echo "  ${G}✅ 清理完成${NC}"
                fi
                teach "docker system prune" "一键清理所有未使用的资源"
                pause
                ;;
            0|*) return ;;
        esac
    done
}

# 注册到 tm
tm_register_toolbox_item "d" "🐳 Docker 管理" "do_docker_menu"
tm_register_shortcut "docker" "do_docker_menu"
