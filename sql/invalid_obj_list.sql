set pagesize 100
set lines 100
set recsep off
set wrap off

prompt 
prompt Invalid Objects (invalid_objects.sql)
prompt =================================================================
prompt Returns a list of invalid database objects.

column owner format a8 heading 'User'
column object_name format a35 heading 'Name' word_wrapped
column object_type format a8 heading 'Type'
column last_ddl_time format a10 heading 'Last DDL'
column status format a8 heading 'Status'

select 
owner, 
object_name, 
object_type, 
to_char(last_ddl_time, 'DD-MON-RR') last_ddl_time, 
status 
from 
dba_objects 
where status != 'VALID'
order by 1,2
/
set wrap on


