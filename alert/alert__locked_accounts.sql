create or replace view alert__locked_accounts as
select 'warning' alert_level,
       username || ' - Account Locked' alert_name,
       'Account locked on ' || to_char(lock_date, 'YYYY-MM-DD HH24:MI:SS') alert_info,
       'database' alert_type
  from dba_users
 where lock_date >= sysdate - 1;