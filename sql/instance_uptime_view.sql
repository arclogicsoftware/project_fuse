create or replace view instance_uptime as
select inst_id,
       trunc(((sysdate)-logon_time)) || ' days ' ||
       mod(trunc(((sysdate)-logon_time)*24),24) || ' hours and ' ||
       mod(trunc(((sysdate)-logon_time)*24*60),60) || ' minutes.' uptime,
       to_char(logon_time, 'YYYY-MM-DD HH24:MI') start_time
  from gv$session
 where program like '%(PMON)%'
/

create or replace public synonym instance_uptime for instance_uptime;