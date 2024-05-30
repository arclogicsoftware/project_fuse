@sensor__database_parameters.sql
@sensor__database_accounts.sql
@sensor__tablespaces.sql
@sensor__session_user_programs.sql
@sensor__data_files.sql
@sensor__database_directories.sql
@sensor__invalid_objects.sql
@sensor__dba_tab_privs.sql
@sensor__dba_sys_privs.sql
@sensor__dba_role_privs.sql
@sensor__accounts_of_interest.sql
@sensor__dba_profiles.sql
@sensor__dba_roles.sql

begin
   app_config.add_param_num(p_name=>'sensor_purge_days', p_num=>365);
end;
/

create or replace procedure sensor_purge as
   -- User should add a modified version of this procedure to app_customer.sql to customize sensor purge.
   -- This procedure is called once per day from the daily_am procedure.
begin
   delete from sensor_hist where created < sysdate - app_config.get_param_num('sensor_purge_days', 365);
   delete from sensor_hist 
    where sensor_id=(select sensor_id from sensor_table where sensor_view='sensor__session_user_programs')
      and created < systimestamp-90;
   commit;
end;
/
