
-- If we need to install supporting objects in another scheme, for example to 
-- support auditing or a customer owned scheme, we don't want out synonyms
-- pointing to that schema. So this file should only be run for the main 
-- install with all features and excluded from running in any other schema.

create or replace public synonym alert_table for alert_table;
create or replace public synonym alerts_ready_notify for alerts_ready_notify;
create or replace public synonym log_table for log_table;
create or replace public synonym blocked_sessions for blocked_sessions;
create or replace public synonym sql_log_weekly_stat for sql_log_weekly_stat;
create or replace public synonym asm_space for asm_space;
create or replace public synonym sga_info for sga_info;
create or replace public synonym sparse_tables for sparse_tables;


