# Участие в разработке

1. Создайте fork и отдельную ветку.
2. Не коммитьте `.cache/`, `build/`, `dist/` и upstream Firefox checkout.
3. Выполните `bash -n scripts/*.sh` и `python3 -m py_compile scripts/*.py`.
4. Для изменений браузера соберите пакет и запустите проверки из
   `docs/BUILDING.md`.
5. В Pull Request опишите влияние на приватность, брендинг и обновления.

Использовать знаки Mozilla или выдавать NeBrowser за официальный Firefox
нельзя. Сообщения об уязвимостях отправляйте по процедуре из `SECURITY.md`.
