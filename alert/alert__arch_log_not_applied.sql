


begin
   app_config.add_param_num(p_name=>'alert__arch_log_not_applied_count', p_num=>5);
end;
/

create or replace view alert__arch_log_not_applied as 
select count(*) value from gv$archived_log 
 where first_time >= sysdate-1 
   and standby_dest='YES' 
   and applied != 'YES'
having count(*) > app_config.get_param_num('alert__arch_log_not_applied_count', 5);

