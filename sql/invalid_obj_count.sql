set pagesize 100
set lines 100
set recsep off
set wrap off

prompt
prompt Invalid Object Count (invalid_obj_count.sql)
prompt =================================================================

column owner format a20 heading "Owner"
column object_type format a20 heading "Type"
column total  format 999999 heading "Total"
column status format a10 heading "Status"
col invalid format 999999 heading "Invalid"

select owner, object_type, count(*) total , status
  from dba_objects
 where status = 'INVALID'
 group
    by owner, object_type, status
 order 
    by owner, object_type;


