-- RDS is case aware, username should be upper case!
define username='EPOST';

-- Works everywhere
grant create sequence to &username;
grant create session to &username;
grant create table to &username;
grant create procedure to &username;
grant create view to &username;
grant create trigger to &username;
grant create type to &username;
grant create public synonym to &username;
grant create synonym to &username;
grant drop public synonym to &username;
grant select on dba_segments to &username;
grant select on dba_tables to &username;
grant select on dba_indexes to &username;
grant select on dba_temp_files to &username;
grant select on dba_users to &username;
grant create job to &username;
grant create any context to &username;
grant drop any context to &username;
grant execute on dbms_session to &username;
grant select on dba_data_files to &username;
grant select on dba_tablespaces to &username;
grant select on dba_free_space to &username;
grant select on dba_objects to &username;
grant select on dba_roles to &username;
grant select on dba_role_privs to &username;
grant create role to &username;
grant select on dba_tab_privs to &username;
grant select on dba_sys_privs to &username;
grant select any table to &username;
grant select on dba_scheduler_job_run_details to &username;
grant select on dba_scheduler_jobs to &username;
grant select on dba_scheduler_job_log to &username;
grant select on dba_outstanding_alerts to &username;
grant select on dba_recyclebin to &username;
grant select on dba_directories to &username;
grant select on dba_triggers to &username;
grant execute on dbms_file_transfer to &username;
grant select on dba_profiles to &username;
grant select on unified_audit_trail to &username;
grant alter user to &username;
grant execute on dbms_lock to &username;
grant alter system to &username;


-- Style 1
grant select on v$database to &username;
grant select on gv$database to &username;
grant select on v$instance to &username;
grant select on gv$instance to &username;
grant select on v$tempfile to &username;
grant select on gv$sort_usage to &username;
grant select on gv$tempstat to &username;
grant select on gv$sql to &username;
grant select on gv$filestat to &username;
grant select on gv$sysstat to &username;
grant select on gv$system_event to &username;
grant select on gv$sgastat to &username;
grant select on gv$waitstat to &username;
grant select on gv$archived_log to &username;
grant select on v$recovery_file_dest to &username;
grant select on v$sqlarea to &username;
grant select on gv$sqlarea to &username;
grant select on gv$db_object_cache to &username;
grant select on gv$object_dependency to &username;
grant select on gv$session to &username;
grant select on gv$lock to &username;
grant select on gv$bgprocess to &username;
grant select on gv$locked_object to &username;
grant select on v$statname to &username;
grant select on gv$statname to &username;
grant select on gv$sesstat to &username;
grant select on gv$session_event to &username;
grant select on gv$asm_diskgroup to &username;
grant select on v$asm_diskgroup to &username;
grant select on v$resource_limit to &username;
grant select on gv$resource_limit to &username;
grant select on v$parameter to &username;
grant select on gv$parameter to &username;
grant select on v$process to &username;
grant select on gv$process to &username;
grant select on v$flash_recovery_area_usage to &username;
grant select on gv$flash_recovery_area_usage to &username;
grant select on gv$pdbs to &username;
grant select on v$pdbs to &username;
grant select on gv$archive_dest to &username;
grant select on v$archive_dest to &username;
grant select on gv$archive_dest_status to &username;
grant select on v$archive_dest_status to &username;
grant select on v$rman_backup_job_details to &username;
grant select on gv$rman_backup_job_details to &username;
grant select on v$rman_status to &username;
grant select on gv$rman_status to &username;
grant select on v$log_history to &username;
grant select on gv$log_history to &username;
grant select on gv$mystat to &username;
grant select on v$mystat to &username;
grant select on gv$dataguard_status to &username;
grant select on v$dataguard_status to &username;
grant select on gv$log to &username;
grant select on v$log to &username;
grant select on gv$osstat to &username;
grant select on v$osstat to &username;
grant select on v$datafile to &username;
grant select on gv$datafile to &username;
grant select on gv$segment_statistics to &username;

-- Style 2

