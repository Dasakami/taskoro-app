
# Полный README 

````markdown
# Taskoro-App

Мобильный фронтенд для проекта **Taskoro** — Flutter приложение для Android и iOS.
Этот репозиторий содержит UI, навигацию, клиентскую логику и интеграцию с бекендом Taskoro.

---

## Краткое описание
Taskoro-App — мобильный клиент, который предоставляет пользователю:
- просмотр и выполнение задач/миссий;
- социальные функции (друзья, дуэли, турниры);
- внутриигровой магазин и покупки;
- профиль, заметки, история действий;
- нотификации и офлайн-кеширование.

(Точная функциональность зависит от API бекенда `taskoro`. README рассчитан на интеграцию с REST API / WebSocket.)

---

## Быстрый старт (для разработчика)

1. Клонируем репозиторий:
```bash
git clone https://github.com/Dasakami/taskoro-app.git
cd taskoro-app
````

2. Установить Flutter (рекомендуется версия >= 3.0, проверить `flutter doctor`):

```bash
flutter doctor
```

3. Установить зависимости:

```bash
flutter pub get
```

4. Для хранения конфигурации (API URL, ключи) рекомендуется использовать `flutter_dotenv`:

* создать `.env` в корне (пример ниже),
* добавить `.env` в `.gitignore`.

5. Запуск на устройстве/эмуляторе:

```bash
flutter run
```

6. Сборка релиза:

* Android: `flutter build apk --release` или `flutter build appbundle --release`
* iOS: `flutter build ipa` (или сборка через Xcode)

---

## Рекомендуемая структура конфигурации (пример `.env`)

```
API_BASE_URL=https://api.taskoro.example
WS_URL=wss://ws.taskoro.example
ENV=development
GOOGLE_MAPS_API_KEY=...
SENTRY_DSN=...
```

Как загружать (`flutter_dotenv`):

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}
```

---

## Рекомендации по архитектуре и состоянию

(Если проект ещё не определился с архитектурой — выбрать один из вариантов и придерживаться его)

1. State management:

   * **Riverpod** — современно, тестируемо, удобное DI.
   * **Bloc** — если нужна явная event/state логика.
   * **Provider** — простая альтернатива (если команда маленькая).

2. Network:

   * `dio` — для HTTP (интерсепторы, retry, timeouts).
   * `http` — проще, но меньше возможностей.
   * Использовать `flutter_secure_storage` для токенов, `shared_preferences` — для less-sensitive кеша.

3. Архитектурные слои:

   * `presentation/` — экраны, виджеты.
   * `domain/` — бизнес-модели, сервисы, интерфейсы.
   * `data/` — реализации репозиториев, remote/local data sources (API, SQLite).
   * `core/` — конфиги, утилиты, theme, localization.

---

## API & интеграция (как и куда подключать)

1. **Базовый контракт**:

   * В корне создать `lib/config/api.dart`:

     ```dart
     final String baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://api.example';
     ```
   * Централизованный `ApiService` (dio) с интерсептором для `Authorization` и refresh token flow.

2. **Эндпоинты (минимум)**:

   * `POST /auth/login` — получить access & refresh.
   * `POST /auth/refresh` — обновление токена.
   * `GET /tasks` — список задач.
   * `GET /tasks/{id}` — детали задачи.
   * `POST /tasks/{id}/complete` — пометка выполнено.
   * `GET /user/profile`, `PUT /user/profile` — профиль.
   * `GET /friends`, `POST /friends/invite` — друзья.
   * `GET /duels`, `POST /duels/challenge` — дуэли.
   * `GET /shop`, `POST /shop/buy` — магазин.
   * Event/WS: `wss://...` — опционально для live-дуэлей/уведомлений.

3. **Ошибки и поведение**:

   * Сервер возвращает коды 4xx/5xx — централизованная обработка в `ApiService`.
   * Если access token expired — тригер refresh, затем повтор запроса.

---

## Экранная карта (какие экраны и что в них)


* Onboarding / Welcome — быстрый старт, объяснение механик.
* Auth: Login / Register / Forgot Password.
* Home / Feed — список доступных задач/событий.
* Task Detail — описание, чеклисты, выполнение, доказательства.
* Create Task — UI для создания кастомных задач (если доступно).
* Duels / Tournaments — создать вызов, принять, смотреть результаты.
* Friends — список, приглашения, профиль друга.
* Shop — товары, покупки, баланс.
* Profile — статистика пользователя, настройки.
* Notes — личные записи.
* History / Activity — журнал действий.
* Settings — аккаунт, уведомления, privacy.
* Notifications — пуши и внутриигровые оповещения.

