create or replace view sensor__tablespaces as
select tablespace_name name,
       status value
  from dba_tablespaces;