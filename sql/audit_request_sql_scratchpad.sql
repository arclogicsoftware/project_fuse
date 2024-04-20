

set pages 300
set lines 140

col username format a20
col created format a12
col lock_date format a12
col account_status format a25
col current_time format a35
col db_name format a12

-- Arterra wants screenshots and .xlsx of this as part of control -02.
select username,
       created,
       lock_date,
       account_status,
       systimestamp current_time,
       (select distinct name from gv$database) db_name
  from dba_users a where oracle_maintained='N' and nvl(lock_date, sysdate) >= to_date('2023-03-01', 'YYYY-MM-DD')
 order by username;