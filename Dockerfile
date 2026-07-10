# ─────────────────────────────────────────────
# 🐳 Hermes Agent Dockerfile (Coolify-ready)
# ─────────────────────────────────────────────
# الصورة مبنية على Ubuntu 22.04، بتثبّت Hermes Agent
# وتستعدّي لاستعادة الباك أب تلقائياً عند أول تشغيل.

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    HERMES_HOME=/root/.hermes \
    TZ=UTC

# 1️⃣ الحزم الأساسية
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl ca-certificates bash tar tzdata openssl \
    && rm -rf /var/lib/apt/lists/*

# 2️⃣ تثبيت Hermes Agent (shell installer)
RUN curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash

# 3️⃣ مجلد العمل والتطبيقات
WORKDIR /app

# نسخ ملفات الإعداد (Dockerfile context)
COPY backup/ ./backup/
COPY restore.sh /app/restore.sh
COPY start.sh /app/start.sh
RUN chmod +x /app/restore.sh /app/start.sh

# 4️⃣ فضح المنافذ (سيرفر Hermes + التونل)
EXPOSE 9119

# 5️⃣ أمر التشغيل
CMD ["/app/start.sh"]
