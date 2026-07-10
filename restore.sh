#!/bin/bash
# ─────────────────────────────────────────────
# 🚀 Hermes Agent Restore Script
# يستعيد الباك أب (tar.gz) إلى ~/.hermes عند أول تشغيل فقط
# ─────────────────────────────────────────────
set -e

BK_DIR="/app/backup"
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
FLAG="$HERMES_HOME/.restored"

# دعم تمرير اسم الملف عبر متغير البيئة (اختياري)
BK_FILE="${BACKUP_FILE:-$(ls -1 "$BK_DIR"/*.tar.gz 2>/dev/null | head -1)}"

if [ -f "$FLAG" ]; then
    echo "✅ تم الاسترجاع مسبقاً (موجود: $FLAG) — تخطّي."
    exit 0
fi

if [ -z "$BK_FILE" ] || [ ! -f "$BK_FILE" ]; then
    echo "⚠️ لم يُعثر على ملف باك أب في $BK_DIR — سيُطلق Hermes بإعدادات افتراضية."
    touch "$FLAG"
    exit 0
fi

echo "📦 فك ضغط الباك أب: $BK_FILE"
mkdir -p /tmp/hermes-restore
tar xzf "$BK_FILE" -C /tmp/hermes-restore
SRC=$(find /tmp/hermes-restore -maxdepth 1 -type d -name 'hermes-backup-*' | head -1)

if [ -z "$SRC" ]; then
    echo "❌ هيكل الباك أب غير متوقع."
    exit 1
fi
echo "   المصدر: $SRC"

mkdir -p "$HERMES_HOME"

echo "1️⃣ الإعدادات (config.yaml / .env / auth.json)..."
cp "$SRC/files/config.yaml" "$HERMES_HOME/" 2>/dev/null || true
cp "$SRC/files/.env"        "$HERMES_HOME/" 2>/dev/null || true
cp "$SRC/files/auth.json"   "$HERMES_HOME/" 2>/dev/null || true

echo "2️⃣ المهارات (skills)..."
[ -f "$SRC/files/skills.tar.gz" ] && tar xzf "$SRC/files/skills.tar.gz" -C ~/

echo "3️⃣ الجلسات (sessions)..."
[ -f "$SRC/files/sessions.tar.gz" ] && tar xzf "$SRC/files/sessions.tar.gz" -C ~/
[ -f "$SRC/files/state.db" ] && cp "$SRC/files/state.db" "$HERMES_HOME/"

echo "4️⃣ Cloudflare Tunnel..."
mkdir -p ~/.cloudflared
[ -f "$SRC/files/cloudflared.tar.gz" ] && tar xzf "$SRC/files/cloudflared.tar.gz" -C ~/
[ -f "$SRC/files/tunnel-config.yml" ] && cp "$SRC/files/tunnel-config.yml" /tmp/

echo "🔒 صلاحيات الأمان..."
chmod 600 "$HERMES_HOME/.env" "$HERMES_HOME/auth.json" 2>/dev/null || true

touch "$FLAG"
echo "✅ تم الاسترجاع بنجاح!"
