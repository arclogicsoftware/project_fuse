create or replace view alert__new_accounts as
select 'warning' alert_level,
       username || ' - New account FYI!' alert_name,
       'Account created on ' || to_char(created, 'YYYY-MM-DD HH24:MI:SS') alert_info,
       'database' alert_type
  from dba_users
 where created >= sysdate - 1;
