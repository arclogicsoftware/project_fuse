create or replace view sensor__session_user_programs as
select distinct
       username||','||program name,
       null value
  from gv$session;