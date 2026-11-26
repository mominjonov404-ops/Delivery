# Yetkazma — APK Olish Qo'llanmasi
## Telefon orqali, GitHub Codespaces bilan

---

## 1-QADAM — Supabase (5 daqiqa)

1. **Brauzerda oching:** https://supabase.com
2. **"Start your project"** → Google bilan kiring
3. **"New project"** tugmasini bosing
   - Name: `yetkazma`
   - Region: `Southeast Asia (Singapore)` ← O'zbekistonga eng yaqin
   - Password: xohlagan parol yozing
4. **"Create new project"** → 2 daqiqa kuting
5. Tayyor bo'lgach: **Settings → API** ga kiring
6. Quyidagilarni nusxa oling va saqlang:
   ```
   Project URL:  https://xxxxxxxxxxxx.supabase.co
   anon public:  eyJhbGc...
   ```

---

## 2-QADAM — SQL Migratsiya

1. Supabase da **"SQL Editor"** ga kiring (chap menyu)
2. **"New query"** bosing
3. Quyidagi faylning barcha matnini nusxa oling:
   ```
   supabase/migrations/001_initial_schema.sql
   ```
4. SQL Editor ga joylashtiring → **"Run"** bosing
5. `Success` ko'rsangiz — tayyor

---

## 3-QADAM — GitHub Repo (3 daqiqa)

1. **Brauzerda oching:** https://github.com
2. Hisob oching yoki kiring
3. **"New repository"** bosing
   - Repository name: `yetkazma`
   - Public yoki Private — farqi yo'q
   - **"Create repository"** bosing
4. **"uploading an existing file"** havolasini bosing
5. `delivery_app.zip` ni yuklang → **"Commit changes"** bosing

---

## 4-QADAM — Secrets (Supabase kalitlari)

1. GitHub repo → **Settings** (yuqori menyu)
2. **Secrets and variables → Actions**
3. **"New repository secret"** — ikkita qo'shing:

   | Name | Value |
   |------|-------|
   | `SUPABASE_URL` | 1-qadamdagi Project URL |
   | `SUPABASE_ANON_KEY` | 1-qadamdagi anon public key |

---

## 5-QADAM — Codespaces (APK build)

1. GitHub repo sahifasida yashil **"Code"** tugmasini bosing
2. **"Codespaces"** tabini tanlang
3. **"Create codespace on main"** bosing
4. Brauzerda VS Code ochiladi — 2-3 daqiqa kuting

**Terminal ochiq bo'lmasa:** View → Terminal (yoki Ctrl+`)

**Terminalni bosqichma-bosqich ishga tushiring:**

```bash
# Flutter o'rnatish
git clone https://github.com/flutter/flutter.git -b stable --depth 1 ~/flutter
export PATH="$PATH:$HOME/flutter/bin"
flutter precache --android
```

```bash
# Android SDK o'rnatish
wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip -q commandlinetools-linux-11076708_latest.zip -d ~/android-sdk
mkdir -p ~/android-sdk/cmdline-tools/latest
mv ~/android-sdk/cmdline-tools/{bin,lib,NOTICE.txt,source.properties} ~/android-sdk/cmdline-tools/latest/ 2>/dev/null || true
export ANDROID_SDK_ROOT=$HOME/android-sdk
export PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools"
```

```bash
# Android lisenziya va build tools
yes | sdkmanager --licenses
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
```

```bash
# Proyekt papkasiga kiring
cd delivery_app
flutter pub get
```

```bash
# APK build
flutter build apk --debug \
  --dart-define=SUPABASE_URL=$SUPABASE_URL \
  --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY
```

> Agar `SUPABASE_URL` ishlamasa, to'g'ridan to'g'ri yozing:
> ```bash
> flutter build apk --debug \
>   --dart-define=SUPABASE_URL=https://SIZNING_URL.supabase.co \
>   --dart-define=SUPABASE_ANON_KEY=SIZNING_ANON_KEY
> ```

---

## 6-QADAM — APK Yuklab Olish

1. Build tugagach (`build/app/outputs/flutter-apk/app-debug.apk`)
2. VS Code da **Explorer** (chap panel) → `delivery_app/build/app/outputs/flutter-apk/`
3. `app-debug.apk` ustida o'ng klik → **"Download"**
4. Telefoningizga yuboring (Telegram, email, Drive)

---

## 7-QADAM — Admin Sozlash

APK telefoningizga o'rnatilgach:

1. `+998941771247` bilan kiring → SMS kod olasiz
2. Supabase → **SQL Editor** → yangi query:
   ```sql
   update public.profiles 
   set role = 'admin' 
   where phone = '+998941771247';
   ```
3. **Run** → ilovaga qaytib kiring → Admin panel ochiladi

---

## Muammolar

**`flutter: command not found`**
```bash
export PATH="$PATH:$HOME/flutter/bin"
```

**`SDK not found`**
```bash
export ANDROID_SDK_ROOT=$HOME/android-sdk
export PATH="$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin"
```

**Build uzoq davom etyapti** — normal, birinchi marta 10-15 daqiqa ketadi.

**Lisenziya xatosi**
```bash
yes | sdkmanager --licenses
```

---

## SMS (Twilio) — Ixtiyoriy

Haqiqiy SMS olish uchun:
1. https://twilio.com → bepul hisob (trial)
2. Phone Number oling
3. Supabase → Authentication → Providers → Phone → Twilio
4. Account SID, Auth Token, Phone Number kiriting

> Trial holatda faqat tasdiqlangan raqamlarga SMS ketadi.
> Test uchun Supabase → Authentication → Users → "Send OTP" qo'lda ishlating.

