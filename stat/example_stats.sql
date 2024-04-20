
-- exec drop_view('example_view');
create or replace view example_view as 
select 90 value from dual;

-- exec drop_procedure('stat__example');
create or replace procedure stat__example (
   p_interval_mins in number default app_config.example_interval) is 
   v_stat_group varchar2(128);
begin 
   v_stat_group := get_db_name ||'[example]';
   
   if not collect_stat.check_interval(p_stat_group=>v_stat_group, p_interval_mins=>p_interval_mins) then 
      return;
   end if;
   
   merge into stat_table a
   using example_view b on (a.stat_name='Example View' and a.stat_group=v_stat_group)
   when matched then
      update set a.value=b.value
   when not matched then
      insert (a.stat_name, a.stat_group, a.status, a.value, a.stat_type, a.stat_label, a.tags)
      values ('Example View', v_stat_group, 'stage', b.value, 'value', null, '[!]');

end;
/