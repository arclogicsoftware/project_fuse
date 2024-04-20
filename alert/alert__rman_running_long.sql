create or replace view alert__rman_running_long as 
select elapsed_minutes value 
  from rman_backup_job_details
 where status='RUNNING'
   and elapsed_minutes=(8*60);