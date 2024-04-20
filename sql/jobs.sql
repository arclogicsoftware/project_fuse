set recsep off
set lines 120
set pages 40
set wrap off

prompt
prompt DBA_JOBS 
prompt ===================================================================================================
prompt Returns list of jobs from dba_jobs.

column schema_user heading "Schema" format a10
column job heading 'Job' format 99999
column last_date heading 'Last' format a20 word_wrapped
column next_date heading 'Next' format a20 word_wrapped
column total_time heading 'Hours' format 9999.9
column failures heading 'Fails' format 9999
column what format a25 heading 'What' 
column broken heading 'Broke' format a5

select 
 schema_user,
 job, 
 decode(last_date, NULL, NULL, to_char(last_date, 'DD-MON-RR HH24:MI:SS')) last_date,
 decode(next_date, NULL, NULL, to_char(next_date, 'DD-MON-RR HH24:MI:SS')) next_date,
 round(total_time/60/60,1) total_time,
 failures, 
 what, 
 broken from dba_jobs
/


prompt
prompt DBMS_SCHEDULER JOBS 
prompt ===================================================================================================
prompt Returns list of jobs from dba_scheduler_jobs.


col job_name format a30
col job_action format a30
col enabled format a10
col run_count format 9999
col failure_count format 9999
col last_start_date format a20

select job_name, 
       job_action, 
       enabled, 
       run_count, 
       failure_count, 
       to_char(last_start_date, 'YYYY-MM-DD HH24:MI') last_start_date 
  from dba_scheduler_jobs
 order
    by job_name;



