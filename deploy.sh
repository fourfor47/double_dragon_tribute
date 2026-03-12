#!/data/data/com.termux/files/usr/bin/bash
# 双截龙致敬版自动部署脚本
# 功能：导出 HTML5 版本并部署到 GitHub Pages

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== 双截龙致敬版 - GitHub Pages 自动部署 ==="
echo "工作目录: $SCRIPT_DIR"

# 1. 检查 git 配置
if [ ! -d ".git" ]; then
    echo "初始化 Git 仓库..."
    git init
    git remote add origin https://github.com/YOUR_USERNAME/double_dragon_tribute.git 2>/dev/null || true
fi

# 2. 检查 Godot 是否可用
if ! command -v godot &> /dev/null; then
    echo "错误: 未找到 godot 命令。请安装 Godot 4.x 并添加到 PATH"
    exit 1
fi

echo "使用 Godot 版本: $(godot --version)"

# 3. 导出 HTML5 版本
echo "正在导出 HTML5 版本..."
godot --headless --export-release "HTML5" build/index.html

if [ ! -f "build/index.html" ]; then
    echo "导出失败：未生成 index.html"
    exit 1
fi

echo "导出成功！文件位于 build/"

# 4. 将构建文件复制到 gh-pages 分支（或主分支的 docs 文件夹）
echo "准备部署文件..."

# 清理并创建 docs 文件夹
rm -rf docs
mkdir -p docs
cp -r build/* docs/

# 5. 提交并推送
git add docs/
git commit -m "自动部署 HTML5 版本 - $(date '+%Y-%m-%d %H:%M:%S')" || echo "没有变更需要提交"
git push origin main || echo "GitHub 推送失败，请手动推送"

echo "✅ 部署完成！"
echo "访问地址: https://YOUR_USERNAME.github.io/double_dragon_tribute/"
echo ""
echo "注意：请将 YOUR_USERNAME 替换为你的 GitHub 用户名"
echo "如果使用 gh-pages 分支，请相应调整脚本"
