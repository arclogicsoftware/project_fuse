set serveroutput on
set head off
set feed off
set verify off
set term off
set lines 120
set pages 0
spool standby_lag.log append

select to_char(sysdate, 'YYYYMMDD')||','||to_char(sysdate, 'HH24MISS')||','||name||' ('||sys_context('userenv', 'db_name')||' '||inst_id||'),'||round(((extract(day from val)*86400)+(extract(hour from val)*3600)+(extract(minute from val)*60)+(extract(second from val)))/60) x
  from (
select to_dsinterval(value) val,
      a.*
      from gv$dataguard_stats a where name in ('transport lag', 'apply lag'));

select to_char(sysdate, 'YYYYMMDD')||','||to_char(sysdate, 'HH24MISS')||',archive_log_lag ('||sys_context('userenv', 'db_name')||' '||inst_id||'),'||mins x
  from (
select inst_id,
       round((sysdate-max(next_time))*24*60) mins
  from gv$archived_log
 where next_time is not null
   and applied != 'NO'
 group
    by inst_id);

spool off

