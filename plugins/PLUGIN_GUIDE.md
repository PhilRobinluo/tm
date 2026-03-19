# 如何写一个 tm 插件

## 最小模板

```bash
#!/bin/zsh
# 描述: 一句话说明这个插件干什么

do_my_feature() {
    clear
    echo ""
    echo "  ${BD}🔧 功能标题${NC}"
    line

    # ... 你的逻辑 ...

    teach "原始命令" "一句话解释"
    pause
}

# 注册到工具箱菜单（按 [m] 触发）
tm_register_toolbox_item "m" "🔧 我的功能" "do_my_feature"

# 注册快捷命令（tm myfeat 直接触发）
tm_register_shortcut "myfeat" "do_my_feature"
```

## 规范

1. 第一行 `#!/bin/zsh`
2. 第二行 `# 描述:` 用于 `tm plugin list` 展示
3. 每个操作带 `teach()` — 这是 tm 的灵魂
4. 用 `pause()` 让用户看到结果
5. 用 `line()` 画分隔线
6. 颜色：成功=`$G`，警告=`$Y`/`$R`，命令=`$C`，注释=`$GR`，加粗=`$BD`

## 可用的注册函数

| 函数 | 作用 |
|------|------|
| `tm_register_toolbox_item "键" "标签" "函数名"` | 在工具箱菜单添加一项 |
| `tm_register_shortcut "命令名" "函数名"` | 注册 `tm xxx` 快捷命令 |

## 安装位置

`~/.tm/plugins/你的插件.sh`

tm 启动时自动加载该目录下所有 `.sh` 文件。
