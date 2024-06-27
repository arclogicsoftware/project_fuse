create or replace view sensor__sparse_tables as 
select owner||'.'||table_name name,
       null value
  from sparse_tables;