grant select on v_$database to &username;
grant select on gv_$database to &username;
grant select on v_$instance to &username;
grant select on gv_$instance to &username;
grant select on v_$tempfile to &username;
grant select on gv_$sort_usage to &username;
grant select on gv_$tempstat to &username;
grant select on gv_$sql to &username;
grant select on gv_$filestat to &username;
grant select on gv_$sysstat to &username;
grant select on gv_$system_event to &username;
grant select on gv_$sgastat to &username;
grant select on gv_$waitstat to &username;
grant select on gv_$archived_log to &username;
grant select on v_$recovery_file_dest to &username;
grant select on v_$sqlarea to &username;
grant select on gv_$sqlarea to &username;
grant select on gv_$db_object_cache to &username;
grant select on gv_$object_dependency to &username;
grant select on gv_$session to &username;
grant select on gv_$lock to &username;
grant select on gv_$bgprocess to &username;
grant select on gv_$locked_object to &username;
grant select on v_$statname to &username;
grant select on gv_$statname to &username;
grant select on gv_$sesstat to &username;
grant select on gv_$session_event to &username;
grant select on gv_$asm_diskgroup to &username;
grant select on v_$asm_diskgroup to &username;
grant select on v_$resource_limit to &username;
grant select on gv_$resource_limit to &username;
grant select on v_$parameter to &username;
grant select on gv_$parameter to &username;
grant select on v_$process to &username;
grant select on gv_$process to &username;
grant select on v_$flash_recovery_area_usage to &username;
grant select on gv_$flash_recovery_area_usage to &username;
grant select on gv_$pdbs to &username;
grant select on v_$pdbs to &username;
grant select on gv_$archive_dest to &username;
grant select on v_$archive_dest to &username;
grant select on gv_$archive_dest_status to &username;
grant select on v_$archive_dest_status to &username;
grant select on v_$rman_backup_job_details to &username;
grant select on gv_$rman_backup_job_details to &username;
grant select on v_$rman_status to &username;
grant select on gv_$rman_status to &username;
grant select on v_$log_history to &username;
grant select on gv_$log_history to &username;
grant select on gv_$mystat to &username;
grant select on v_$mystat to &username;
grant select on gv_$dataguard_status to &username;
grant select on v_$dataguard_status to &username;
grant select on gv_$log to &username;
grant select on v_$log to &username;
grant select on gv_$osstat to &username;
grant select on v_$osstat to &username;
grant select on v_$datafile to &username;
grant select on gv_$datafile to &username;
grant select on gv_$segment_statistics to &username;

-- RDS (object names are case sensative!)
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'DBA_SEGMENTS', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'DBA_OBJECTS', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'DBA_USERS', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'V_$TEMPFILE', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$SORT_USAGE', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$TEMPSTAT', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$SQL', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$FILESTAT', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$SYSSTAT', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$SYSTEM_EVENT', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$SGASTAT', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$SYSTEM_EVENT', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$SGASTAT', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$WAITSTAT', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$ARCHIVED_LOG', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'V_$RECOVERY_FILE_DEST', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$SQLAREA', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'V_$SQLAREA', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$DB_OBJECT_CACHE', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$OBJECT_DEPENDENCY', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$SESSION', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$LOCK', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$BGPROCESS', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$LOCKED_OBJECT', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$DATABASE', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'V_$DATABASE', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$INSTANCE', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'V_$INSTANCE', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'V_$STATNAME', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$STATNAME', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$SESSTAT', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$SESSION_EVENT', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'DBA_ROLES', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'DBA_ROLE_PRIVS', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'DBA_TAB_PRIVS', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'DBA_SYS_PRIVS', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'DBA_SCHEDULER_JOB_RUN_DETAILS', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'DBA_SCHEDULER_JOBS', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$RESOURCE_LIMIT', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'V_$RESOURCE_LIMIT', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$PARAMETER', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'V_$PARAMETER', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$PROCESS', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'V_$PROCESS', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'DBA_SCHEDULER_JOB_LOG', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'V_$ASM_DISKGROUP', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$ASM_DISKGROUP', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$FLASH_RECOVERY_AREA_USAGE', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'V_$FLASH_RECOVERY_AREA_USAGE', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'V_$PDBS', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$PDBS', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'DBA_OUTSTANDING_ALERTS', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'DBA_RECYCLEBIN', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'V_$ARCHIVE_DEST', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$ARCHIVE_DEST', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'V_$ARCHIVE_DEST_STATUS', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$ARCHIVE_DEST_STATUS', p_grantee=>'&username', p_privilege=>'SELECT');
-- execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$RMAN_BACKUP_JOB_DETAILS', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'V_$RMAN_BACKUP_JOB_DETAILS', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'V_$RMAN_STATUS', p_grantee=>'&username', p_privilege=>'SELECT');
-- execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$RMAN_STATUS', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'DBA_DIRECTORIES', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'V_$LOG_HISTORY', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$LOG_HISTORY', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$MYSTAT', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'V_$MYSTAT', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$DATAGUARD_STATUS', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'V_$DATAGUARD_STATUS', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$LOG', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'V_$LOG', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'DBA_TRIGGERS', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'DBMS_SYSTEM', p_grantee=>'&username', p_privilege=>'EXECUTE');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$OSSTAT', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'V_$OSSTAT', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'DBMS_FILE_TRANSFER', p_grantee=>'&username', p_privilege=>'EXECUTE');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$FILESTAT', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'V_$FILESTAT', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'DBA_PROFILES', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'UNIFIED_AUDIT_TRAIL', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'GV_$SEGMENT_STATISTICS', p_grantee=>'&username', p_privilege=>'SELECT');
execute rdsadmin.rdsadmin_util.grant_sys_object( p_obj_name=>'DBMS_LOCK', p_grantee=>'&username', p_privilege=>'EXECUTE');
