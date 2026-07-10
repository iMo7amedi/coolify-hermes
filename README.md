# 🐳 Hermes Agent على Coolify — حزمة النشر الجاهزة

هذا المجلد فيه كل ما تحتاجه لرفع Hermes Agent على Coolify مع استعادة
الباك أب تلقائياً عند أول تشغيل.

## 📁 محتويات المجلد

```
coolify-hermes/
├── Dockerfile              # يبني الصورة ويثبّت Hermes Agent
├── docker-compose.yml      # تعريف الخدمة + volume دائم
├── restore.sh             # يستعيد الباك أب إلى ~/.hermes (مرة واحدة)
├── start.sh               # يشغّل السيرفر + الجيت واي (+ التونل)
├── backup/
│   └── hermes-backup-20260710.tar.gz   # الباك أب الكامل
└── README.md
```

## 🚀 خطوات النشر على Coolify

### 1️⃣ ارفع المجلد إلى مستودع Git (GitHub/GitLab)
أو استخدم "Private Repository" في Coolify وارفع الملفات.

### 2️⃣ في Coolify Dashboard:
- **New Resource** → اختر **Docker Compose**
- اربط المستودع (أو ارفع الـ compose يدوياً)
- Coolify سيتعرف على `docker-compose.yml` تلقائياً

### 3️⃣ إعدادات مهمة:
- **Port:** `9119` (تم فضحه في Dockerfile والـ compose)
- **Volume:** `hermes_data` تم تعريفه تلقائياً — بيحفظ
  `~/.hermes/` (الإعدادات، المهارات، الجلسات) حتى بعد
  إعادة بناء الكونتينر.
- **Health check (اختياري):**
  `curl -s --max-time 10 http://localhost:9119/api/status`

### 4️⃣ Deploy 🎯
اضغط **Deploy**. عند أول تشغيل:
1. `restore.sh` يفك الباك أب ويستعيد كل الإعدادات.
2. `start.sh` يشغّل `hermes serve` + `hermes gateway`.
3. لو `/tmp/tunnel-config.yml` و `/tmp/cloudflared` موجودين،
   التونل يشتغل تلقائياً.

## 🔑 متغيرات البيئة (اختيارية)

من لوحة Coolify → Environment:

| المتغير | الوصف | الافتراضي |
|---------|-------|-----------|
| `HERMES_HOME` | مسار بيت Hermes | `/root/.hermes` |
| `TZ` | المنطقة الزمنية | `UTC` |
| `BACKUP_FILE` | مسار ملف الباك أب داخل الحاوية | أول `.tar.gz` في `/app/backup/` |

## ✅ التحقق بعد النشر

```bash
# داخل الكونتينر (Coolify Terminal):
hermes status --all
hermes config check
hermes doctor

# اختبار التونل (لو شغّال):
curl -s --max-time 10 https://hermes.moflow.pro/api/status
```

## 🔄 تحديث الباك أب لاحقاً

استبدل الملف في `backup/` بأحدث نسخة، ثم أعد الـ Deploy.
(ملاحظة: الاستعادة تتم مرة واحدة فقط — لإعادة الاستعادة احذف
الملف `~/.hermes/.restored` داخل الـ volume ثم أعد التشغيل.)

## ⚠️ ملاحظات أمان

- ملف `.env` و `auth.json` فيهما مفاتيح حساسة — الـ restore.sh
  يضبط صلاحياتهم إلى `600`.
- لا تشارك الباك أب (`*.tar.gz`) علناً أبداً.
