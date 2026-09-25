# SQL Practice: MySQL and Sakila

Практика работы с MySQL 8.0 и учебной базой данных sakila. Три подраздела покрывают администрирование СУБД, базовые SQL-запросы и работу с JOIN и агрегацией.

## Стек

- MySQL 8.0 (Docker)
- База данных sakila (стандартный демо-датасет: фильмы, актеры, магазины, аренды)
- SQL: DDL, DML, SELECT, JOIN, GROUP BY, подзапросы

## Содержание

| Подраздел | Тема | Что освоено |
|---|---|---|
| [01-intro-to-sql](01-intro-to-sql/) | Работа с данными (DDL/DML) | Развертывание MySQL в Docker, создание пользователей, выдача и отзыв прав, работа с INFORMATION_SCHEMA, восстановление дампа sakila |
| [02-select-basics](02-select-basics/) | SQL. Часть 1 | SELECT, фильтрация (LIKE, BETWEEN), сортировка, LIMIT, строковые функции (`REPLACE`, `LOWER`, `SUBSTRING_INDEX`, `CONCAT`) |
| [03-joins-aggregation](03-joins-aggregation/) | SQL. Часть 2 | JOIN (в т.ч. многотабличные), GROUP BY + HAVING, подзапросы, CASE, LEFT JOIN + IS NULL |

## Что освоено в разделе

- Развертывание MySQL 8.0 в Docker с нуля.
- Управление пользователями и правами: `CREATE USER`, `GRANT`, `REVOKE`, `SHOW GRANTS`, `FLUSH PRIVILEGES`.
- Работа с системными таблицами через `INFORMATION_SCHEMA`.
- Восстановление БД из дампа (curl + mysql).
- Базовые SQL-запросы: выборка, фильтрация, сортировка, ограничение строк.
- Строковые функции MySQL: `SUBSTRING_INDEX`, `CONCAT`, `UPPER`, `LEFT`, `REPLACE`, `LOWER`.
- Соединения таблиц: `INNER JOIN`, `LEFT JOIN`, многотабличные JOIN.
- Агрегация: `COUNT`, `SUM`, `AVG`, `GROUP BY`, `HAVING`.
- Подзапросы в `WHERE`.
- Вычисляемые колонки через `CASE`.
- Поиск записей без связанных данных через `LEFT JOIN ... IS NULL` (анти-join).

## Запуск

Каждый подраздел автономен. Инструкции по запуску — в README соответствующей папки:

- `01-intro-to-sql/` — запуск MySQL в Docker и восстановление дампа sakila.
- `02-select-basics/` — те же контейнеры, готовые SQL-запросы.
- `03-joins-aggregation/` — те же контейнеры, JOIN и агрегация.