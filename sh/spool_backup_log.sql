
column x format a160

set pages 0
set head off
set feed off
set lines 180 
set ver off
set trims on

prompt
prompt
prompt RMAN_BACKUP_JOB_DETAILS for Prior Day
prompt

spool backup_log.log append

select (select max(name) from gv$database)||', '||to_char(end_time, 'YYYY-MM-DD HH24:MI')||', '||
       input_type||', '||
       output_device_type||', '||
       status||', '||
       trim(to_char(round(input_bytes/1024/1024/1024), '0000'))||'/'||trim(to_char(round(output_bytes/1024/1024/1024), '0000'))||' GB IN/OUT, '||
       trim(to_char(round(elapsed_seconds/60/60, 1), '00'))||' HRS'  x
  from v$rman_backup_job_details 
 where input_type not in ('ARCHIVELOG', 'SPFILE')
   and trunc(end_time)=trunc(sysdate-1)
 order by 1;
 
select (select max(name) from gv$database)||', '||to_char(end_time, 'YYYY-MM-DD HH24:MI')||', '||
       input_type||', '||
       output_device_type||', '||
       status||', '||
       trim(to_char(round(input_bytes/1024/1024/1024), '0000'))||'/'||trim(to_char(round(output_bytes/1024/1024/1024), '0000'))||' GB IN/OUT, '||
       trim(to_char(round(elapsed_seconds/60/60, 1), '00'))||' HRS'  x
  from v$rman_backup_job_details 
 where input_type not in ('DB INCR', 'DB FULL')
   and trunc(end_time)=trunc(sysdate-1)
 order by 1;

 spool off

 