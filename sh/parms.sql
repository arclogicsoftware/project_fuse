set pages 0
set lines 150
set verify off
set feedback off
set recsep off

column inst_id format 99
column name format a40
column value format a50
column isdefault format a8

prompt "Parameters (parms.sql)"

select inst_id,
       name,
       value,
       isdefault
from gv$parameter where lower(name) like '%&1%'
 and value is not null
order by name
;

