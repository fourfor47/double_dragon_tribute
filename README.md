# 双截龙：致敬版 (Double Dragon Tribute)

一款基于 **Godot 4.x** 开发的横向卷轴格斗游戏，向经典街机游戏《双截龙》致敬。

## 🌟 特性

- **双人同屏合作** - 本地双人游戏，重温并肩作战的感觉
- **经典玩法** - belt-scroll 横向卷轴，拳脚格斗，武器拾取
- **完全免费开源** - MIT 协议，无版权顾虑
- **网页即玩** - 支持 HTML5 导出，直接在浏览器中游玩

## 🎮 操作说明

### 玩家1 (键盘)
- **A / D** - 左右移动
- **W** - 跳跃
- **Z** - 攻击 / 拾取武器

### 玩家2 (键盘)
- **J / L** - 左右移动
- **I** - 跳跃
- **K** - 攻击 / 拾取武器

### 通用
- **ESC** - 暂停游戏

## 📦 项目结构

```
double_dragon_tribute/
├── scripts/          # GDScript 源代码
│   ├── game_manager.gd    # 全局游戏管理器
│   ├── input_manager.gd   # 输入处理（双人支持）
│   ├── player.gd          # 玩家角色
│   ├── enemy.gd           # 敌人 AI
│   ├── weapon.gd          # 可拾取武器
│   ├── stage_loader.gd    # 关卡加载器
│   ├── hud.gd             # 用户界面
│   └── main_menu.gd       # 主菜单
├── scenes/           # 游戏场景 (.tscn)
│   ├── main_menu.tscn
│   ├── game.tscn
│   └── hud.tscn
├── assets/           # 美术与音效资源（待补充）
│   ├── characters/
│   ├── tilesets/
│   ├── maps/
│   ├── audio/
│   └── ui/
└── project.godot    # Godot 项目配置

```

## 🚀 快速开始

### 开发环境搭建

1. 下载并安装 [Godot 4.2+](https://godotengine.org/download/)
2. 克隆或下载本项目
3. 用 Godot 打开项目文件夹（`double_dragon_tribute`）
4. 按 **F6** 运行当前场景

### 导出为网页版 (HTML5)

1. 点击菜单：**项目 → 导出**
2. 添加 **HTML5** 预设
3. 点击 **导出项目**，选择输出文件夹
4. 生成的 `index.html` 及相关文件可直接部署到任何静态网页托管服务

**推荐部署平台：**
- [GitHub Pages](https://pages.github.com/) - 免费，支持自动 HTTPS
- [itch.io](https://itch.io/) - 游戏社区，HTML5 一键托管
- [Netlify](https://www.netlify.com/) - 自动从 Git 仓库构建

## 🛠️ 技术栈

- **引擎**: Godot 4.x (MIT License)
- **编程语言**: GDScript (Python-like)
- **地图编辑**: Tiled Map Editor (BSD) - 可选
- **像素美术**: LibreSprite / Aseprite / Piskel
- **音效音乐**: Bosca Ceoil / sfxr / freesound.org (CC0)

## 📝 开发进度

- [x] 项目框架搭建
- [x] 玩家基础移动 & 攻击系统
- [x] 敌人基础 AI（巡逻、追击、攻击）
- [x] 武器拾取与投掷
- [x] 血条与 UI
- [ ] 关卡设计（第1关）
- [ ] 敌人种类扩展
- [ ] Boss 关卡
- [ ] 音效与音乐
- [ ] 网页版导出与测试

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

本项目为开源学习项目，所有代码使用 MIT 协议。美术资源请使用 CC0 或原创。

## ⚠️ 版权说明

本项目为致敬作品，**不包含任何原版《双截龙》的素材、音效或代码**。
所有内容均为原创或使用开源/CC0协议资源。

原作《双截龙》版权归属 Technōs Japan / Arc System Works。

---

**Made with ❤️ by the OpenClaw Agent**
