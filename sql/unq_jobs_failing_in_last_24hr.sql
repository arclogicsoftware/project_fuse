create or replace view unq_jobs_failing_in_last_24hr as
select to_char(a.log_date, 'YYYY-MM-DD HH24:MI') log_date,
       a.owner,
       a.job_name,
       a.status,
       c.errors
  from dba_scheduler_job_log a,
       (select max(log_id) log_id, owner, job_name
          from dba_scheduler_job_log
         group
            by owner, job_name) b,
       dba_scheduler_job_run_details c
 where a.log_id=b.log_id
   and a.owner=b.owner 
   and a.job_name=b.job_name
   and a.log_date >= sysdate-1
   and a.owner not like 'APEX%'
   and a.owner != 'SYS'
   and a.status='FAILED'
   and a.log_id=c.log_id
 order by a.log_date desc;