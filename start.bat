@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
echo ========================================
echo   CRM Database Package
echo ========================================
echo.

cd /d "%~dp0"

echo [1/2] Установка зависимостей...
set PRISMA_ENGINES_MIRROR=https://binaries.prisma.sh
set MAX_ATTEMPTS=5
set ATTEMPT=1

:install_loop
echo Попытка !ATTEMPT! из !MAX_ATTEMPTS!...
call bun install
if errorlevel 1 (
    set /a ATTEMPT+=1
    if !ATTEMPT! LEQ !MAX_ATTEMPTS! (
        echo ⚠️ Попытка !ATTEMPT! не удалась ^(ECONNRESET^), повторяю через 10 секунд...
        timeout /t 10 /nobreak >nul
        goto install_loop
    ) else (
        echo ⚠️ Все попытки через bun не удались, пробую через npm...
        call npm install
        if errorlevel 1 (
            echo ❌ Ошибка установки зависимостей
            echo.
            echo Это проблема с сетью при загрузке Prisma engines.
            echo Попробуйте:
            echo   1. Запустить fix-prisma.bat
            echo   2. Проверить интернет-соединение
            echo   3. Использовать VPN
            echo   4. Выполнить вручную: npm install
            pause
            exit /b 1
        )
    )
) else (
    echo ✅ Установка успешна!
    goto :generate
)

:generate
echo.
echo [2/2] Генерация Prisma клиента...
set PRISMA_ENGINES_MIRROR=https://binaries.prisma.sh
if not exist "node_modules\.prisma" mkdir "node_modules\.prisma"
if exist "node_modules\.bin\prisma.cmd" (
    call node_modules\.bin\prisma.cmd generate
) else (
    call bun run db:generate
    if errorlevel 1 (
        call npx --yes prisma@5.7.0 generate
    )
)
if errorlevel 1 (
    echo ⚠️ Первая попытка не удалась, повторяю через 5 секунд...
    timeout /t 5 /nobreak >nul
    if exist "node_modules\.bin\prisma.cmd" (
        call node_modules\.bin\prisma.cmd generate
    ) else (
        call npx --yes prisma@5.7.0 generate
    )
    if errorlevel 1 (
        echo ⚠️ Вторая попытка не удалась...
        if errorlevel 1 (
            echo ❌ Ошибка генерации Prisma клиента
            echo.
            echo Это может быть временная проблема с сетью.
            echo Попробуйте:
            echo   1. Запустить fix-prisma-network.bat
            echo   2. Использовать VPN
            echo   3. Выполнить вручную: npx prisma@5.7.0 generate --schema=./prisma/schema.prisma
            pause
            exit /b 1
        )
    )
)

echo.
echo ✅ Готово! Prisma клиент сгенерирован.
echo.
echo Доступные команды:
echo   bun run db:push      - Применить схему к БД
echo   bun run db:migrate   - Создать миграцию
echo   bun run db:studio    - Открыть Prisma Studio
echo.
pause

