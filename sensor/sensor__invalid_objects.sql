create or replace view sensor__invalid_objects as 
select owner||'.'||object_name||' ['||object_type||']' name,
       to_char(last_ddl_time, 'YYYY-MM-DD HH24:MI') value
  from dba_objects
 where status='INVALID';