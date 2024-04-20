
create or replace view sensor__dba_profiles as 
select 'profile='||profile||', name='||resource_name||', type='||resource_type name,
       limit value 
  from dba_profiles;