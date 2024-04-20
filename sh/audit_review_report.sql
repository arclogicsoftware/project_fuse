set lines 170
set pages 1000
col audit_info format a90 trunc
col event_timestamp format a16
col sql_text format a60 trunc
select to_char(event_timestamp, 'YYYY-MM-DD HH24:MI') event_timestamp,
       os_username||','||userhost||','||dbusername||','||client_program_name||','||action_name||','||object_schema||','||object_name audit_info,
       sql_text
  from unified_audit_review
 where event_timestamp >= current_timestamp - interval '7' day
   and (system_privilege_used != 'CREATE SESSION' and return_code=0)
   -- Exclude datapump jobs
   and client_program_name not like '%(DW%)%'
 order
    by event_timestamp;
    