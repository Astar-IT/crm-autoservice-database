@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
echo ========================================
echo   Исправление Prisma
echo ========================================
echo.

cd /d "%~dp0"

echo [1/4] Остановка процессов Node.js и Bun...
taskkill /F /IM node.exe /T 2>nul
taskkill /F /IM bun.exe /T 2>nul
timeout /t 3 /nobreak >nul
echo ✅ Процессы остановлены

echo.
echo [2/4] Удаление node_modules...
if exist "node_modules" (
    rmdir /S /Q "node_modules" 2>nul
    if errorlevel 1 (
        echo ⚠️ Не удалось удалить полностью, повторяю через 2 секунды...
        timeout /t 2 /nobreak >nul
        rmdir /S /Q "node_modules" 2>nul
    )
    echo ✅ node_modules удален
)

echo.
echo [3/4] Установка через npm с повторами...
set MAX_ATTEMPTS=3
set ATTEMPT=1

:install_loop
echo Попытка !ATTEMPT! из !MAX_ATTEMPTS!...
set PRISMA_ENGINES_MIRROR=https://binaries.prisma.sh
call npm install
if errorlevel 1 (
    set /a ATTEMPT+=1
    if !ATTEMPT! LEQ !MAX_ATTEMPTS! (
        echo ⚠️ Попытка !ATTEMPT! не удалась ^(ECONNRESET^), повторяю через 10 секунд...
        timeout /t 10 /nobreak >nul
        goto install_loop
    ) else (
        echo ❌ Все попытки установки не удались
        echo.
        echo Это проблема с сетью при загрузке Prisma engines.
        echo Попробуйте:
        echo   1. Проверить интернет-соединение
        echo   2. Использовать VPN
        echo   3. Выполнить позже
        pause
        exit /b 1
    )
) else (
    echo ✅ Установка успешна!
    goto :generate
)

:generate
echo.
echo [4/4] Генерация Prisma клиента...
call npm run db:generate
if errorlevel 1 (
    echo ⚠️ Первая попытка не удалась, пробую напрямую...
    if exist "node_modules\.bin\prisma.cmd" (
        call node_modules\.bin\prisma.cmd generate --schema=./prisma/schema.prisma
    ) else (
        call npx --yes prisma@5.7.0 generate --schema=./prisma/schema.prisma
    )
    if errorlevel 1 (
        echo ❌ Ошибка генерации Prisma клиента
        echo.
        echo Попробуйте вручную:
        echo   npm run db:generate
        pause
        exit /b 1
    )
)

echo.
echo ✅ Prisma клиент успешно сгенерирован!
echo.
pause

