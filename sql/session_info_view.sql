create or replace view session_info as
select (select round(value/100/60, 1) from gv$sesstat b where statistic#=19 and sid=a.sid and inst_id=a.inst_id) cpu_min,
       round((sysdate-logon_time)*24, 1) logon_hrs,
       round(last_call_et/60, 1) last_call_min,
       sid,
       serial#,
       username,
       status,
       osuser,
       machine,
       program,
       sql_id,
       prev_sql_id,
       module,
       logon_time
  from gv$session a
 where type != 'BACKGROUND'
 order 
    by 1 desc;