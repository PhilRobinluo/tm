class Tm < Formula
  desc "Terminal Mentor - 终端导航菜单，按数字操作，顺便学命令"
  homepage "https://github.com/PhilRobinluo/terminal-mentor"
  url "https://github.com/PhilRobinluo/terminal-mentor/archive/refs/tags/v1.0.0.tar.gz"
  sha256 ""
  license "MIT"

  depends_on "tmux"

  def install
    bin.install "tm"
    bin.install "tm-cheat"
  end

  def caveats
    <<~EOS
      安装完成！

      开始使用：
        tm          打开导航菜单
        tm help     查看所有命令
        tm keys     学习快捷键

      可选配置：
        创建 ~/.tmrc 自定义设置
        创建 ~/.tm/plugins/ 存放插件
    EOS
  end

  test do
    assert_match "tm version", shell_output("#{bin}/tm --version")
  end
end
