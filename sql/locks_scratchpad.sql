
select * from dba_waiters;

select session_id,
       oracle_username
,      object_name
,      decode(a.locked_mode,
              0, 'None',           /* Mon Lock equivalent */
              1, 'Null',           /* N */
              2, 'Row-S (SS)',     /* L */
              3, 'Row-X (SX)',     /* R */
              4, 'Share',          /* S */
              5, 'S/Row-X (SSX)',  /* C */
              6, 'Exclusive',      /* X */
       to_char(a.locked_mode)) mode_held
   from gv$locked_object a
   ,    dba_objects b
  where a.object_id = b.object_id
/

select /*+ ordered */
  l.type || '-' || l.id1 || '-' || l.id2  locked_resource,
  nvl(b.name, lpad(to_char(l.sid), 8)) sid, l.inst_id,
  decode(
    l.lmode,
    1, '      N',
    2, '     SS',
    3, '     SX',
    4, '      S',
    5, '    SSX',
    6, '      X'
  )  holding,
  decode(
    l.request,
    1, '      N',
    2, '     SS',
    3, '     SX',
    4, '      S',
    5, '    SSX',
    6, '      X'
  )  wanting,
  l.ctime  seconds
from
  sys.gv_$lock l,
  sys.gv_$session s,
  sys.gv_$bgprocess b
where
  s.inst_id = l.inst_id and
  s.sid = l.sid and
  -- Don't monitor locks from data pump, triggers many false alarms.
  -- Somewhere else we need to monitor for long running data pump jobs.
  s.module not like '%Data Pump%' and
  b.paddr (+) = s.paddr and
  b.inst_id (+) = s.inst_id and
  l.type not in ('MR','TS','RT','XR','CF','RS','CO','AE','BR') and
  nvl(b.name, lpad(to_char(l.sid), 4)) not in ('CKPT','LGWR','SMON','VKRM','DBRM','DBW0','MMON') order by 5, 6;
  
select * from v$session where sid in (5234, 2663, 5705, 2196, 6791, 1625);

select * from dba_datapump_jobs;

select * from v$sql where sql_id='gqdyntaz1bv4b';
   
select * from blocked_sessions;
select * from blocked_sessions_hist order by insert_time desc;

select * from alert_table order by opened desc;
   
select b.spid processid,
       a.*
  from blocked_is_blocked a,
       gv$process b
 where a.paddr=b.addr;

select * from v$session where sid=4578;

select * from v$sql where sql_id='gf4pm8pst5xx2';

select * from v$session where sid in (select blocking_instance from v$session where blocking_session_status='VALID');

select count(*), blocking_session, blocking_instance, blocking_session_status from v$session group by blocking_session, blocking_instance, blocking_session_status;

select * from v$session where blocking_session=141;

SELECT
level lock_level,
       --blocking_session_status,
      -- LPAD(' ', (level-1)*2, ' ') || NVL(s.username, '(oracle)') AS username,
             NVL(s.username, '(oracle)') AS username,
     s.osuser,
       p.spid processid,
       s.process clientpid,
       s.inst_id,
       s.sid,
       s.serial#,
       s.sql_id,
       s.machine
FROM   gv$session s,
       gv$process p
WHERE s.paddr = p.addr
--and s.inst_id = p.inst_id
and wait_time_micro > (1000000 * 60 *  1 )
and
(level > 1
OR     EXISTS (SELECT 1
               FROM   gv$session s2
               WHERE  s2.blocking_session  = s.sid
               and    s2.blocking_instance = s.inst_id))
CONNECT BY PRIOR s.sid = s.blocking_session
START WITH s.blocking_session IS NULL order by 1;
