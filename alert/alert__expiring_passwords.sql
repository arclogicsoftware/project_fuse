create or replace view alert__expiring_passwords as
select 'warning' alert_level,
       username || ' - Password Expiring Soon' alert_name,
       'Password expires on ' || to_char(expiry_date, 'YYYY-MM-DD HH24:MI:SS') alert_info,
       'expiring_password' alert_type
  from dba_users
 where expiry_date <= sysdate + 1
   and expiry_date > sysdate;
