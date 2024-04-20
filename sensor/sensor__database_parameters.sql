create or replace view sensor__database_parameters as 
select name||'_'||inst_id name,
       value
  from gv$parameter;