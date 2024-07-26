set pages 100
set lines 120
set feedback off

prompt
prompt Database Info (dbinfo.sql)
prompt ===================================================================================================


set head off
column current_time format a100
select 'Current Time: '||to_char(sysdate, 'YYYY-MM-DD HH24:MI') current_time from dual;
set head on

column instance_name format a15 heading 'Instance'
column host_name format a25 heading 'Host'
column version format a15 heading 'Version'
column archiver format a15 heading 'Archiver'
column instance_role format a20 heading 'Instance Role'

SELECT
   instance_name,
   host_name,
   version,
   archiver,
   instance_role
from gv$instance
/

prompt GV$OSTATS

col inst_id format 9999999
col stat_name format a30 trunc
col value format 999999999999999
col comments format a80 trunc 

select inst_id, stat_name, value, comments from gv$osstat order by 2;


set lines 120 pages 100

col inst_id format 999
col pool format a30
col name format a30
col mbytes format 99999

select inst_id,
       pool,
       name,
       round(bytes/1024/1024, 1) mbytes
  from gv$sgastat where round(bytes/1024/1024, 1) > 0
 order
    by 4
/

set head off feed off lines 120 pages 100

col x format a60
col gb format 99999
col name format a60 trunc

select 'Estimated Total Size: '||round((select sum(bytes)/1024/1024/1024 from gv$datafile where inst_id=1 ) + 
(select sum(bytes)/1024/1024/1024 from gv$tempfile where inst_id=1), 1) || ' GB''s' x from dual;

select 'Total GB associated with datafiles including UNDO: '||round(sum(bytes)/1024/1024/1024,1) x from gv$datafile where inst_id=1;
select 'Total GB associated with tempfiles: '||round(sum(bytes)/1024/1024/1024, 1) gb from gv$tempfile where inst_id=1;

set head on

prompt
prompt UNDO Datafiles
prompt ==============
select name, round(bytes/1024/1024/1024) gb from gv$datafile where lower(name) like '%undo%';


col parameter format a40
col values format a40
SELECT parameter, value
  FROM nls_database_parameters
   WHERE parameter IN ('NLS_CHARACTERSET', 'NLS_NCHAR_CHARACTERSET');


set recsep off
set pages 100
set linesize 140

prompt
prompt Total File IO (all_filestats.sql)
prompt =================================================================
prompt File IO statistics since startup.

column dummy noprint
column fno format 9999 heading "File|No"
column file_name format a60 heading 'Name' word_wrapped
column tablespace_name format a15 heading 'Tablespace'
column physical_reads format 9,999,999.9 heading 'Reads|*1000'
column physical_writes format 9,999,999.9 heading 'Writes|*1000'
column avg_read_tim format 99.999 heading 'Avg|Rd|Tim'
column avg_write_tim format 99.999 heading 'Avg|Wt|Tim'
column last_io_time format 99.999 heading 'Last|IO|Time'

break on report
compute sum of physical_reads physical_writes on report

select
   null dummy,
   a.file# fno,
   c.file_name,
   c.tablespace_name,
   round((a.phyrds)/1000,1) physical_reads,
   round((a.phywrts)/1000,1) physical_writes,
   round(decode(a.phyrds, 0, -1, a.readtim/a.phyrds/100), 3) avg_read_tim,
   round(decode(a.phywrts,0, -1, a.writetim/a.phywrts/100), 3) avg_write_tim,
   lstiotim/100 last_io_time
from
   v$filestat a,
   dba_data_files c
where
   a.file# = c.file_id
order by 9 desc
/

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

set pages 100
set lines 100

prompt
prompt Archive Log Info (archive_log_info.sql)
prompt =================================================================

column next_time format a12 heading 'Date'
column no_created format 999 heading '#|Created'
column archived format a8 heading 'Archived'
column avg_completion_time format 999.99 heading 'Avg Copy Time|(Sec.)'
column max_completion_time format 999.99 heading 'Max Copy Time|(Sec.)'

select
   trunc(next_time) next_time,
   count(*) no_created,
   archived,
   round(avg((completion_time-next_time)*1440), 2) avg_completion_time,
   round(max((completion_time-next_time)*1440), 2) max_completion_time
from
   v$archived_log
where
   trunc(next_time) > sysdate-10
group by
   trunc(next_time), archived
order by
   1 desc
/



set lines 120 pages 100

col profile format a20
col resource_name format a40
col limit format a20

select profile,
       resource_name,
       limit
  from dba_profiles
 order
    by profile, 
       resource_name;


set lines 120 pages 500
col role format a40
col password_required format a20

select * from dba_roles;



set pages 0 feed off head off lines 120
col file_name format a120

-- datafiles
select file_name file_name from dba_data_files
union
-- redologs
select member from v$logfile
union
-- tempfiles
select file_name from dba_temp_files
union
-- controlfiles
select name from v$controlfile
 order by 1;


set pages 100

prompt
prompt Locked Accounts (locked_accounts.sql)
prompt =================================================================
prompt Returns a list of accounts that are currently locked.

column username format a20 heading "User"

select username from dba_users where lock_date is not null
/

set pages 0
set lines 120
set wrap off
set verify off
set feedback off
set recsep off

column name format a45 heading "Name"
column value format a60 heading "Value" 
column isdefault format a8 heading "Default"

prompt "Parameters (parms.sql)"

select name,
       value
from v$parameter where isdefault != 'TRUE'
 and value is not null
order by name
;

set pages 40
set feed on ver on wrap on


set pages 100
set lines 100

prompt
prompt Redo Info (redo_info.sql)
prompt =================================================================

