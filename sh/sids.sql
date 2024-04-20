set linesize 120
set pages 40
set feedback off
set recsepchar '-'
set verify off

column spid format a10 heading "SID-PID"
column inst_id format 99 heading "Inst"
column serial# format 99999 heading "Serial#"
column username format a10 heading "User"
column osuser format a10 heading "OS User"
column machine format a10 heading "Machine"
column program format a10 heading "Program"
column logon_time format a14 heading "Last Call|Logon Time"
column client_info format a20 heading "Info"
column sql_text format a98 heading "SQL"  word_wrapped

select
 a.sid ||'-'|| p.spid spid,
 a.inst_id,
 a.serial#,
 a.username,
 a.status,
 a.osuser,
 a.machine,
 a.program,
 a.last_call_et || ' ' || to_char(logon_time,'DDMON HH24:MI') logon_time,
 a.client_info,
 b.sql_text
from
 gv$session a,
 gv$sqlarea b,
 gv$process p
where
 a.sql_address = b.address(+) and
 a.sql_hash_value = b.hash_value(+) and
 a.inst_id = b.inst_id(+) and
 a.paddr = p.addr(+) and
 a.inst_id = p.inst_id(+)
order by
a.last_call_et desc
/
