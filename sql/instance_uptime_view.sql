create or replace view instance_uptime as
select inst_id,
       trunc(((sysdate)-startup_time)) || ' days ' ||
       mod(trunc(((sysdate)-startup_time)*24),24) || ' hours and ' ||
       mod(trunc(((sysdate)-startup_time)*24*60),60) || ' minutes.' uptime,
       to_char(startup_time, 'YYYY-MM-DD HH24:MI') start_time
  from gv$instance
/

create or replace public synonym instance_uptime for instance_uptime;