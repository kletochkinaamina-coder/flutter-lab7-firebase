# Лабораторная работа 7. Firebase Realtime Database и Push Notifications

Форма регистрации из СРСП 5, подключённая к Firebase: при отправке формы данные пользователя сохраняются в Firebase Realtime Database (`users/`), после успешной регистрации приходит push-уведомление. Приложение принимает push-уведомления через Firebase Cloud Messaging (FCM).

Выполнила: Ильяс Амина

## Запуск

1. Создать проект в Firebase Console, включить Realtime Database (Test mode).
2. Добавить Android-приложение с package name `kz.amina.lab7_app`.
3. Скачать `google-services.json` и положить в `android/app/`.

```bash
flutter pub get
flutter run
```
