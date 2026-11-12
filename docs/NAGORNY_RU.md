# Nagorny Express — как собрать и раздать

Nagorny Express — это форк [Hiddify](https://github.com/hiddify/hiddify-app) (лицензия GPLv3 + Hiddify Extended).
Изменения: название, идентификатор Android `app.nagorny.express`, заголовок окна Windows, простая сборка `nagorny-build.yml`.
Использование только некоммерческое. Исходники должны оставаться открытыми в этом форке.

## Собрать новую версию (Windows + Android) — без установки чего-либо на ПК

1. Откройте https://github.com/Vivaellpololoco/vpn-client/actions/workflows/nagorny-build.yml
2. Нажмите **Run workflow** → **Run workflow**.
3. Подождите 40–60 минут, пока обе строки (windows, android) станут зелёными.
4. Откройте запуск, внизу в разделе **Artifacts** скачайте:
   - `NagornyExpress-Windows` — zip, внутри папка с программой (запускать `Hiddify.exe`);
   - `NagornyExpress-Android` — внутри `NagornyExpress-Android-arm64.apk` (для почти всех телефонов)
     и `NagornyExpress-Android-universal.apk` (если arm64 не ставится).

Artifacts хранятся на GitHub 90 дней.

## Установить APK на Android

1. Отправьте файл `.apk` на телефон (Telegram, кабель, облако).
2. Откройте его. Телефон спросит разрешение «Установка из неизвестных источников» — разрешите для того приложения,
   из которого открываете файл.
3. Откройте Nagorny Express → «+» → вставьте ссылку на подписку → подключайтесь.

## Важно про подпись APK

Сейчас APK подписан временным отладочным ключом сборщика GitHub. Ключ при каждой сборке может быть другим,
поэтому новая версия может не встать поверх старой (придётся удалить старую и поставить заново).

Чтобы обновления ставились поверх, нужен свой постоянный ключ:
1. Создать ключ (один раз): `keytool -genkey -v -keystore nagorny.jks -keyalg RSA -keysize 2048 -validity 10000 -alias nagorny`
2. Добавить в GitHub → Settings → Secrets and variables → Actions четыре секрета:
   `ANDROID_SIGNING_KEY` (файл `nagorny.jks` в base64), `ANDROID_SIGNING_STORE_PASSWORD`,
   `ANDROID_SIGNING_KEY_PASSWORD`, `ANDROID_SIGNING_KEY_ALIAS` (= `nagorny`).
3. Файл `nagorny.jks` и пароли хранить в надёжном месте. **Потеряете ключ — обновления поверх больше не встанут.**

(Шаг подключения этих секретов в `nagorny-build.yml` ещё не добавлен.)

## Windows: что увидят пользователи

- SmartScreen «Windows защитила ваш компьютер» → **Подробнее** → **Выполнить в любом случае** (нет платной подписи кода).
- Для режима TUN (весь трафик через VPN) программа попросит права администратора — это нормально.
- Антивирус может ругаться на VPN-ядро — добавить папку программы в исключения.
