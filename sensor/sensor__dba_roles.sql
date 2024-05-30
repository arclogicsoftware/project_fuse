
create or replace view sensor__dba_roles as 
select 'role='||role name,
       null value 
  from dba_roles;