
create or replace public synonym unified_audit_review for unified_audit_review;
  
create or replace view unified_audit_review as
-- APP_AUDIT_DB_SCHEMA_CHANGES
select unified_audit_policies, os_username, userhost, terminal, dbusername, client_program_name, event_timestamp, action_name, return_code, object_schema, object_name, sql_text, system_privilege_used 
  from unified_audit_trail 
 where event_timestamp >= current_timestamp - interval '1' month 
   and unified_audit_policies='APP_AUDIT_DB_SCHEMA_CHANGES'
   and (client_program_name not in ('JDBC Thin Client', 'w3wp.exe')
    and client_program_name not like 'jdenet_k%'
    and client_program_name not like 'runbatch%')
union all
-- USER_AUDIT_DB_SCHEMA_CHANGES
select unified_audit_policies, os_username, userhost, terminal, dbusername, client_program_name, event_timestamp, action_name, return_code, object_schema, object_name, sql_text, system_privilege_used 
  from unified_audit_trail 
 where event_timestamp >= current_timestamp - interval '1' month 
   and unified_audit_policies='USER_AUDIT_DB_SCHEMA_CHANGES'
   and object_schema not in ('EPOST', 'RSINHA', 'AWC', 'SYS', 'DBA_ADMIN')
   and client_program_name not like '%(DW%)%'
union all
-- USER_ACTIONS_USING_SYSTEM_PRIV
select unified_audit_policies, os_username, userhost, terminal, dbusername, client_program_name, event_timestamp, action_name, return_code, object_schema, object_name, sql_text, system_privilege_used 
  from unified_audit_trail 
 where event_timestamp >= current_timestamp - interval '1' month 
   and unified_audit_policies='USER_ACTIONS_USING_SYSTEM_PRIV'
union all
-- APP_ACTIONS_USING_SYSTEM_PRIV
select unified_audit_policies, os_username, userhost, terminal, dbusername, client_program_name, event_timestamp, action_name, return_code, object_schema, object_name, sql_text, system_privilege_used 
  from unified_audit_trail 
 where event_timestamp >= current_timestamp - interval '1' month 
   and unified_audit_policies='APP_ACTIONS_USING_SYSTEM_PRIV'
   and client_program_name not in ('JDBC Thin Client', 'w3wp.exe')
union all
-- AUDIT_DATAPUMP
select unified_audit_policies, os_username, userhost, terminal, dbusername, client_program_name, event_timestamp, action_name, return_code, object_schema, object_name, sql_text, system_privilege_used 
  from unified_audit_trail 
 where event_timestamp >= current_timestamp - interval '1' month 
   and unified_audit_policies='AUDIT_DATAPUMP'
union all
-- ORA_SECURECONFIG
select unified_audit_policies, os_username, userhost, terminal, dbusername, client_program_name, event_timestamp, action_name, return_code, object_schema, object_name, sql_text, system_privilege_used 
  from unified_audit_trail 
 where event_timestamp >= current_timestamp - interval '1' month 
   and unified_audit_policies='ORA_SECURECONFIG'
union all
-- ORA_LOGON_FAILURES
select unified_audit_policies, os_username, userhost, terminal, dbusername, client_program_name, event_timestamp, action_name, return_code, object_schema, object_name, sql_text, system_privilege_used 
  from unified_audit_trail 
 where event_timestamp >= current_timestamp - interval '1' month 
   and unified_audit_policies='ORA_LOGON_FAILURES'
union all
-- Policy is NULL
select unified_audit_policies, os_username, userhost, terminal, dbusername, client_program_name, event_timestamp, action_name, return_code, object_schema, object_name, sql_text, system_privilege_used 
  from unified_audit_trail 
 where event_timestamp >= current_timestamp - interval '1' month 
   and unified_audit_policies is null;