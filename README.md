# CRM Database Package

Общий пакет для работы с базой данных через Prisma.

## 🚀 Установка

```bash
bun install
bun run db:generate
```

## 📋 Команды

- `bun run db:generate` - генерация Prisma клиента
- `bun run db:push` - применение схемы к БД (без миграций)
- `bun run db:migrate` - создание и применение миграций
- `bun run db:studio` - открытие Prisma Studio
- `bun run db:seed` - заполнение БД тестовыми данными

## 🔗 Использование в других сервисах

### Через file: (локально)

В `package.json` сервиса:
```json
{
  "dependencies": {
    "@crm-autoservice/database": "file:../crm-autoservice-database"
  }
}
```

### Через npm/git (в продакшене)

После публикации пакета:
```json
{
  "dependencies": {
    "@crm-autoservice/database": "^1.0.0"
  }
}
```

## 📝 Изменение схемы

1. Отредактируйте `prisma/schema.prisma`
2. Примените изменения:
   ```bash
   bun run db:push        # Для разработки
   # или
   bun run db:migrate     # Для продакшена
   ```
3. Регенерируйте клиент:
   ```bash
   bun run db:generate
   ```
4. Обновите зависимости в сервисах:
   ```bash
   cd ../crm-autoservice-auth && bun install
   cd ../crm-autoservice-api && bun install
   cd ../crm-autoservice-web && bun install
   ```

## ⚠️ Важно

- Все сервисы используют **одну базу данных**
- Изменения схемы применяются **один раз** ко всей БД
- После изменения схемы нужно регенерировать клиент во всех сервисах

