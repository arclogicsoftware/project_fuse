
create or replace view stat__dba_sched_job_run_dtl as
select 'job_failures_in_last_hr' stat_name,
       'scheduled_jobs' stat_group,
       'value' stat_type,
       count(*) value,
       null tags,
       null value_convert,
       null stat_label
  from dba_scheduler_job_run_details
 where actual_start_date >= localtimestamp-(1/24)
   and status='FAILED'
union all
select 'distinct_jobs_with_failures_in_last_hr' stat_name,
       'scheduled_jobs' stat_group,
       'value' stat_type,
       count(distinct owner||' ' ||job_name) value,
       null tags,
       null value_convert,
       null stat_label
  from dba_scheduler_job_run_details
 where actual_start_date >= localtimestamp-(1/24)
   and status='FAILED';