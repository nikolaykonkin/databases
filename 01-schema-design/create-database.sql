-- Создание базы данных (выполняется отдельно)
-- CREATE DATABASE employee_management;

-- Подключение к базе данных
-- \c employee_management;

-- Таблица типов подразделений
CREATE TABLE DepartmentTypes (
    type_id SERIAL PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица должностей
CREATE TABLE Positions (
    position_id SERIAL PRIMARY KEY,
    position_title VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица структурных подразделений
CREATE TABLE Departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(200) NOT NULL UNIQUE,
    type_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_department_type FOREIGN KEY (type_id)
        REFERENCES DepartmentTypes(type_id) ON DELETE RESTRICT
);

-- Таблица филиалов
CREATE TABLE Branches (
    branch_id SERIAL PRIMARY KEY,
    address TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица сотрудников
CREATE TABLE Employees (
    employee_id SERIAL PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    position_id INTEGER NOT NULL,
    department_id INTEGER NOT NULL,
    branch_id INTEGER NOT NULL,
    hire_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_employee_position FOREIGN KEY (position_id)
        REFERENCES Positions(position_id) ON DELETE RESTRICT,
    CONSTRAINT fk_employee_department FOREIGN KEY (department_id)
        REFERENCES Departments(department_id) ON DELETE RESTRICT,
    CONSTRAINT fk_employee_branch FOREIGN KEY (branch_id)
        REFERENCES Branches(branch_id) ON DELETE RESTRICT,
    CONSTRAINT chk_salary CHECK (salary > 0)
);

-- Таблица проектов
CREATE TABLE Projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(200) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Таблица назначений на проекты (связь многие ко многим)
CREATE TABLE EmployeeProjects (
    employee_project_id SERIAL PRIMARY KEY,
    employee_id INTEGER NOT NULL,
    project_id INTEGER NOT NULL,
    assigned_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_employeeproject_employee FOREIGN KEY (employee_id)
        REFERENCES Employees(employee_id) ON DELETE CASCADE,
    CONSTRAINT fk_employeeproject_project FOREIGN KEY (project_id)
        REFERENCES Projects(project_id) ON DELETE CASCADE,
    UNIQUE (employee_id, project_id)
);

-- Индексы для оптимизации производительности
CREATE INDEX idx_employees_position ON Employees(position_id);
CREATE INDEX idx_employees_department ON Employees(department_id);
CREATE INDEX idx_employees_branch ON Employees(branch_id);
CREATE INDEX idx_employees_hire_date ON Employees(hire_date);
CREATE INDEX idx_departments_type ON Departments(type_id);
CREATE INDEX idx_employeeprojects_employee ON EmployeeProjects(employee_id);
CREATE INDEX idx_employeeprojects_project ON EmployeeProjects(project_id);

-- Триггер для автоматического обновления updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_departmenttypes_updated_at BEFORE UPDATE ON DepartmentTypes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_positions_updated_at BEFORE UPDATE ON Positions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_departments_updated_at BEFORE UPDATE ON Departments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_branches_updated_at BEFORE UPDATE ON Branches
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_employees_updated_at BEFORE UPDATE ON Employees
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON Projects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Вставка начальных данных (из файла)

-- Добавление типов подразделений
INSERT INTO DepartmentTypes (type_name) VALUES
    ('Отдел'),
    ('Группа'),
    ('Департамент')
ON CONFLICT (type_name) DO NOTHING;

-- Добавление должностей (уникальные значения из файла)
INSERT INTO Positions (position_title) VALUES
    ('ведущий QA инженер'),
    ('специалист'),
    ('специалист по персоналу'),
    ('ведущий разработчик'),
    ('ведущий инженер'),
    ('руководитель проектов по интеграции'),
    ('старший инженер'),
    ('инженер'),
    ('руководитель сервисных проектов'),
    ('разработчик'),
    ('старший разработчик'),
    ('ведущий архитектор'),
    ('старший архитектор'),
    ('руководитель проектов'),
    ('руководитель направления разработки')
ON CONFLICT (position_title) DO NOTHING;

-- Добавление структурных подразделений
INSERT INTO Departments (department_name, type_id) VALUES
    ('Центр компетенций QA Москва', (SELECT type_id FROM DepartmentTypes WHERE type_name = 'Отдел')),
    ('Группа сервисной поддержки', (SELECT type_id FROM DepartmentTypes WHERE type_name = 'Группа')),
    ('Центр разработки продуктов для digital-маркетинга', (SELECT type_id FROM DepartmentTypes WHERE type_name = 'Отдел')),
    ('Департамент Техническая поддержка', (SELECT type_id FROM DepartmentTypes WHERE type_name = 'Департамент')),
    ('Группа CRM 2', (SELECT type_id FROM DepartmentTypes WHERE type_name = 'Группа')),
    ('Группа первичной диагностики №2', (SELECT type_id FROM DepartmentTypes WHERE type_name = 'Группа')),
    ('Группа Billing', (SELECT type_id FROM DepartmentTypes WHERE type_name = 'Группа')),
    ('Группа DOC', (SELECT type_id FROM DepartmentTypes WHERE type_name = 'Группа')),
    ('Группа ODS', (SELECT type_id FROM DepartmentTypes WHERE type_name = 'Группа')),
    ('Группа Rating', (SELECT type_id FROM DepartmentTypes WHERE type_name = 'Группа')),
    ('Центр управления сервисами', (SELECT type_id FROM DepartmentTypes WHERE type_name = 'Отдел')),
    ('Департамент FBF', (SELECT type_id FROM DepartmentTypes WHERE type_name = 'Департамент')),
    ('Центр анализа и архитектуры Medio', (SELECT type_id FROM DepartmentTypes WHERE type_name = 'Отдел')),
    ('Центр разработки Medio', (SELECT type_id FROM DepartmentTypes WHERE type_name = 'Отдел')),
    ('Группа инфраструктуры', (SELECT type_id FROM DepartmentTypes WHERE type_name = 'Группа')),
    ('Департамент Rating and Charging', (SELECT type_id FROM DepartmentTypes WHERE type_name = 'Департамент'))
ON CONFLICT (department_name) DO NOTHING;

-- Добавление филиалов (уникальные адреса)
INSERT INTO Branches (address) VALUES
    ('Приморский край, г. Владивосток, ул Нижнепортовая, д. 1'),
    ('Краснодарский край, г. Краснодар, ул Путевая, д. 1'),
    ('Ростовская обл, г. Ростов-на-Дону, ул 2-я Краснодарская, д. 135/2')
ON CONFLICT (address) DO NOTHING;

-- Добавление проектов (уникальные названия)
INSERT INTO Projects (project_name) VALUES
    ('Итэлма Инженерный корпус'),
    ('Севастополь ТВ'),
    ('Кристалл Доп объем'),
    ('Ростелеком. Гончарная'),
    ('ВТБ Башня PM'),
    ('Газпромбанк Бирюзова'),
    ('Гпб Оазис Кабинет З.'),
    ('Комплекс Pine Creek Доп работы'),
    ('Сбербанк Нижний Новгород'),
    ('Рособоронэкспорт _ PM'),
    ('Ростелеком Академик'),
    ('Оформление планировочных Итэлма'),
    ('ТМК. Сколково'),
    ('16120_1_TUL (ДС5)'),
    ('ИКСпФОН (РД)'),
    ('Европлан'),
    ('Газпромбанк Аквамарин АН'),
    ('Гурзуф'),
    ('Департамент финансов и кадров'),
    ('Пансионат Дельфин (Крым)'),
    ('Ледовая Арена Кристалл РД АИ'),
    ('Сколково'),
    ('Билайн. Ставрополь'),
    ('ТПУ Томск'),
    ('РТИ'),
    ('ИТЭЛМА'),
    ('Билайн. Нижний Новгород'),
    ('Итэлма АМО ЗИЛ'),
    ('Общественное пространство Норильск'),
    ('17110_2_TMK'),
    ('Открытие Спартаковская')
ON CONFLICT (project_name) DO NOTHING;

-- Создание представления для отчета (аналогичного исходному Excel)
CREATE OR REPLACE VIEW EmployeeReport AS
SELECT
    e.full_name AS "ФИО сотрудника",
    e.salary AS "Оклад",
    p.position_title AS "Должность",
    dt.type_name AS "Тип подразделения",
    d.department_name AS "Структурное подразделение",
    e.hire_date AS "Дата найма",
    b.address AS "Адрес филиала",
    COALESCE(
        (SELECT STRING_AGG(pr.project_name, ', ' ORDER BY pr.project_name)
         FROM EmployeeProjects ep
         JOIN Projects pr ON ep.project_id = pr.project_id
         WHERE ep.employee_id = e.employee_id),
        'Нет проектов'
    ) AS "Проект на который назначен"
FROM Employees e
JOIN Positions p ON e.position_id = p.position_id
JOIN Departments d ON e.department_id = d.department_id
JOIN DepartmentTypes dt ON d.type_id = dt.type_id
JOIN Branches b ON e.branch_id = b.branch_id
ORDER BY e.employee_id;

-- Функция для массовой загрузки данных сотрудников
CREATE OR REPLACE FUNCTION load_employee_data()
RETURNS VOID AS $$
BEGIN
    -- Суханова Арина Руслановна
    INSERT INTO Employees (full_name, salary, position_id, department_id, branch_id, hire_date)
    VALUES (
        'Суханова Арина Руслановна',
        103333.00,
        (SELECT position_id FROM Positions WHERE position_title = 'ведущий QA инженер'),
        (SELECT department_id FROM Departments WHERE department_name = 'Центр компетенций QA Москва'),
        (SELECT branch_id FROM Branches WHERE address = 'Приморский край, г. Владивосток, ул Нижнепортовая, д. 1'),
        '2013-01-20'::DATE
    );

    -- Баранов Георгий Александрович
    INSERT INTO Employees (full_name, salary, position_id, department_id, branch_id, hire_date)
    VALUES (
        'Баранов Георгий Александрович',
        12130.00,
        (SELECT position_id FROM Positions WHERE position_title = 'специалист'),
        (SELECT department_id FROM Departments WHERE department_name = 'Группа сервисной поддержки'),
        (SELECT branch_id FROM Branches WHERE address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1'),
        '2017-12-03'::DATE
    );

    -- Вишневская Виктория Матвеевна
    INSERT INTO Employees (full_name, salary, position_id, department_id, branch_id, hire_date)
    VALUES (
        'Вишневская Виктория Матвеевна',
        12130.00,
        (SELECT position_id FROM Positions WHERE position_title = 'специалист по персоналу'),
        (SELECT department_id FROM Departments WHERE department_name = 'Группа сервисной поддержки'),
        (SELECT branch_id FROM Branches WHERE address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1'),
        '2017-11-17'::DATE
    );

    -- Алексеев Константин Николаевич
    INSERT INTO Employees (full_name, salary, position_id, department_id, branch_id, hire_date)
    VALUES (
        'Алексеев Константин Николаевич',
        12366.00,
        (SELECT position_id FROM Positions WHERE position_title = 'специалист по персоналу'),
        (SELECT department_id FROM Departments WHERE department_name = 'Группа сервисной поддержки'),
        (SELECT branch_id FROM Branches WHERE address = 'Ростовская обл, г. Ростов-на-Дону, ул 2-я Краснодарская, д. 135/2'),
        '2020-06-23'::DATE
    );

    -- Лаптев Владислав Даниилович
    INSERT INTO Employees (full_name, salary, position_id, department_id, branch_id, hire_date)
    VALUES (
        'Лаптев Владислав Даниилович',
        71000.00,
        (SELECT position_id FROM Positions WHERE position_title = 'ведущий разработчик'),
        (SELECT department_id FROM Departments WHERE department_name = 'Центр разработки продуктов для digital-маркетинга'),
        (SELECT branch_id FROM Branches WHERE address = 'Ростовская обл, г. Ростов-на-Дону, ул 2-я Краснодарская, д. 135/2'),
        '2016-06-22'::DATE
    );

    -- Коновалов Даниил Матвеевич
    INSERT INTO Employees (full_name, salary, position_id, department_id, branch_id, hire_date)
    VALUES (
        'Коновалов Даниил Матвеевич',
        62000.00,
        (SELECT position_id FROM Positions WHERE position_title = 'ведущий разработчик'),
        (SELECT department_id FROM Departments WHERE department_name = 'Центр разработки продуктов для digital-маркетинга'),
        (SELECT branch_id FROM Branches WHERE address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1'),
        '2013-11-26'::DATE
    );

    -- Фролов Тимур Тимофеевич
    INSERT INTO Employees (full_name, salary, position_id, department_id, branch_id, hire_date)
    VALUES (
        'Фролов Тимур Тимофеевич',
        55000.00,
        (SELECT position_id FROM Positions WHERE position_title = 'ведущий инженер'),
        (SELECT department_id FROM Departments WHERE department_name = 'Центр разработки продуктов для digital-маркетинга'),
        (SELECT branch_id FROM Branches WHERE address = 'Ростовская обл, г. Ростов-на-Дону, ул 2-я Краснодарская, д. 135/2'),
        '2017-03-22'::DATE
    );

    -- Левина Елизавета Артёмовна
    INSERT INTO Employees (full_name, salary, position_id, department_id, branch_id, hire_date)
    VALUES (
        'Левина Елизавета Артёмовна',
        33000.00,
        (SELECT position_id FROM Positions WHERE position_title = 'руководитель проектов по интеграции'),
        (SELECT department_id FROM Departments WHERE department_name = 'Департамент Техническая поддержка'),
        (SELECT branch_id FROM Branches WHERE address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1'),
        '2013-03-10'::DATE
    );

    -- Сафонов Леонид Максимович
    INSERT INTO Employees (full_name, salary, position_id, department_id, branch_id, hire_date)
    VALUES (
        'Сафонов Леонид Максимович',
        60615.00,
        (SELECT position_id FROM Positions WHERE position_title = 'ведущий инженер'),
        (SELECT department_id FROM Departments WHERE department_name = 'Группа CRM 2'),
        (SELECT branch_id FROM Branches WHERE address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1'),
        '2013-11-23'::DATE
    );

    -- Журавлев Денис Георгиевич
    INSERT INTO Employees (full_name, salary, position_id, department_id, branch_id, hire_date)
    VALUES (
        'Журавлев Денис Георгиевич',
        33300.00,
        (SELECT position_id FROM Positions WHERE position_title = 'старший инженер'),
        (SELECT department_id FROM Departments WHERE department_name = 'Группа CRM 2'),
        (SELECT branch_id FROM Branches WHERE address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1'),
        '2016-03-26'::DATE
    );

    -- Ильина Злата Игоревна
    INSERT INTO Employees (full_name, salary, position_id, department_id, branch_id, hire_date)
    VALUES (
        'Ильина Злата Игоревна',
        33250.00,
        (SELECT position_id FROM Positions WHERE position_title = 'старший инженер'),
        (SELECT department_id FROM Departments WHERE department_name = 'Группа CRM 2'),
        (SELECT branch_id FROM Branches WHERE address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1'),
        '2016-05-13'::DATE
    );

    -- Дементьев Лев Маркович
    INSERT INTO Employees (full_name, salary, position_id, department_id, branch_id, hire_date)
    VALUES (
        'Дементьев Лев Маркович',
        31000.00,
        (SELECT position_id FROM Positions WHERE position_title = 'инженер'),
        (SELECT department_id FROM Departments WHERE department_name = 'Группа первичной диагностики №2'),
        (SELECT branch_id FROM Branches WHERE address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1'),
        '2013-03-23'::DATE
    );

    -- Шилов Глеб Николаевич
    INSERT INTO Employees (full_name, salary, position_id, department_id, branch_id, hire_date)
    VALUES (
        'Шилов Глеб Николаевич',
        32000.00,
        (SELECT position_id FROM Positions WHERE position_title = 'старший инженер'),
        (SELECT department_id FROM Departments WHERE department_name = 'Группа Billing'),
        (SELECT branch_id FROM Branches WHERE address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1'),
        '2017-10-03'::DATE
    );

    -- Еремеев Денис Степанович
    INSERT INTO Employees (full_name, salary, position_id, department_id, branch_id, hire_date)
    VALUES (
        'Еремеев Денис Степанович',
        60300.00,
        (SELECT position_id FROM Positions WHERE position_title = 'ведущий инженер'),
        (SELECT department_id FROM Departments WHERE department_name = 'Группа DOC'),
        (SELECT branch_id FROM Branches WHERE address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1'),
        '2017-10-23'::DATE
    );

    -- Тарасова Анастасия Даниловна
    INSERT INTO Employees (full_name, salary, position_id, department_id, branch_id, hire_date)
    VALUES (
        'Тарасова Анастасия Даниловна',
        33752.00,
        (SELECT position_id FROM Positions WHERE position_title = 'старший инженер'),
        (SELECT department_id FROM Departments WHERE department_name = 'Группа ODS'),
        (SELECT branch_id FROM Branches WHERE address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1'),
        '2015-12-03'::DATE
    );

    -- Высоцкая Ольга Константиновна
    INSERT INTO Employees (full_name, salary, position_id, department_id, branch_id, hire_date)
    VALUES (
        'Высоцкая Ольга Константиновна',
        55000.00,
        (SELECT position_id FROM Positions WHERE position_title = 'инженер'),
        (SELECT department_id FROM Departments WHERE department_name = 'Группа Rating'),
        (SELECT branch_id FROM Branches WHERE address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1'),
        '2017-03-16'::DATE
    );

    -- Богданова Софья Никитична
    INSERT INTO Employees (full_name, salary, position_id, department_id, branch_id, hire_date)
    VALUES (
        'Богданова Софья Никитична',
        56000.00,
        (SELECT position_id FROM Positions WHERE position_title = 'старший инженер'),
        (SELECT department_id FROM Departments WHERE department_name = 'Группа Rating'),
        (SELECT branch_id FROM Branches WHERE address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1'),
        '2017-10-03'::DATE
    );

    -- Новиков Марк Евгеньевич
    INSERT INTO Employees (full_name, salary, position_id, department_id, branch_id, hire_date)
    VALUES (
        'Новиков Марк Евгеньевич',
        65600.00,
        (SELECT position_id FROM Positions WHERE position_title = 'руководитель сервисных проектов'),
        (SELECT department_id FROM Departments WHERE department_name = 'Центр управления сервисами'),
        (SELECT branch_id FROM Branches WHERE address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1'),
        '2013-07-01'::DATE
    );

    -- Гусева Екатерина Марковна
    INSERT INTO Employees (full_name, salary, position_id, department_id, branch_id, hire_date)
    VALUES (
        'Гусева Екатерина Марковна',
        60000.00,
        (SELECT position_id FROM Positions WHERE position_title = 'разработчик'),
        (SELECT department_id FROM Departments WHERE department_name = 'Департамент FBF'),
        (SELECT branch_id FROM Branches WHERE address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1'),
        '2017-07-16'::DATE
    );

    -- Воробьев Герман Ильич
    INSERT INTO Employees (full_name, salary, position_id, department_id, branch_id, hire_date)
    VALUES (
        'Воробьев Герман Ильич',
        136000.00,
        (SELECT position_id FROM Positions WHERE position_title = 'старший разработчик'),
        (SELECT department_id FROM Departments WHERE department_name = 'Департамент FBF'),
        (SELECT branch_id FROM Branches WHERE address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1'),
        '2020-07-13'::DATE
    );

    -- Григорьева Вера Константиновна
    INSERT INTO Employees (full_name, salary, position_id, department_id, branch_id, hire_date)
    VALUES (
        'Григорьева Вера Константиновна',
        135200.00,
        (SELECT position_id FROM Positions WHERE position_title = 'ведущий архитектор'),
        (SELECT department_id FROM Departments WHERE department_name = 'Центр анализа и архитектуры Medio'),
        (SELECT branch_id FROM Branches WHERE address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1'),
        '2012-03-10'::DATE
    );

    -- Осипов Андрей Алексеевич
    INSERT INTO Employees (full_name, salary, position_id, department_id, branch_id, hire_date)
    VALUES (
        'Осипов Андрей Алексеевич',
        116600.00,
        (SELECT position_id FROM Positions WHERE position_title = 'старший архитектор'),
        (SELECT department_id FROM Departments WHERE department_name = 'Центр анализа и архитектуры Medio'),
        (SELECT branch_id FROM Branches WHERE address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1'),
        '2012-03-23'::DATE
    );

    -- Назарова Мария Альбертовна
    INSERT INTO Employees (full_name, salary, position_id, department_id, branch_id, hire_date)
    VALUES (
        'Назарова Мария Альбертовна',
        151600.00,
        (SELECT position_id FROM Positions WHERE position_title = 'ведущий разработчик'),
        (SELECT department_id FROM Departments WHERE department_name = 'Центр разработки Medio'),
        (SELECT branch_id FROM Branches WHERE address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1'),
        '2017-05-23'::DATE
    );

    -- Лаптева Анна Максимовна
    INSERT INTO Employees (full_name, salary, position_id, department_id, branch_id, hire_date)
    VALUES (
        'Лаптева Анна Максимовна',
        33000.00,
        (SELECT position_id FROM Positions WHERE position_title = 'разработчик'),
        (SELECT department_id FROM Departments WHERE department_name = 'Центр разработки Medio'),
        (SELECT branch_id FROM Branches WHERE address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1'),
        '2017-01-25'::DATE
    );

    -- Ситникова Эмилия Николаевна
    INSERT INTO Employees (full_name, salary, position_id, department_id, branch_id, hire_date)
    VALUES (
        'Ситникова Эмилия Николаевна',
        132132.00,
        (SELECT position_id FROM Positions WHERE position_title = 'старший разработчик'),
        (SELECT department_id FROM Departments WHERE department_name = 'Центр разработки Medio'),
        (SELECT branch_id FROM Branches WHERE address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1'),
        '2013-03-30'::DATE
    );

    -- Кузнецова Любовь Даниэльевна
    INSERT INTO Employees (full_name, salary, position_id, department_id, branch_id, hire_date)
    VALUES (
        'Кузнецова Любовь Даниэльевна',
        75300.00,
        (SELECT position_id FROM Positions WHERE position_title = 'старший разработчик'),
        (SELECT department_id FROM Departments WHERE department_name = 'Центр разработки Medio'),
        (SELECT branch_id FROM Branches WHERE address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1'),
        '2013-07-27'::DATE
    );

    -- Трофимов Вячеслав Романович
    INSERT INTO Employees (full_name, salary, position_id, department_id, branch_id, hire_date)
    VALUES (
        'Трофимов Вячеслав Романович',
        67100.00,
        (SELECT position_id FROM Positions WHERE position_title = 'ведущий инженер'),
        (SELECT department_id FROM Departments WHERE department_name = 'Группа инфраструктуры'),
        (SELECT branch_id FROM Branches WHERE address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1'),
        '2013-07-26'::DATE
    );

    -- Пантелеева Есения Серафимовна
    INSERT INTO Employees (full_name, salary, position_id, department_id, branch_id, hire_date)
    VALUES (
        'Пантелеева Есения Серафимовна',
        76550.00,
        (SELECT position_id FROM Positions WHERE position_title = 'руководитель проектов'),
        (SELECT department_id FROM Departments WHERE department_name = 'Департамент Rating and Charging'),
        (SELECT branch_id FROM Branches WHERE address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1'),
        '2017-03-13'::DATE
    );

    -- Зуев Георгий Ильич
    INSERT INTO Employees (full_name, salary, position_id, department_id, branch_id, hire_date)
    VALUES (
        'Зуев Георгий Ильич',
        135000.00,
        (SELECT position_id FROM Positions WHERE position_title = 'руководитель направления разработки'),
        (SELECT department_id FROM Departments WHERE department_name = 'Департамент Rating and Charging'),
        (SELECT branch_id FROM Branches WHERE address = 'Краснодарский край, г. Краснодар, ул Путевая, д. 1'),
        '2012-11-21'::DATE
    );

    -- Назначение сотрудников на проекты (на основе данных из файла)

    -- Назначение Сухановой Арины
    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Суханова Арина Руслановна'),
        (SELECT project_id FROM Projects WHERE project_name = 'Итэлма Инженерный корпус')
    );

    -- Назначение Баранова Георгия
    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Баранов Георгий Александрович'),
        (SELECT project_id FROM Projects WHERE project_name = 'Севастополь ТВ')
    );

    -- Назначение Вишневской Виктории
    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Вишневская Виктория Матвеевна'),
        (SELECT project_id FROM Projects WHERE project_name = 'Кристалл Доп объем')
    );

    -- Назначение Алексеева Константина на несколько проектов
    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Алексеев Константин Николаевич'),
        (SELECT project_id FROM Projects WHERE project_name = 'Ростелеком. Гончарная')
    );

    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Алексеев Константин Николаевич'),
        (SELECT project_id FROM Projects WHERE project_name = 'ВТБ Башня PM')
    );

    -- Назначение Лаптева Владислава
    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Лаптев Владислав Даниилович'),
        (SELECT project_id FROM Projects WHERE project_name = 'Газпромбанк Бирюзова')
    );

    -- Назначение Коновалова Даниила
    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Коновалов Даниил Матвеевич'),
        (SELECT project_id FROM Projects WHERE project_name = 'Гпб Оазис Кабинет З.')
    );

    -- Назначение Фролова Тимура
    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Фролов Тимур Тимофеевич'),
        (SELECT project_id FROM Projects WHERE project_name = 'Комплекс Pine Creek Доп работы')
    );

    -- Назначение Левиной Елизаветы
    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Левина Елизавета Артёмовна'),
        (SELECT project_id FROM Projects WHERE project_name = 'Сбербанк Нижний Новгород')
    );

    -- Назначение Сафонова Леонида
    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Сафонов Леонид Максимович'),
        (SELECT project_id FROM Projects WHERE project_name = 'Рособоронэкспорт _ PM')
    );

    -- Назначение Журавлева Дениса
    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Журавлев Денис Георгиевич'),
        (SELECT project_id FROM Projects WHERE project_name = 'Ростелеком Академик')
    );

    -- Назначение Ильиной Златы
    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Ильина Злата Игоревна'),
        (SELECT project_id FROM Projects WHERE project_name = 'Оформление планировочных Итэлма')
    );

    -- Назначение Дементьева Льва
    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Дементьев Лев Маркович'),
        (SELECT project_id FROM Projects WHERE project_name = 'ТМК. Сколково')
    );

    -- Назначение Шилова Глеба
    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Шилов Глеб Николаевич'),
        (SELECT project_id FROM Projects WHERE project_name = '16120_1_TUL (ДС5)')
    );

    -- Назначение Еремеева Дениса
    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Еремеев Денис Степанович'),
        (SELECT project_id FROM Projects WHERE project_name = 'ИКСпФОН (РД)')
    );

    -- Назначение Тарасовой Анастасии
    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Тарасова Анастасия Даниловна'),
        (SELECT project_id FROM Projects WHERE project_name = 'Европлан')
    );

    -- Назначение Высоцкой Ольги на несколько проектов
    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Высоцкая Ольга Константиновна'),
        (SELECT project_id FROM Projects WHERE project_name = 'Газпромбанк Аквамарин АН')
    );

    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Высоцкая Ольга Константиновна'),
        (SELECT project_id FROM Projects WHERE project_name = 'Гурзуф')
    );

    -- Назначение Богдановой Софьи
    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Богданова Софья Никитична'),
        (SELECT project_id FROM Projects WHERE project_name = 'Департамент финансов и кадров')
    );

    -- Назначение Новикова Марка
    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Новиков Марк Евгеньевич'),
        (SELECT project_id FROM Projects WHERE project_name = 'Пансионат Дельфин (Крым)')
    );

    -- Назначение Гусевой Екатерины
    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Гусева Екатерина Марковна'),
        (SELECT project_id FROM Projects WHERE project_name = 'Ледовая Арена Кристалл РД АИ')
    );

    -- Назначение Воробьева Германа
    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Воробьев Герман Ильич'),
        (SELECT project_id FROM Projects WHERE project_name = 'Сколково')
    );

    -- Назначение Григорьевой Веры на несколько проектов
    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Григорьева Вера Константиновна'),
        (SELECT project_id FROM Projects WHERE project_name = 'Билайн. Ставрополь')
    );

    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Григорьева Вера Константиновна'),
        (SELECT project_id FROM Projects WHERE project_name = 'ТПУ Томск')
    );

    -- Назначение Осипова Андрея
    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Осипов Андрей Алексеевич'),
        (SELECT project_id FROM Projects WHERE project_name = 'РТИ')
    );

    -- Назначение Назаровой Марии
    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Назарова Мария Альбертовна'),
        (SELECT project_id FROM Projects WHERE project_name = 'ИТЭЛМА')
    );

    -- Назначение Лаптевой Анны на несколько проектов
    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Лаптева Анна Максимовна'),
        (SELECT project_id FROM Projects WHERE project_name = 'Билайн. Нижний Новгород')
    );

    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Лаптева Анна Максимовна'),
        (SELECT project_id FROM Projects WHERE project_name = 'Итэлма АМО ЗИЛ')
    );

    -- Назначение Ситниковой Эмилии
    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Ситникова Эмилия Николаевна'),
        (SELECT project_id FROM Projects WHERE project_name = 'Общественное пространство Норильск')
    );

    -- Назначение Кузнецовой Любови
    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Кузнецова Любовь Даниэльевна'),
        (SELECT project_id FROM Projects WHERE project_name = '17110_2_TMK')
    );

    -- Назначение Трофимова Вячеслава
    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Трофимов Вячеслав Романович'),
        (SELECT project_id FROM Projects WHERE project_name = 'Открытие Спартаковская')
    );

    -- Назначение Пантелеевой Есении
    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Пантелеева Есения Серафимовна'),
        (SELECT project_id FROM Projects WHERE project_name = 'ВТБ Башня PM')
    );

    -- Назначение Зуева Георгия
    INSERT INTO EmployeeProjects (employee_id, project_id)
    VALUES (
        (SELECT employee_id FROM Employees WHERE full_name = 'Зуев Георгий Ильич'),
        (SELECT project_id FROM Projects WHERE project_name = 'Сколково')
    );

END;
$$ LANGUAGE plpgsql;

-- Выполнение загрузки данных
SELECT load_employee_data();

-- Обновление статистики планировщика после массовой загрузки
ANALYZE;

-- Проверка данных
SELECT * FROM EmployeeReport;