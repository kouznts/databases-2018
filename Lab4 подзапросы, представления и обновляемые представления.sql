﻿-- выбрать все занятия, проходящие раньше по времени, чем первое (последнее) занятие, которое преподает Сдлвьдлычин М.А.
-- в двух запросах используются вложенные SELECT, в которых применены операторы ALL и ANY
SELECT n AS 'День недели',
	  Время,
	  ФИО_преподавателя,
	  Название_дисциплины,
	  Номер_аудитории,
	  Номер_корпуса
FROM Занятие
	 JOIN Дисциплина ON Дисциплина.Код_дисциплины = Занятие.Код_дисциплины
	 JOIN Преподаватель ON Преподаватель.Номер_табеля = Занятие.Номер_табеля
	 JOIN Weekdays ON Weekdays.d = Занятие.День_недели
WHERE Время < ALL(SELECT Время FROM Занятие
	 WHERE Номер_табеля = 101001);

SELECT n AS 'День недели',
    Время,
    ФИО_преподавателя,
    Название_дисциплины,
    Номер_аудитории,
    Номер_корпуса
FROM Занятие
    JOIN Дисциплина ON Дисциплина.Код_дисциплины = Занятие.Код_дисциплины
    JOIN Преподаватель ON Преподаватель.Номер_табеля = Занятие.Номер_табеля
    JOIN Weekdays ON Weekdays.d = Занятие.День_недели
WHERE Время < ANY(SELECT Время FROM Занятие WHERE Номер_табеля = 101001);

-- выбрать все группы студентов, у которых есть занятия с заданным преподавателем (Ватутин И.Н.)
-- запрос сконструирован так, чтобы использовался оператор EXISTS
SELECT DISTINCT Номер_группы
FROM Занятие
WHERE EXISTS (
	SELECT Номер_группы
	FROM Занятие
	WHERE Z1.Номер_группы = Занятие.Номер_группы AND Номер_табеля = 18923
);

/* создать представление, в которое включить все занятия, 
проходящие раньше по времени, чем первое (последнее) занятие, 
которое преподает Сдавельчин М.А. */
CREATE VIEW ViewAll AS
SELECT n AS 'День недели',
    Время,
    ФИО_преподавателя,
    Название_дисциплины,
    Номер_аудитории,
    Номер_корпуса
FROM Занятие
    INNER JOIN Дисциплина ON Дисциплина.Код_дисциплины = Занятие.Код_дисциплины
    INNER JOIN Преподаватель ON Преподаватель.Номер_табеля = Занятие.Номер_табеля
    INNER JOIN Weekdays ON Weekdays.d = Занятие.День_недели
WHERE Время < ALL(SELECT Время FROM Занятие WHERE Номер_табеля = 101001)

-- создать представления с выборкой, сортировкой, группировкой, левым, правым и внешним объединением.
-- ORDER BY использоваться в представлениях НЕ МОЖЕТ
CREATE VIEW Число_часов_Сдавельчин AS
SELECT 
    ФИО_преподавателя AS 'ФИО преподавателя',
    COUNT(*)*2 AS 'Число часов'
FROM Занятие
    JOIN Преподаватель ON Преподаватель.Номер_табеля = Занятие.Номер_табеля
GROUP BY ФИО_преподавателя
HAVING ФИО_преподавателя LIKE 'Сдав%'

CREATE VIEW Дисциплина_которой_не_учат AS
SELECT Название_дисциплины
FROM Занятие RIGHT OUTER JOIN Дисциплина ON Занятие.Код_дисциплины = Дисциплина.Код_дисциплины
WHERE Время IS NULL;
go

CREATE VIEW Дисциплина_которой_не_учат_2 AS
SELECT Название_дисциплины
FROM Дисциплина LEFT OUTER JOIN Занятие ON Занятие.Код_дисциплины = Дисциплина.Код_дисциплины
WHERE Время IS NULL;
go

CREATE VIEW Дисциплина_которой_не_учат_3 AS
SELECT Название_дисциплины
FROM Дисциплина FULL OUTER JOIN Занятие ON Занятие.Код_дисциплины = Дисциплина.Код_дисциплины
WHERE Время IS NULL;

-- создать обновляемые представления для всех таблиц, реализовать запросы INSERT, UPDATE, DELETE для представлений
CREATE VIEW Занятие_в_пн AS
SELECT *
FROM Занятие
WHERE День_недели = 1
WITH CHECK OPTION;

INSERT INTO Занятие_в_пн VALUES
('09:45', 1, 212211, 1002, 413, 5, 11);

/* При попытке выполнения вышеприведенного запроса Microsoft SQL Server сгенерировал ошибку: 
«Ошибка при попытке вставки или обновления, поскольку целевое представление либо указывает WITH CHECK OPTION, 
либо охватывает представление, которое указывает WITH CHECK OPTION, а одна или несколько строк, 
получающиеся при операции, не определены в рамках ограничения CHECK OPTION» */
/* Дело в том, что в приведенном примере производится попытка добавить в представление занятие, 
проходящее во вторник, а это не соответствует условию WHERE. Итак, CHECK OPTION необходим, 
чтобы в таблицу, для которой создано представление, можно было добавить только такие строки, 
которые согласуются с заданным предикатом в представлении (с условием WHERE).
*/
INSERT INTO Занятие_в_пн VALUES
('11:30', 2, 212211, 1002, 413, 5, 11);

/* заметим, что строку в исходной таблице с такими же группой и временем, 
но другим днем недели (вторник) UPDATE не затронул */
UPDATE Занятие_в_пн
SET Номер_аудитории = 415,
Номер_корпуса = 5
WHERE Время = '9:45' AND Номер_группы = 11

-- Представления для остальных таблиц:
CREATE VIEW Ауд_Предс AS
SELECT *
FROM Аудитория
WITH CHECK OPTION;
go

CREATE VIEW Преп_Предс AS
SELECT *
FROM Преподаватель
WITH CHECK OPTION;
go

CREATE VIEW Группа_Предс AS
SELECT *
FROM Группа_студентов
WITH CHECK OPTION;
go

CREATE VIEW Дисц_Предс AS
SELECT *
FROM Дисциплина
WITH CHECK OPTION;
Go