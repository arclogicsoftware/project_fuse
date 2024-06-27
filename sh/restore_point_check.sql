

set head off
set pages 0
set lines 120
set feed off
col x format a110

select 'INFO: DB has guaranteed restore point: '||name x from v$restore_point where guarantee_flashback_database='YES';