#!/bin/zsh
# 描述: npm/pnpm 包管理导航菜单
# ================================================================
# tm 官方插件 — npm/pnpm 包管理
# 安装：tm plugin install npm
# ================================================================

do_npm_menu() {
    # 自动检测包管理器
    local PM="npm"
    [[ -f "pnpm-lock.yaml" ]] && PM="pnpm"
    [[ -f "yarn.lock" ]] && PM="yarn"
    [[ -f "bun.lockb" ]] && PM="bun"

    while true; do
        clear
        echo ""
        echo "  ${BD}📦 包管理 ($PM)${NC}"
        echo ""

        if [[ -f "package.json" ]]; then
            local name=$(grep '"name"' package.json 2>/dev/null | head -1 | cut -d'"' -f4)
            local ver=$(grep '"version"' package.json 2>/dev/null | head -1 | cut -d'"' -f4)
            echo "  ${GR}项目: $name@$ver${NC}"
        else
            echo "  ${Y}当前目录没有 package.json${NC}"
        fi
        line
        echo ""
        echo "  ${BD}[1]${NC} 📥 安装依赖 ($PM install)"
        echo "  ${BD}[2]${NC} ➕ 添加包"
        echo "  ${BD}[3]${NC} ➖ 删除包"
        echo "  ${BD}[4]${NC} 🚀 运行脚本 ($PM run ...)"
        echo "  ${BD}[5]${NC} 📋 查看已装的包"
        echo "  ${BD}[6]${NC} 🔍 搜索包（在 npm 上）"
        echo "  ${BD}[7]${NC} ⬆️  检查过时的包"
        echo "  ${BD}[8]${NC} 🧹 清理缓存"
        echo "  ${BD}[0]${NC} 返回"
        echo ""
        echo -n "  选择: "
        read -k1 pick
        echo ""

        case $pick in
            1)
                echo "  ${C}→ $PM install${NC}"
                echo ""
                $PM install
                teach "$PM install" "根据 package.json 安装所有依赖"
                pause
                ;;
            2)
                echo -n "  输入包名: "
                read pkg
                if [[ -n "$pkg" ]]; then
                    echo ""
                    echo -n "  装到 devDependencies？(y/N): "
                    read dev
                    if [[ "$dev" == "y" || "$dev" == "Y" ]]; then
                        $PM add -D "$pkg" 2>/dev/null || $PM install --save-dev "$pkg"
                        teach "$PM add -D $pkg" "-D = devDependencies（开发依赖）"
                    else
                        $PM add "$pkg" 2>/dev/null || $PM install "$pkg"
                        teach "$PM add $pkg" "安装到 dependencies（生产依赖）"
                    fi
                fi
                pause
                ;;
            3)
                echo -n "  输入要删的包名: "
                read pkg
                [[ -n "$pkg" ]] && ($PM remove "$pkg" 2>/dev/null || $PM uninstall "$pkg")
                teach "$PM remove $pkg" "从项目中移除这个包"
                pause
                ;;
            4)
                echo ""
                echo "  ${BD}可用脚本：${NC}"
                grep -E '^\s+"[^"]+":' package.json 2>/dev/null | grep -v '"name"\|"version"\|"description"\|"main"\|"license"\|"author"\|"repository"' | head -15
                echo ""
                echo -n "  输入脚本名（如 dev/build/test）: "
                read script
                if [[ -n "$script" ]]; then
                    echo ""
                    $PM run "$script"
                    teach "$PM run $script" "运行 package.json 中定义的脚本"
                fi
                pause
                ;;
            5)
                echo ""
                $PM list --depth=0 2>/dev/null || $PM ls --depth=0
                teach "$PM list --depth=0" "--depth=0 只看顶层依赖，不看嵌套的"
                pause
                ;;
            6)
                echo -n "  搜索关键词: "
                read keyword
                [[ -n "$keyword" ]] && npm search "$keyword" 2>/dev/null | head -15
                teach "npm search $keyword" "在 npm 注册表中搜索包"
                pause
                ;;
            7)
                echo ""
                $PM outdated 2>/dev/null
                teach "$PM outdated" "列出所有可更新的包"
                pause
                ;;
            8)
                echo ""
                if [[ "$PM" == "pnpm" ]]; then
                    pnpm store prune
                    teach "pnpm store prune" "清理 pnpm 全局存储中未引用的包"
                else
                    npm cache clean --force
                    teach "npm cache clean --force" "清理 npm 缓存"
                fi
                pause
                ;;
            0|*) return ;;
        esac
    done
}

# 注册到 tm
tm_register_toolbox_item "n" "📦 npm/pnpm 包管理" "do_npm_menu"
tm_register_shortcut "npm" "do_npm_menu"
tm_register_shortcut "pnpm" "do_npm_menu"
