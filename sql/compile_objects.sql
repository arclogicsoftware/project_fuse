set lines 120
col x format a100
set head off feed off pages 1000

spool ~compile.sql

select 'alter package '||owner||'.'||object_name||' compile'||decode(object_type, 'PACKAGE BODY', ' body', '')||';'||chr(10)||'show errors' x
  from all_objects where status='INVALID'
   and object_type in ('PACKAGE','PACKAGE BODY')
union all
select 'alter '||object_type||' '||owner||'.'||object_name||' compile;'||chr(10)||'show errors' x
  from all_objects where status='INVALID'
   and object_type in ('PROCEDURE', 'FUNCTION', 'TRIGGER');
  
set head on feed on echo on
@~compile.sql