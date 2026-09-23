#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
update_holidays.py
中国节假日数据独立更新脚本
用途：从公开节假日数据源（如 holiday-cn）获取指定年份的法定节假日与调休数据，
生成更新后的 lua/holidays.lua 文件。更新失败绝不损坏现有数据。
"""

import os
import sys
import json
import urllib.request
import tempfile
from datetime import datetime

# 每年 11 月 20 日起把次年加入检测范围；远端的未来年份空壳只有在包含
# 国务院公告来源和实际日期记录后才会被接纳。
now = datetime.now()
TARGET_YEARS = list(range(2024, now.year + 1))
if (now.month, now.day) >= (11, 20):
    TARGET_YEARS.append(now.year + 1)
DATA_URL_TEMPLATE = "https://raw.githubusercontent.com/NateScarlet/holiday-cn/master/{year}.json"
MIRROR_URL_TEMPLATE = "https://fastly.jsdelivr.net/gh/NateScarlet/holiday-cn@master/{year}.json"

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
RIME_DIR = os.path.dirname(SCRIPT_DIR)
LUA_HOLIDAYS_PATH = os.path.join(RIME_DIR, "lua", "holidays.lua")

def fetch_year_holidays(year):
    urls = [
        MIRROR_URL_TEMPLATE.format(year=year),
        DATA_URL_TEMPLATE.format(year=year),
    ]
    for url in urls:
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
            with urllib.request.urlopen(req, timeout=10) as resp:
                if resp.status == 200:
                    data = json.loads(resp.read().decode("utf-8"))
                    if (
                        data.get("year") == year
                        and data.get("papers")
                        and data.get("days")
                    ):
                        return data["days"]
        except Exception as e:
            continue
    return None

def generate_lua_content(years_data):
    lines = [
        "--[[",
        "  holidays.lua",
        "  中国法定节假日与调休补班本地数据",
        "  由 scripts/update_holidays.py 自动生成于 " + datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "  true  = 调休补班工作日 (周末变工作日)",
        "  false = 法定节假日/调休放假 (工作日变休息日)",
        "  nil   = 按自然周判断 (周一至周五为工作日，周六周日为休息日)",
        "--]]",
        "",
        "local M = {}",
        "",
        "M.years = {",
    ]
    for y in sorted(years_data.keys()):
        lines.append(f"    [{y}] = true,")
    lines.append("}")
    lines.append("")
    lines.append("M.days = {")

    all_days = {}
    for y, days in years_data.items():
        for d in days:
            date_str = d.get("date")
            is_off_day = d.get("isOffDay")
            name = d.get("name", "")
            if date_str and is_off_day is not None:
                all_days[date_str] = (not is_off_day, name)

    for date_str in sorted(all_days.keys()):
        is_workday, name = all_days[date_str]
        val = "true" if is_workday else "false"
        comment = f" -- {name} 调休工作日" if is_workday else f" -- {name} 放假"
        lines.append(f'    ["{date_str}"] = {val},{comment}')

    lines.append("}")
    lines.append("")
    lines.append("return M")
    lines.append("")
    return "\n".join(lines)

def main():
    print("开始更新中国节假日数据...")
    years_data = {}
    success_count = 0

    for year in TARGET_YEARS:
        print(f"正在获取 {year} 年数据...")
        days = fetch_year_holidays(year)
        if days:
            years_data[year] = days
            success_count += 1
            print(f"  成功获取 {year} 年数据，记录数: {len(days)}")
        else:
            print(f"  获取 {year} 年数据失败（可能尚未发布或网络不可达）")

    if success_count == 0:
        print("未能获取到任何年份的节假日数据，终止更新，保持原文件不变。")
        sys.exit(1)

    content = generate_lua_content(years_data)

    # 原子写入
    dir_name = os.path.dirname(LUA_HOLIDAYS_PATH)
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", dir=dir_name, delete=False) as tf:
        tf.write(content)
        temp_name = tf.name

    os.replace(temp_name, LUA_HOLIDAYS_PATH)
    print(f"更新成功！已保存到: {LUA_HOLIDAYS_PATH}")

if __name__ == "__main__":
    main()
