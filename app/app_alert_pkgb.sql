create or replace package body app_alert is 

function get_notify_count (
   -- Returns minimum number of notifications sent for the alert in given # of hours.
   -- Can be used in the filter procedures.
   p_alert_name in varchar2, 
   p_hours in number default 0) return number is 
   n number;
begin
   select count(*) into n 
     from alert_table 
    where alert_name=p_alert_name 
      and last_notify >= systimestamp - interval '1' hour * p_hours;
   return n;
end;

procedure close_alert (
   p_alert_name in varchar2,
   p_alert_type in varchar2 default null) is 
   -- Closes the specified alert by updating its status and marking it as ready for notification.
   pragma autonomous_transaction;
begin 
   update alert_table 
      set closed=systimestamp,
          ready_notify=1
    where alert_name=p_alert_name
      and nvl(alert_type, '~')=nvl(p_alert_type, '~')
      and closed is null;
   commit;
end;

procedure open_alert (
   -- Only one alert of alert_name and alert_type can be open at a time.
   -- open_alert can be called > 1 time and if alert is already open the
   -- existing alert is simply updated.
   p_alert_name in varchar2,
   p_alert_type in varchar2 default null,
   p_alert_level in varchar2 default 'warning',
   p_alert_info in varchar2 default null,
   p_alert_view in varchar2 default null
   ) is 
   pragma autonomous_transaction;
begin

   -- This function can be customized to filter out some alerts.
   if alert_can_open_yn (
      p_alert_name=>p_alert_name,
      p_alert_level=>p_alert_level,
      p_alert_info=>p_alert_info,
      p_alert_type=>p_alert_type,
      p_alert_view=>p_alert_view) = 'n' then 
      return;
   end if;

   update alert_table
      set alert_level=p_alert_level,
          alert_info=p_alert_info,
          updated=systimestamp
    where alert_name=p_alert_name
      and nvl(alert_type, '~')=nvl(p_alert_type, '~')
      and closed is null;

   if sql%rowcount = 0 then
      -- This alert is not open so insert the row.
      insert into alert_table (
         alert_level,
         alert_name,
         alert_info,
         alert_type,
         alert_view,
         ready_notify) values (
         p_alert_level,
         p_alert_name,
         p_alert_info,
         p_alert_type,
         p_alert_view,
         1);
   end if;

   commit;
end;

procedure merge_alert_long (
   p_view_name in varchar2) is
   -- Merges alerts from a long alert view into the alert_table.
   c sys_refcursor;
   a alert_table%rowtype;
begin
   begin
      open c for 'select alert_level, alert_name, alert_info, alert_type from '||p_view_name; 
      loop
         fetch c into a.alert_level, a.alert_name, a.alert_info, a.alert_type;
         exit when c%notfound;
         open_alert (
            p_alert_name=>a.alert_name, 
            p_alert_type=>a.alert_type, 
            p_alert_level=>a.alert_level, 
            p_alert_info=>a.alert_info, 
            p_alert_view=>p_view_name);
      end loop;
   exception
      when others then 
         log_text(p_text=>p_view_name||': '||dbms_utility.format_error_stack, p_type=>'error', p_expires=>systimestamp+1);
   end;
end;

procedure check_close (
   p_view_name in varchar2) is
begin 
   update alert_table
      set closed=systimestamp,
          ready_notify=1
    where alert_view=p_view_name 
      and closed is null
      and secs_between_timestamps(systimestamp, updated) > 30;
end;

procedure merge_alert_short (
   p_view_name in varchar2) is
   n number;
   c sys_refcursor;
   a alert_table%rowtype;
begin
   -- Short alerts are views which return a single row.

   -- If the view has a column named "VALUE".
   select count(*) into n from user_tab_columns 
    where table_name=p_view_name and column_name='VALUE';
   if n = 1 then
      begin
         open c for 'select value from '||p_view_name; 
         loop
            fetch c into a.alert_info;
            exit when c%notfound;
            open_alert (
               p_alert_name=>p_view_name, 
               p_alert_type=>null, 
               p_alert_level=>null, 
               p_alert_info=>a.alert_info, 
               p_alert_view=>p_view_name);
         end loop;
      exception
         when others then 
            log_text(p_text=>p_view_name||': '||dbms_utility.format_error_stack, p_type=>'error', p_expires=>systimestamp+1);
      end;
   -- If the view does not have a column named "VALUE".
   else 
      execute immediate 'select count(*) from '||p_view_name into n;
      if n > 0 then 
         begin
            open_alert (
               p_alert_name=>p_view_name, 
               p_alert_type=>null, 
               p_alert_level=>null, 
               p_alert_info=>to_char(n), 
               p_alert_view=>p_view_name);
         exception
            when others then 
               log_text(p_text=>p_view_name||': '||dbms_utility.format_error_stack, p_type=>'error', p_expires=>systimestamp+1);
         end;
      end if;
   end if;
end;

procedure check_alert_views is 
   cursor alert_views is 
   select view_name
     from user_views
    where view_name like 'ALERT\_\_%' escape '\';
   n number;
   elapsed_secs number;
   epoch_now number := get_epoch_from_date;
   -- This prevents long running views from running too frequently.
   target_secs_per_hr number := 50;
   max_checks_per_hour number;
   next_check number;
begin 
   for v in alert_views loop

      -- If the view has a column called ALERT_NAME then we will use merge_alert_long.
      select count(*) into n 
        from user_tab_columns 
       where table_name=v.view_name 
         and column_name='ALERT_NAME';

      next_check := get_cache_num(p_key=>v.view_name||'_next_check', p_default=>0);

      if epoch_now < next_check then 
         continue;
      end if;

      g_timer(v.view_name) := sysdate;

      if n = 1 then 
         merge_alert_long(v.view_name);
      else 
         merge_alert_short(v.view_name);
      end if;

      check_close(p_view_name=>v.view_name);

      elapsed_secs := round((sysdate-nvl(g_timer(v.view_name), sysdate))*24*60*60, 1);

      increment_counter(p_key=>v.view_name||'_elapsed_secs', p_num=>elapsed_secs);

      increment_counter(p_key=>v.view_name||'_num_checks', p_num=>1);

      if elapsed_secs > 0 then 
         max_checks_per_hour := target_secs_per_hr/elapsed_secs;
         next_check := epoch_now + (60/max_checks_per_hour*60);
         cache_num(p_key=>v.view_name||'_next_check', p_num=>next_check);
      end if;

   end loop;

   apply_alert_rules;

end;

end;
/