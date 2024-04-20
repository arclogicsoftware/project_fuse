create or replace view sensor__database_accounts as 
select username name,
       account_status value
  from dba_users;