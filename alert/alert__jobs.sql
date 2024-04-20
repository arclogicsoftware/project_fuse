create or replace view alert__jobs as
select 'info' alert_level,
       owner||'.'||job_name||' - '||status alert_name,
       errors alert_info,
       'jobs' alert_type
  from unq_jobs_failing_in_last_24hr;