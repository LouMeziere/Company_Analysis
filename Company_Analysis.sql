-- 1. Analyzing Gender Distribution Over Time

/* This query provides a breakdown of the number of male and female employees by year from 1990 onwards. 
It helps us see trends in gender distribution over time. */

SELECT 
    YEAR(d.from_date) AS calendar_year,
    e.gender,    
    COUNT(e.emp_no) AS num_of_employees
FROM     
     t_employees e         
     JOIN t_dept_emp d ON d.emp_no = e.emp_no
GROUP BY calendar_year, e.gender 
HAVING calendar_year >= 1990;



-- 2. Employee Activity and Department Membership

/* Determine which employees were active in each department over the years. 
It helps us understand the dynamics of departmental membership and employee tenure. */

SELECT
    d.dept_name,
    ee.gender,
    dm.emp_no,
    dm.from_date,
    dm.to_date,
    e.calendar_year,
    CASE 
        WHEN e.calendar_year BETWEEN YEAR(dm.from_date) AND YEAR(dm.to_date) 
        THEN 1 ELSE 0 
    END AS active
FROM 
    (SELECT YEAR(hire_date) AS calendar_year
     FROM t_employees 
     WHERE YEAR(hire_date) >= 1990
     GROUP BY calendar_year) e
    CROSS JOIN t_dept_manager dm
    JOIN t_departments d ON d.dept_no = dm.dept_no
    JOIN t_employees ee ON ee.emp_no = dm.emp_no
ORDER BY dm.emp_no, e.calendar_year;



-- 3. Average Salary by Department and Gender

/* Calculate the average salary by department and gender, providing insights 
into salary distribution before 2003. It helps to identify any disparities 
or trends in compensation */

SELECT 
    e.gender, 
    d.dept_name, 
    ROUND(AVG(s.salary), 2) AS avg_salary, 
    YEAR(s.from_date) AS calendar_year
FROM 
    t_employees e
    JOIN t_dept_emp de ON e.emp_no = de.emp_no
    JOIN t_departments d ON de.dept_no = d.dept_no
    JOIN t_salaries s ON s.emp_no = e.emp_no
GROUP BY d.dept_no, e.gender, calendar_year
HAVING calendar_year <= 2002
ORDER BY d.dept_no;



-- 4. Stored Procedure for Salary Range Analysis

/* Calculate the average salary for employees within a specific salary range */

-- Drop procedure if it exists
DROP PROCEDURE IF EXISTS prod;

-- Create procedure to analyze average salaries within a range
DELIMITER $$
CREATE PROCEDURE prod (IN param_1 FLOAT, IN param_2 FLOAT)
BEGIN
    SELECT
        d.dept_name,
        e.gender,
        ROUND(AVG(s.salary), 2) AS avg_salary
    FROM 
        t_employees e
        JOIN t_dept_emp de ON e.emp_no = de.emp_no
        JOIN t_departments d ON de.dept_no = d.dept_no
        JOIN t_salaries s ON s.emp_no = e.emp_no
    WHERE s.salary BETWEEN param_1 AND param_2
    GROUP BY d.dept_no, e.gender
    ORDER BY d.dept_no;
END $$
DELIMITER ;

-- Call the stored procedure with a salary range of 50,000 to 90,000
CALL prod(50000, 90000);





