#!/bin/bash
# ─────────────────────────────────────────────
# 🚀 Hermes Agent Startup Script (Coolify)
# 1) يستعيد الباك أب عند أول تشغيل
# 2) يشغّل السيرفر + الجيت واي (+ التونل لو موجود)
# ─────────────────────────────────────────────
set -e

HERMES_BIN="$(command -v hermes || echo /root/.hermes/.venv/bin/hermes)"
export HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"

echo "🔄 استعادة الباك أب (إن لزم)..."
bash /app/restore.sh

echo "🩺 فحص الإعدادات..."
"$HERMES_BIN" config check 2>/dev/null || true

echo "🚀 تشغيل Hermes serve على المنفذ 9119..."
"$HERMES_BIN" serve --host 0.0.0.0 --port 9119 &
SERVE_PID=$!

echo "🌉 تشغيل Cloudflare Tunnel (إن وُجد الكونفيج)..."
if [ -f /tmp/tunnel-config.yml ] && [ -x /tmp/cloudflared ]; then
    /tmp/cloudflared tunnel --config /tmp/tunnel-config.yml run &
fi

echo "📡 تشغيل Hermes Gateway..."
"$HERMES_BIN" gateway run &
GATEWAY_PID=$!

echo "✅ Hermes Agent يعمل. (serve PID=$SERVE_PID, gateway PID=$GATEWAY_PID)"
echo "   للمراقبة: hermes status --all"

# ابقَ العملية حية (مهم لـ Coolify/Docker)
wait
