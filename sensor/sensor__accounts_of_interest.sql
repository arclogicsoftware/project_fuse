create or replace view sensor__accounts_of_interest as 
select reason||': '||username||' '||account_status name,
       null value 
  from accounts_of_interest;