set head on
column group# format 99 heading 'Group|No.'
column member format a30 heading 'Member'
column mb format 9999.9 heading 'Size|(Mb)'
column status format a8 heading 'Status'
column first_time_ago format 9999.9 heading 'First Time|Hours'

select
   b.group#,
   b.member,
   round(a.bytes/1024/1024) mb,
   a.status,
   round((sysdate-first_time) * 1440 / 60,1) first_time_ago
from
 v$log a,
 v$logfile b
where
 a.group# = b.group#
/



set lines 120 pages 40

col inst_id format 99
col group# format 99
col disk# format 99
col name format a10
col total_gb format 99999
col free_gb format 99999
col reads_m format 99999
col writes_m format 99999
col gb_read format 99999
col gb_written format 99999
col kb_per_write format 99999
col kb_per_read format 99999
col mode_status format a10

prompt
prompt Summary Of GV$ASM_DISK (asm_disks.sql)
prompt =================================================================

select inst_id,
       group_number group#, 
       disk_number disk#, 
       name, 
       round(total_mb/1024) total_gb, 
       round(free_mb/1024) free_gb,
       round(reads/1000000, 1) reads_m, 
       round(writes/1000000, 1) writes_m, 
       round(bytes_read/1024/1024/1024) gb_read, 
       round(bytes_written/1024/1024/1024) gb_written,
       round(bytes_written/1024/writes) kb_per_write,
       round(bytes_read/1024/reads) kb_per_read,
       mode_status
  from gv$asm_disk
 order
    by inst_id,
       group_number,
       disk_number;



-- http://gavinsoorma.com/2009/06/monitor-space-used-in-asm-disk-groups/

SET LINESIZE  145
SET PAGESIZE  9999
SET VERIFY    off
COLUMN group_name             FORMAT a20           HEAD 'Disk Group|Name'
COLUMN sector_size            FORMAT 99,999        HEAD 'Sector|Size'
COLUMN block_size             FORMAT 99,999        HEAD 'Block|Size'
COLUMN allocation_unit_size   FORMAT 999,999,999   HEAD 'Allocation|Unit Size'
COLUMN state                  FORMAT a11           HEAD 'State'
COLUMN type                   FORMAT a6            HEAD 'Type'
COLUMN total_mb               FORMAT 999,999,999   HEAD 'Total Size (MB)'
COLUMN used_mb                FORMAT 999,999,999   HEAD 'Used Size (MB)'
COLUMN pct_used               FORMAT 999.99        HEAD 'Pct. Used'

break on report on disk_group_name skip 1
compute sum label "Grand Total: " of total_mb used_mb on report

SELECT
    name                                     group_name
  , sector_size                              sector_size
  , block_size                               block_size
  , allocation_unit_size                     allocation_unit_size
  , state                                    state
  , type                                     type
  , total_mb                                 total_mb
  , (total_mb - free_mb)                     used_mb
  , ROUND((1- (free_mb / total_mb))*100, 2)  pct_used
FROM
    v$asm_diskgroup
ORDER BY
    name
/


set pages 100
set wrap off
set lines 120

prompt
prompt All Users (all_users.sql)
prompt =================================================================

column username format a30 heading "User"
column default_tablespace format a15 heading "Default|Tablespace"
column temporary_tablespace format a15 heading "Temporary|Tablespace"
column created format a12 heading "Created"
column account_status format a20 heading "Status"
column profile format a10 heading "Profile"
column expiry_date format a12 heading "Expires"
column last_login format a12 heading "Last Login"

select username,
       default_tablespace, 
       temporary_tablespace, 
       created,
       account_status,
       profile,
       expiry_date,
       to_char(last_login, 'YYYY-MM-DD') last_login
from dba_users where oracle_maintained != 'Y'
order by 1
/

SET LONG 10000
SET PAGESIZE 1000
SET LINESIZE 300
SET HEAD OFF
SET ECHO OFF
SET FEEDBACK OFF

-- Enable the inclusion of encrypted passwords in the DDL output
EXEC DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR', TRUE);
EXEC DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'PRETTY', TRUE);
EXEC DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'STORAGE', FALSE);
EXEC DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SEGMENT_ATTRIBUTES', FALSE);
EXEC DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'TABLESPACE', FALSE);
EXEC DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'CONSTRAINTS', FALSE);
EXEC DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'REF_CONSTRAINTS', FALSE);

-- Generate the DDL for all users
SELECT DBMS_METADATA.GET_DDL('USER', USERNAME) 
FROM DBA_USERS
WHERE USERNAME NOT IN ('SYS', 'SYSTEM');  

SET LONG 10000
SET PAGESIZE 1000
SET LINESIZE 300
SET HEAD OFF
SET ECHO OFF
SET FEEDBACK OFF

-- Enable the inclusion of encrypted passwords in the DDL output
EXEC DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR', TRUE);
EXEC DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'PRETTY', TRUE);
EXEC DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'STORAGE', FALSE);
EXEC DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SEGMENT_ATTRIBUTES', FALSE);
EXEC DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'TABLESPACE', FALSE);
EXEC DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'CONSTRAINTS', FALSE);
EXEC DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'REF_CONSTRAINTS', FALSE);

SET LONG 10000
SET PAGESIZE 1000
SET LINESIZE 200
SET HEAD OFF
SET ECHO OFF
SET FEEDBACK OFF
SPOOL tablespaces_ddl.sql
SELECT DBMS_METADATA.GET_DDL('TABLESPACE', tablespace_name) FROM DBA_TABLESPACES;

