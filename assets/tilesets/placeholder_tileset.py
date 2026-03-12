#!/usr/bin/env python3
"""
简单的地图图块生成脚本
使用 PIL 生成基础像素图块集
需要: pip install pillow
"""

from PIL import Image, ImageDraw

TILE_SIZE = 32
TILES = {
    # 地板 (土灰色)
    "ground": (101, 67, 33),
    # 墙壁 (深灰色)
    "wall": (60, 60, 70),
    # 平台 (木色)
    "platform": (160, 100, 60),
    # 陷阱 (尖刺)
    "spike": (200, 50, 50),
    # 背景装饰
    "bg_building": (80, 80, 90),
    "bg_window": (120, 120, 150),
}

def create_tile(color, variant="normal"):
    img = Image.new("RGB", (TILE_SIZE, TILE_SIZE), color)
    d = ImageDraw.Draw(img)
    # 添加一些像素化纹理
    for y in range(0, TILE_SIZE, 4):
        for x in range(0, TILE_SIZE, 4):
            shade = 10 if (x+y)%8 == 0 else -10
            d.point((x, y), tuple(max(0, min(255, c + shade)) for c in color))
    return img

def main():
    import os
    out_dir = os.path.dirname(__file__)
    for name, color in TILES.items():
        img = create_tile(color)
        path = os.path.join(out_dir, f"{name}.png")
        img.save(path)
        print(f"Generated: {path}")

if __name__ == "__main__":
    main()
