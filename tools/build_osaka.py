#!/usr/bin/env python3
"""
大阪市ごみ収集マップ(読み上げ用)から抜き出した osaka_enc.txt を
gomi_data.json の地区データ(大阪市 24区・町丁目単位)に変換するスクリプト

使い方:  python3 tools/build_osaka.py
"""
import json, os

HERE = os.path.dirname(os.path.abspath(__file__))
ENC = os.path.join(HERE, "osaka_enc.txt")
DATA = os.path.join(HERE, "..", "gomibi", "gomi_data.json")

# 区名 → 公式ページのスラッグ (出典URL用)
SLUG = {"北区":"kita","都島区":"miyakojima","福島区":"fukushima","此花区":"konohana","中央区":"chuo",
        "西区":"nishi","港区":"minato","大正区":"taisho","天王寺区":"tennoji","浪速区":"naniwa",
        "西淀川区":"nishiyodogawa","淀川区":"yodogawa","東淀川区":"higashiyodogawa","東成区":"higashinari",
        "生野区":"ikuno","旭区":"asahi","城東区":"joto","鶴見区":"tsurumi","阿倍野区":"abeno",
        "住之江区":"suminoe","住吉区":"sumiyoshi","東住吉区":"higashisumiyoshi","平野区":"hirano","西成区":"nishinari"}
TYPES = ["burnable", "resource", "plastic", "paper"]   # パターンの並び: 普通|資源|プラ|古紙衣類
UPDATED = "2026-11-23"

def rules_of(pattern, area_id):
    rules = []
    for i, days in enumerate(pattern.split("|")):
        if days:
            rules.append({"id": None, "type": TYPES[i], "weekdays": [int(c) for c in days],
                          "weeks": None, "biweeklyStartDate": None})
    return rules

def ban_label(bans):
    return "・".join(bans) + "番"

def main():
    lines = open(ENC, encoding="utf-8").read().strip().split("\n")
    pats = lines[0][2:].split(",")
    areas, ward = [], None
    for line in lines[1:]:
        if line.startswith("W:"):
            ward = line[2:]; continue
        town, spec = line.split(":", 1)
        for part in spec.split(";"):
            chome, groups = part.split("=", 1)
            base = town if chome == "0" else (town + chome + "丁目" if chome.isdigit() else town + chome)
            segs = groups.split(",")
            for n, seg in enumerate(segs):
                if "/" in seg:
                    pid, bans = seg.split("/", 1)
                    name = f"{base} {ban_label(bans.split('.'))}"
                else:
                    pid = seg
                    name = base if len(segs) == 1 else f"{base}（その他の番地）"
                pattern = pats[int(pid)]
                aid = f"27100-{SLUG[ward]}-{base}-{n}"
                rules = rules_of(pattern, aid)
                for k, r in enumerate(rules):
                    r["id"] = f"{aid}-{k}"
                note = None if pattern.split("|")[3] else "古紙・衣類はコミュニティ回収の地域です（町会などでご確認ください）"
                areas.append({
                    "id": aid, "prefecture": "大阪府", "city": "大阪市", "cityKana": "おおさかし",
                    "ward": ward, "area": name, "rules": rules, "exceptions": [],
                    "source": f"https://www.city.osaka.lg.jp/contents/wdu150/trashmap/text/ward/{SLUG[ward]}.html",
                    "updated": UPDATED, "note": note,
                    "typeNames": {"burnable": "普通ごみ", "plastic": "プラスチック資源", "paper": "古紙・衣類"},
                    "typeShortNames": {"burnable": "普通"},
                })
    return areas

if __name__ == "__main__":
    import uuid
    osaka = main()
    # rule id は UUID 形式が必要 → 文字列から決まった UUID を作る (毎回同じ値)
    for a in osaka:
        for r in a["rules"]:
            r["id"] = str(uuid.uuid5(uuid.NAMESPACE_URL, "gomiday/" + r["id"])).upper()
    data = json.load(open(DATA, encoding="utf-8"))
    data["areas"] = [a for a in data["areas"] if a["city"] != "大阪市"] + osaka
    data["version"] = UPDATED
    # 1地区 = 1行 で書き出し (読みやすさとファイルサイズの両立)
    with open(DATA, "w", encoding="utf-8") as f:
        f.write('{\n  "version": %s,\n  "municipalities": [\n' % json.dumps(data["version"]))
        f.write(",\n".join("    " + json.dumps(m, ensure_ascii=False) for m in data["municipalities"]))
        f.write('\n  ],\n  "areas": [\n')
        f.write(",\n".join("    " + json.dumps(a, ensure_ascii=False, separators=(",", ":")) for a in data["areas"]))
        f.write("\n  ]\n}\n")
    print("大阪市", len(osaka), "地区 / 全体", len(data["areas"]), "地区")
