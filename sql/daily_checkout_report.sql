column name format a30
column log_mode format a15
column remote_archive format a15
column platform_name format a20
column cdb format a5
column con_id format 999

select name, log_mode, remote_archive, platform_name, cdb, con_id from gv$database;

column instance_name format a20
column host_name format a20
column version_full format a30
column status format a10
column edition format a10
column startup_time format a20
column current_time format a20

select instance_name, host_name, version_full, status, edition, to_char(startup_time, 'yyyy-mm-dd hh24:mi') startup_time, to_char(sysdate, 'yyyy-mm-dd hh24:mi') current_time from gv$instance;

column current_pdb format a30

select sys_context('userenv', 'con_name') as current_pdb from dual;

column object_size_gb format 999,999,999.99
column datafile_size_gb format 999,999,999.99
column autoextend_size_gb format 999,999,999.99
column estimated_yearly_growth_gb format 999,999,999.99

select sum(objects_gb) object_size_gb, sum(datafile_gb) datafile_size_gb, sum(can_extend_gb) autoextend_size_gb, sum(gb_per_day)*365 estimated_yearly_growth_gb from tsinfo;

column tablespace_name format a30
column objects_gb format 999,999,999
column datafile_gb format 999,999,999
column free_gb format 999,999,999.9
column pct_full format 999.9
column gb_per_day format 999,999,999.99
column estimated_days_remaining format 999,999,999 heading "~DAYS REMAINING"
column datafile_max_gb format 999,999,999.9
column autoextend_pct_full format 999
column can_extend_gb format 999,999,999.9
column max_days_remaining format 999,999,999 heading "~MAX DAYS REMAINING"

select * from tsinfo order by 6 desc;

column date format a10
column "00" format 999
column "01" format 999
column "02" format 999
column "03" format 999
column "04" format 999
column "05" format 999
column "06" format 999
column "07" format 999
column "08" format 999
column "09" format 999
column "10" format 999
column "11" format 999
column "12" format 999
column "13" format 999
column "14" format 999
column "15" format 999
column "16" format 999
column "17" format 999
column "18" format 999
column "19" format 999
column "20" format 999
column "21" format 999
column "22" format 999
column "23" format 999

select * from archive_log_dist order by 1 desc;

column state format a10
column last_start format a16
column next_run format a16
column repeat_interval format a10
column schedule_type format a15
column job_creator format a15
column job_name format a10
column owner format a15
column failure_count format 99999
column run_count formaT 99999

select state,
       to_char(last_start_date, 'YYYY-MM-DD HH24:MI') last_start,
       to_char(next_run_date, 'YYYY-MM-DD HH24:MI') next_run,
       substr(repeat_interval, 1, 10) repeat_interval,
       schedule_type,
       job_creator,
       substr(job_name, 1, 10) job_name,
       owner,
       failure_count,
       run_count
  from dba_scheduler_jobs
 order 
    by state, owner, last_start;
