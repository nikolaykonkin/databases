# Databases: Design, SQL, Optimization, Replication, Backup

Учебный проект по реляционным базам данных: от проектирования нормализованной схемы до эксплуатации — оптимизация запросов через EXPLAIN ANALYZE, репликация Master-Slave и Master-Master, шардинг, работа с managed-кластером в облаке, стратегии резервного копирования. PostgreSQL и MySQL 8.0, развертывание в Docker и в Yandex Cloud.

## Структура

| Раздел | Тема | Стек |
|---|---|---|
| [01-schema-design](01-schema-design/) | Проектирование схемы БД в 3НФ на основе плоского Excel-отчета | PostgreSQL, PL/pgSQL |
| [02-sql-practice](02-sql-practice/) | Практика SQL: администрирование, SELECT, JOIN, агрегация | MySQL 8.0, Docker, sakila |
| [03-optimization](03-optimization/) | EXPLAIN ANALYZE, оптимизация запросов, индексы | PostgreSQL |
| [04-replication](04-replication/) | Master-Slave и Master-Master репликация | MySQL 8.0, Docker |
| [05-sharding](05-sharding/) | Вертикальный и горизонтальный шардинг | MySQL 8.0, Docker |
| [06-backup](06-backup/) | Стратегии резервного копирования, PITR, pg_dump, binlog | PostgreSQL, MySQL |
| [07-cloud-databases](07-cloud-databases/) | Managed PostgreSQL в Yandex Cloud, репликация между зонами | Yandex Cloud |

## Что реализовано

- **Проектирование схемы.** Плоский Excel-отчет разбит на 7 таблиц в 3НФ: `Employees`, `Positions`, `Departments`, `DepartmentTypes`, `Branches`, `Projects`, `EmployeeProjects`. Индексы на FK и `hire_date`, триггеры на `updated_at`, представление `EmployeeReport` через `STRING_AGG`, PL/pgSQL-функция загрузки данных.
- **Администрирование MySQL.** Развертывание в Docker, управление пользователями и правами (`CREATE USER`, `GRANT`, `REVOKE`), работа с `INFORMATION_SCHEMA`, восстановление дампа sakila.
- **SQL-запросы.** Базовые SELECT, фильтрация (LIKE, BETWEEN), сортировка, строковые функции (`SUBSTRING_INDEX`, `CONCAT`, `UPPER`, `LEFT`, `REPLACE`, `LOWER`), многотабличные JOIN, агрегация (`COUNT`, `SUM`, `AVG`), `GROUP BY` + `HAVING`, подзапросы, `CASE`, поиск записей без связанных данных через `LEFT JOIN ... IS NULL`.
- **Оптимизация.** Чтение плана запроса через EXPLAIN ANALYZE, выявление узких мест (функции на индексированных полях, устаревший синтаксис JOIN, неоптимальные условия соединений), переписывание запроса и добавление индексов. Обзор типов индексов PostgreSQL vs MySQL (GiST, SP-GiST, GIN, BRIN, partial indexes).
- **Репликация.** Master-Slave и Master-Master на MySQL 8.0 в Docker: binlog-репликация, `CHANGE MASTER TO`, чтение `SHOW MASTER STATUS` и `SHOW SLAVE STATUS`, проверка через тестовые данные.
- **Шардинг.** Вертикальный (по столбцам) и горизонтальный (по строкам) шардинг: выбор ключа, Mermaid-схема архитектуры, реализация на Docker с логикой маршрутизации.
- **Резервное копирование.** Сценарии бэкапа для финансовой компании (полный, инкрементный, PITR, мгновенное переключение через репликацию), команды `pg_dump`/`pg_restore`, `mysqldump --single-transaction --master-data`, работа с binlog через `mysqlbinlog`, автоматизация через cron и pgBackRest.
- **Managed PostgreSQL.** Кластер Yandex Cloud с хостами в двух зонах доступности, подключение через `psql` с SSL, проверка репликации через `pg_is_in_recovery()`, `pg_stat_replication`, `pg_stat_wal_receiver`.

## Стек

- **СУБД:** PostgreSQL, MySQL 8.0
- **Языки и инструменты:** SQL, PL/pgSQL, bash, Docker
- **Облако:** Yandex Cloud (Managed Service for PostgreSQL)
- **Диагностика:** EXPLAIN ANALYZE, `information_schema`, системные функции PostgreSQL
- **Документация:** Mermaid для диаграмм

## Запуск

Каждый раздел автономен. Инструкции по запуску — в README соответствующей папки:

- `01-schema-design/` — `psql -d employee_management -f create-database.sql`.
- `02-sql-practice/` — MySQL 8.0 в Docker + база sakila.
- `03-optimization/` — PostgreSQL + sakila.
- `04-replication/`, `05-sharding/` — MySQL 8.0 в Docker, несколько контейнеров.
- `06-backup/` — теоретическая часть + команды из документации.
- `07-cloud-databases/` — Yandex Cloud, консоль + psql.

## Что освоено

- Нормализация данных: переход от плоского отчета к 7 связанным таблицам в 3НФ.
- Проектирование схемы: ссылочная целостность, ограничения `CHECK` и `UNIQUE`, индексы, триггеры.
- SQL: от базовых SELECT до многотабличных JOIN, подзапросов, агрегации и вычисляемых колонок.
- Работа с метаданными: `information_schema`, системные функции PostgreSQL.
- Администрирование MySQL: пользователи, права, восстановление дампов.
- Оптимизация запросов: EXPLAIN ANALYZE, чтение плана, переписывание запроса, индексы.
- Репликация: binlog в MySQL, физическая репликация PostgreSQL, разница между Master-Slave и Master-Master.
- Шардинг: выбор ключа, вертикальное и горизонтальное разделение, маршрутизация на уровне приложения.
- Облачные БД: managed-кластер, зоны доступности, SSL, репликация между зонами.
- Резервное копирование: полное, инкрементное, PITR, работа с WAL и binlog, автоматизация.

## Границы проекта

- Все задания выполнялись в учебном формате: одна задача — одно решение. В продакшене такой набор покрывается миграциями, IaC, CI/CD и автоматическими тестами.
- Managed-кластер в Yandex Cloud развертывался для проверки и удалялся после — скриншоты сохранены как подтверждение.
- Репликация и шардинг настраивались локально в Docker без `docker-compose.yml` (для нескольких контейнеров использовались команды `docker run`).
- Секреты (пароли MySQL, root-пароли) в учебных примерах записаны в открытом виде. В продакшене — `.env`, Docker secrets, secret manager в облаке.
- Integration-тесты и CI отсутствуют.