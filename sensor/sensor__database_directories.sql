create or replace view sensor__database_directories as 
select owner||'.'||directory_name||'_'||origin_con_id name,
       directory_path value 
  from dba_directories;