---

## Offline / caching

* Использовать `sqflite` / `floor` / `hive` для локального кеша задач и профиля.
* Показывать кешированные данные при отсутствии сети + индикатор «offline».
* Синхронизация: очередь локальных изменений, retry при восстановлении сети.

---

## Безопасность

* Никогда не хранить access token в plain SharedPreferences — использовать `flutter_secure_storage`.
* Не коммитить `.env` с секретами.
* HTTPS для всех запросов.
* Минимальные права Android/iOS.

---

## Тестирование

* Unit tests: business logic (`domain`).
* Widget tests: экраны с key-виджетами.
* Integration tests: end-to-end (flutter\_driver / integration\_test).
* Запуск тестов:

```bash
flutter test
flutter drive --target=test_driver/app.dart
```

---

## CI / CD (рекомендация)

* GitHub Actions:

  * `on: [push, pull_request]`
  * Шаги: checkout → flutter action → `flutter pub get` → `flutter analyze` → `flutter test` → (build apk for release on tag).
* Автоматическая сборка release на tag + выгрузка в Firebase App Distribution / Play Store (через fastlane).

---

## Code style и инструменты

* Dart format: `dart format .`
* Analyzer: `flutter analyze`
* Linter rules: `analysis_options.yaml` (уже в репозитории) — привести к единому стандарту.
* Pre-commit hooks: `melos` / `pre-commit` или просто CI.

---

## Сборка релизов (коротко)

* Android: настроить `keystore`, прописать `key.properties`, собрать `aab` для Play Store.
* iOS: настроить provisioning profiles, сертификаты, собрать в Xcode.

---

## Лицензия и права

* Добавьте `LICENSE` (MIT/Apache2) — без лицензии проект по умолчанию proprietary.

---

## Contribution

1. Форк → branch `feature/xxx` → PR → Review → merge.
2. Описывать в PR что изменено и запускать тесты.
3. Добавить `CONTRIBUTING.md` с правилами.

---

## TODOs / быстрые улучшения (приоритеты)

1. (High) Интеграция с бекендом: реализовать `ApiService`, endpoints.
2. (High) Auth flow + secure storage.
3. (Med) State management: выбрать Riverpod/Bloc.
4. (Med) Basic screens: Home, TaskDetail, Profile, Shop.
5. (Low) Offline caching + sync.
6. (Low) CI (GH Actions) + unit tests.

---

## Контакты

Автор/владелец: **Dasakami**
GitHub: [https://github.com/Dasakami](https://github.com/Dasakami)


```

Email: dendasakami@gmail.com
Telegram: @dandasakami

```

# Roadmap для Taskoro-App (шаги + оценки)

## Милистоун 1 — Базовая разработка и интеграция (1–2 недели)

* Установить окружение, зависимости, добавить `.env.example`. (0.5 д)
* Реализовать ApiService (Dio) + авторизация (login/refresh). (1–2 д)
* Экран Login / Logout / Profile (view). (1 д)
* Интеграция с бекендом: GET /tasks, GET /user/profile (endpoints). (1–2 д)

## Милистоун 2 — Основной функционал (2–3 недели)

* Home: список задач с пагинацией и pull-to-refresh. (2 д)
* Task Detail: показ деталей + кнопка Complete (POST). (2 д)
* Offline cache: хранение списка задач (Hive/SQFlite). (2–3 д)
* State management: внедрить Riverpod/Bloc для централизованной логики. (1–2 д)

## Милистоун 3 — Социальные фишки и экономика (2–3 недели)

* Friends: list, invite, accept. (2 д)
* Duels & Tournaments: интерфейс вызова и просмотра результатов (basic). (3–4 д)
* Shop: просмотр товаров и покупка (интеграция с платежами/балансом). (3–4 д)

## Милистоун 4 — Полировка, тесты, CI (1–2 недели)

* Widget и unit тесты (покрытие ключевой логики). (2–3 д)
* Добавить GitHub Actions: analyze + test + build. (1–2 д)
* Настроить релизные сборки (keystore, iOS provisioning). (2–3 д)

## Милистоун 5 — Продвинутые фичи (по желанию)

* Реалтайм через WebSocket для дуэлей/уведомлений (2–5 д)
* Analytics, Sentry, A/B tests (2–3 д)
* Локализация (i18n) и themes (1–2 д)


