set lines 120 pages 100

col program format a25 trunc head "Program"
col username format a15 trunc head "User"
col osuser format a15 trunc head "OS User"
col machine format a25 trunc head "Machine"
col min_logon_time format a12 trunc head "Min Logon"
col total_sessions format 9999 head "Sessions"
col total_processes format 9999 head "Processes"
col inst_id format 9999 head "Instance"

select inst_id,
       program,
       username,
       osuser,
       machine,
       to_char(min(logon_time), 'MONDD HH24:MI') min_logon_time,
       count(*) total_sessions
  from gv$session
 where type != 'BACKGROUND'
 group
    by inst_id,
       username,
       osuser,
       program,
       machine
 order
    by inst_id,
       program,
       username,
       osuser,
       machine;

prompt ## Background Sessions

select inst_id,
       username,
       osuser,
       machine,
       to_char(min(logon_time), 'MONDD HH24:MI') min_logon_time,
       count(*) total_sessions
  from gv$session
 where type = 'BACKGROUND'
 group
    by inst_id,
       username,
       osuser,
       machine
 order
    by inst_id,
       username,
       osuser,
       machine;

prompt ## Total Sessions

select count(*) total_sessions
  from gv$session;

select username,
       count(*) total_processes
  from gv$process
 group
    by username
/
