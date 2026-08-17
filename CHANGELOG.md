# Changelog

## 0.1.1 — 2026-08-17

- Убраны Mozilla Account/Sync, AI, рекомендации, рекламные new-tab поверхности и лишние элементы по умолчанию.
- Normandy и Health Report исключены из сборки; JPEG XL отключён.
- Исправлена критичная регрессия раннего lean-профиля: DevTools runtime сохранён, чтобы работали стартовая страница и меню браузера.
- Улучшена воспроизводимость сборки в обычном macOS Terminal: проверки больше не требуют ripgrep.

## 0.1.0 — 2026-08-16

- Первая сборка NeBrowser на Firefox 153.0.4 для macOS Apple Silicon.
- Добавлены собственные имя, bundle ID, иконка и about-брендинг.
- Стартовая страница изменена на `https://affpapa.org/`.
- Отключены Mozilla Telemetry, Studies, Normandy, Crash Reporter и updater.
- Добавлены воспроизводимые build, packaging, verification и Direct release
  сценарии.
