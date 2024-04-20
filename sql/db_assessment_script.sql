
drop table sql$instance;

drop table sql$database;

drop table sql_sys_privs;

drop table sql_tab_privs;

drop table sql_role_privs;

drop table sql$parameter;

drop table sql_data_files;

drop table sql$filestat;

drop table sql_temp_files;

drop table sql$tempfile;

drop table sql$log;

drop table sql$logfile;

drop table sql$statname;

drop table sql$sysstat;

drop table sql$waitstat;

drop table sql$system_event;

drop table sql$session;

drop table sql$process;

drop table sql_segments;

drop table sql_users;

drop table sql_profiles;

drop table sql_tables;

drop table sql_indexes;

drop table sql_directories;

drop table sql_queues;

drop table sql_tablespaces;

drop table sql$log_history;

drop table sql$archived_log;

drop table sql$asm_disk;

drop table sql$asm_diskgroup;

drop table sql$flash_recovery_area_usage;

drop table sql_objects;

drop table sql_links;

drop table sql$os_stat;

drop table sql_scheduler_jobs;

drop table sql_jobs;

drop table sql$rollstat;

drop table sql$rollname;

drop table sql$sgastat;

drop table sql$resource_limit;

drop table sql$datafile;

drop table sql$session_event;

drop table sql$controlfile;

drop table sql_recyclebin;


create table sql$instance as (select * from gv$instance);

create table sql$database as (select * from gv$database);

create table sql_sys_privs as (select * from dba_sys_privs);

create table sql_tab_privs as (select * from dba_tab_privs);

create table sql_role_privs as (select * from dba_role_privs);

create table sql$parameter as (select * from gv$parameter);

create table sql_data_files as (select * from dba_data_files);

create table sql$filestat as (select * from gv$filestat);

create table sql_temp_files as (select * from dba_temp_files);

create table sql$tempfile as (select * from gv$tempfile);

create table sql$log as (select * from gv$log);

create table sql$logfile as (select * from gv$logfile);

create table sql$statname as (select * from gv$statname);

create table sql$sysstat as (select * from gv$sysstat);

create table sql$waitstat as (select * from gv$waitstat);

create table sql$system_event as (select * from gv$system_event);

create table sql$session as (select * from gv$session);

create table sql$process as (select * from gv$process);

create table sql_segments as (select * from dba_segments);

create table sql_users as (select * from dba_users);

create table sql_profiles as (select * from dba_profiles);

create table sql_tables as (select * from dba_tables);

create table sql_indexes as (select * from dba_indexes);

create table sql_directories as (select * from dba_directories);

create table sql_queues as (select * from dba_queues);

create table sql_tablespaces as (select * from dba_tablespaces);

create table sql$log_history as (select * from gv$log_history);

create table sql$archived_log as (select * from gv$archived_log);

create table sql$asm_disk as (select * from gv$asm_disk);

create table sql$asm_diskgroup as (select * from gv$asm_diskgroup);

create table sql$flash_recovery_area_usage as (select * from v$flash_recovery_area_usage);

create table sql_objects as (select * from dba_objects);

create table sql_links as (select * from dba_db_links);

create table sql$os_stat as (select * from gv$osstat);

create table sql_scheduler_jobs as (select * from dba_scheduler_jobs);

create table sql_jobs as (select * from dba_jobs);

create table sql$rollstat as (select * from gv$rollstat);

create table sql$rollname as (select * from v$rollname);

create table sql$sgastat as (select * from gv$sgastat);

create table sql$resource_limit as (select * from gv$resource_limit);

create table sql$datafile as (select * from gv$datafile);

create table sql$session_event as (select * from gv$session_event);

create table sql$controlfile as (select * from gv$controlfile);

create table sql_recyclebin as (select * from dba_recyclebin);









