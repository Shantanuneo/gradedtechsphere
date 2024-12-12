##TASK-1
##Identify employees with the highest total hours worked and least absenteeism.
select employeeid, employeename , sum(total_hours)+sum(overtime_hours) as hours_worked ,sum(days_absent) as absenteeism from attendance_records group by employeeid, employeename order by hours_worked desc , absenteeism asc;

##TASK-2
##Analyze how training programs improve departmental performance.
select t.department_id, avg(feedback_score) as avg_feedback, avg(case
when e.performance_score = 'Good' then 4
when e.performance_score = 'Excellent' then 5
when e.performance_score = 'Average' then 3
else null
end
) as avg_performance from training_programs t join employee_details e on t.employeeid=e.employeeid group by t.department_id;
 
 ##TASK-3
 ##Evaluate the efficiency of project budgets by calculating costs per hour worked.
 select project_assignments.project_id, project_assignments.project_name, sum(project_assignments.budget)/sum(project_assignments.hours_worked) as cost_per_hour from project_assignments group by project_assignments.project_name, project_assignments.project_id order by cost_per_hour desc;
 
 ##TASK-4
 ##Measure attendance trends and identify departments with significant deviations.
 Select e.department_id, e.employeename , a.total_hours as total_hours , avg(a.total_hours) over(partition by e.department_id) as avg_hours,
 total_hours-avg(a.total_hours) over(partition by e.department_id) as deviation
 from employee_details e join attendance_records a on e.employeeid=a.employeeid;
 
 ##TASK-5
 ##Link training technologies with project milestones to assess the real-world impact of training.
 select t.department_id, t.technologies_covered as technology, round(avg(t.feedback_score),2) as avg_feedback_score, avg(p.milestones_achieved) as avg_milestone, count(p.project_id) as project_no from training_programs t join project_assignments p on t.employeeid=p.employeeid group by t.department_id , t.technologies_covered;
 
 With Training_Technologies as (
 select 
 e.employeeid,
 e.department_id,
 t.program_id,
 t.technologies_covered,
 t.feedback_score
 from training_programs as t join employee_details as e on t.employeeid=e.employeeid
 ),
Project_performance as (
select
p.project_id,
p.employeeid,
p.milestones_achieved,
p.budget from project_assignments as p
)
select tt.technologies_covered, tt.department_id,
round(avg(tt.feedback_score),2) as avg_feed_score,
sum(pp.milestones_achieved) as total_milestones,
sum(pp.budget) as total_budget
from Training_Technologies as tt
join Project_performance as pp
on tt.employeeid=pp.employeeid
group by tt.technologies_covered, tt.department_id
order by total_milestones desc;

##TASK-6
##Identify employees who significantly contribute to high-budget projects while maintaining excellent performance scores.

#TASK-7
##Identify employees who have undergone training in specific technologies and contributed to high-performing projects using those technologies.
select p.employeeid, p.employeename,p.project_id, p.project_name, p.budget , e.performance_score from project_assignments as p join employee_details as e on p.employeeid=e.employeeid where e.performance_score='Excellent'  and p.budget > (select avg(budget) from project_assignments) order by p.budget desc;

WITH TrainedEmployees AS (
    SELECT
        e.employeeid,
        e.employeename,
        t.technologies_covered
    FROM
        employee_details e
    JOIN
        training_programs t ON e.employeeid = t.employeeid
),

HighPerformingEmployees AS (
    SELECT
        p.employeeid,
        p.project_id,
        e.performance_score
    FROM
        project_assignments p
    JOIN
        employee_details e ON e.employeeid = p.employeeid
    WHERE
        e.performance_score = 'Excellent' 
)


SELECT DISTINCT
    te.employeeid,
    te.employeename,
    te.technologies_covered,
    hpe.project_id
FROM
    TrainedEmployees te
JOIN
    HighPerformingEmployees hpe ON te.employeeid = hpe.employeeid
ORDER BY
    te.employeename, hpe.project_id;
