

create or replace package body sensor as

procedure check_view (
   p_view_name in varchar2) is 
   new_sensor boolean := false;
   v_view_name varchar2(128) := lower(p_view_name);
   v_sensor_id number;
begin 
   update sensor_table
      set updated=systimestamp
    where sensor_name=v_view_name;

   if sql%rowcount = 0 then
      new_sensor := true;
      insert into sensor_table (
         sensor_name,
         sensor_view) values (
         v_view_name,
         v_view_name);
   end if;

   select sensor_id into v_sensor_id
     from sensor_table
    where sensor_name=v_view_name;

   delete from sensor_text
    where sensor_id=v_sensor_id
      and version='OLD';

   update sensor_text
      set version='OLD'
    where sensor_id=v_sensor_id
      and version='NEW';

   execute immediate '
      insert into sensor_text (
         sensor_id,
         version,
         name,
         value) (
         select :1,
                ''NEW'',
                name,
                value
           from '||v_view_name||')' using v_sensor_id;

   if not new_sensor then
      insert into sensor_hist (
         sensor_id,
         name,
         old_value,
         new_value) (
         select v_sensor_id,
                a.name,
                a.value old_value,
                b.value new_value
           from sensor_text a,
                sensor_text b 
          where a.sensor_id=v_sensor_id
            and a.version='OLD'
            and b.sensor_id=v_sensor_id
            and b.version='NEW'
            and a.name=b.name
            and nvl(a.value, '~') != nvl(b.value, '~')
         union all
         select v_sensor_id,
                name,
                'ROW MISSING' old_value,
                value new_value
           from sensor_text a
          where sensor_id=v_sensor_id
            and version='NEW'
            and not exists (select 'x'
                              from sensor_text b 
                             where a.sensor_id=b.sensor_id
                               and a.name=b.name
                               and b.version='OLD')
         union all
         select sensor_id,
                name,
                value old_value,
                'ROW MISSING' new_value
           from sensor_text a
          where sensor_id=v_sensor_id
            and version='OLD'
            and not exists (select 'x'
                              from sensor_text b 
                             where a.sensor_id=b.sensor_id
                               and a.name=b.name
                               and b.version='NEW'));
         
      if sql%rowcount > 0 then 
         update sensor_table
            set last_time=systimestamp
          where sensor_id=v_sensor_id;
      end if;

   end if;
exception 
   when others then 
      log_text(p_text=>'check_view: '||v_view_name||': '||dbms_utility.format_error_stack, p_type=>'error');
      raise;
end;

procedure check_sensor_views is 
   cursor sensor_views is 
   select lower(view_name) view_name
     from user_views
    where view_name like 'SENSOR\_\_%' escape '\';
   new_sensor boolean := false;
begin 
   for v in sensor_views loop 
      begin
         check_view(v.view_name);
      exception 
         when others then 
            log_text(p_text=>'check_sensor_views: '||v.view_name||': '||dbms_utility.format_error_stack, p_type=>'error');
      end;
   end loop;
end;

end;
/