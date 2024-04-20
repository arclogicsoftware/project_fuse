
create or replace view accounts_of_interest as
select 'RECENTLY LOCKED OR EXPIRED' reason,
       username,
       account_status,
       lock_date,
       expiry_date,
       created
  from dba_users 
 where -- Accounts that have been locked or expired in the last 30 days.
       (account_status != 'OPEN' and (nvl(lock_date, sysdate-999) > trunc(sysdate)-30 or nvl(expiry_date, sysdate-999) > trunc(sysdate)-10))
union all
select 'EXPIRING SOON',
       username,
       account_status,
       lock_date,
       expiry_date,
       created
  from dba_users 
 where -- Accounts which will expire in the next 30 days.
       (account_status = 'OPEN' and nvl(expiry_date, sysdate+999) <= trunc(sysdate)+30)
union all
select 'NEW USER',
       username,
       account_status,
       lock_date,
       expiry_date,
       created
  from dba_users 
 where -- Accounts created within the last 30 days.
       (created >= trunc(sysdate)-30)
union all
select 'LAST LOGIN > 180 DAYS',
       username,
       account_status,
       lock_date,
       expiry_date,
       created
  from dba_users
 where last_login is not null 
   and last_login < sysdate-180
   and account_status not like '%LOCKED%'
   and oracle_maintained='N'
union all
select 'NEVER LOGGED IN',
       username,
       account_status,
       lock_date,
       expiry_date,
       created
  from dba_users
 where last_login is null
   and account_status not like '%LOCKED%'
   and oracle_maintained='N'
order by 1,2,3;