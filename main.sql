--Вывести идентификаторы курсов (предметов).

SELECT courseid from course

--Вывести всю информацию о курсах (предметах).
SELECT * from course

--Вывести идентификатор курса с названием "Machine Learning".
SELECT courseid from course
WHERE coursetitle='Machine Learning'

--Вывести название курса с идентификатором 5.
SELECT coursetitle from course
WHERE courseid=5

--Вывести список мобильных телефонов (PhoneType = 'cell') из таблицы "PHONE_LIST".
SELECT phone FROM PHONE_LIST
WHERE PhoneType = 'cell'

--Вывести количество отметок, которое получил студент с идентификатором (номером зачетки) 345576.
SELECT COUNT(exam_result.grade) FROM students
LEFT JOIN exam_result ON students.studentid = exam_result.studentid
WHERE students.studentid=345576
GROUP BY students.studentid

--Вывести номера зачеток (идентификаторы студентов) и средние баллы, которые получили студенты за все экзамены.
SELECT studentid, AVG(exam_result.grade) FROM exam_result
GROUP BY studentid

--Вывести минимальный и максимальный баллы, полученные студентами на экзаменах.
SELECT MIN(grade), MAX(grade) FROM exam_result

--Найти пересечение идентификаторов студентов, получавших и 2, и 5. Каждый идентификатор из пересечения должен встречаться не более одного раза.
SELECT studentid FROM exam_result
WHERE grade in (2, 5)
GROUP BY studentid
HAVING SUM(grade) = 7

--Найти объединение идентификаторов студентов, у которых есть хоть одна двойка и/или хоть одна пятерка. Каждый идентификатор из пересечения должен встречаться не более одного раза.
SELECT studentid FROM exam_result
WHERE grade in (2, 5)
GROUP BY studentid
ORDER BY studentid



