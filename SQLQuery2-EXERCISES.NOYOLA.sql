-- LOOKING AT THE DATA

SELECT *
FROM Noyi.dbo.ASSIGNMENT;

SELECT *
FROM Noyi.dbo.EMPLOYEE;

SELECT *
FROM Noyi.dbo.JOB;

SELECT *
FROM Noyi.dbo.PROJECT;

-- LAST NAME START WITH "SMITH" FROM THE EMPLOYEE TABLE.

SELECT EMP_NUM,
	   EMP_LNAME,
	   EMP_FNAME,
	   EMP_INITIAL
FROM Noyi.dbo.EMPLOYEE
WHERE EMP_LNAME LIKE 'Smith%'
ORDER BY EMP_NUM;

-- JOINING TABLES PROJECT, EMPLOYEE AND JOB_CODE SORTED BY PROJ_VALUE.

SELECT P.PROJ_NAME,
	   P.PROJ_VALUE,
	   P.PROJ_BALANCE,
	   E.EMP_LNAME,
	   E.EMP_FNAME,
	   E.EMP_INITIAL,
	   J.JOB_CODE,
	   J.JOB_DESCRIPTION,
	   J.JOB_CHG_HOUR
FROM Noyi.dbo.PROJECT AS P
	INNER JOIN Noyi.dbo.EMPLOYEE AS E 
	ON P.EMP_NUM = E.EMP_NUM
	INNER JOIN Noyi.dbo.JOB AS J
	ON E.JOB_CODE = J.JOB_CODE
ORDER BY PROJ_VALUE;

-- JOINING TABLES PROJECT, EMPLOYEE AND JOB_CODE SORTED BY EMP_LNAME.

SELECT P.PROJ_NAME,
	   P.PROJ_VALUE,
	   P.PROJ_BALANCE,
	   E.EMP_LNAME,
	   E.EMP_FNAME,
	   E.EMP_INITIAL,
	   J.JOB_CODE,
	   J.JOB_DESCRIPTION,
	   J.JOB_CHG_HOUR
FROM Noyi.dbo.PROJECT AS P
	INNER JOIN Noyi.dbo.EMPLOYEE AS E 
	ON P.EMP_NUM = E.EMP_NUM
	INNER JOIN Noyi.dbo.JOB AS J
	ON E.JOB_CODE = J.JOB_CODE
ORDER BY EMP_LNAME;

-- DISTINCT PROJECTS IN THE ASSIGNMENT TABLE.

SELECT DISTINCT PROJ_NUM
FROM Noyi.dbo.ASSIGNMENT
ORDER BY PROJ_NUM;

-- THE TOTAL NUMBER OF HOURS WORKED FOR EACH EMPLOYEE AND THE TOTAL CHARGES STEMMING FROM THOSE HOURS WORKED.
-- SORTED BY THE EMPLOYEE NUMBER.

SELECT E.EMP_NUM,
	   E.EMP_LNAME,
	   ROUND(SUM(A.ASSIGN_HOURS),1) AS SUM_OF_ASSIGN_HOURS,
	   ROUND(SUM(A.ASSIGN_CHARGE),2) AS SUM_OF_ASSIGN_CHARGE
FROM Noyi.dbo.EMPLOYEE AS E
	INNER JOIN Noyi.dbo.ASSIGNMENT AS A
	ON E.EMP_NUM = A.EMP_NUM
GROUP BY E.EMP_NUM, E.EMP_LNAME
ORDER BY E.EMP_NUM;

-- THE TOTAL NUMBER OF HOURS AND CHARGES FOR EACH OF THE PROJECTS PRESENTED IN THE ASSIGNMENT TABLE.

SELECT PROJ_NUM,
	   ROUND(SUM(ASSIGN_HOURS),1) AS SUM_OF_ASSIGN_HOURS,
	   ROUND(SUM(ASSIGN_CHARGE),2) AS SUM_OF_ASSIGN_CHARGE
FROM Noyi.dbo.ASSIGNMENT
GROUP BY PROJ_NUM;

-- THE TOTAL NUMBER OF HOURS WORKED FOR EACH EMPLOYEE AND THE TOTAL CHARGES MADE BY ALL EMPLOYEES.

SELECT ROUND(SUM(ASSIGN_HOURS),1) AS SUM_OF_ASSIGN_HOURS,
	   ROUND(SUM(ASSIGN_CHARGE),2) AS SUM_OF_ASSIGN_HOURS
FROM Noyi.dbo.ASSIGNMENT;