create or replace package body sql_monitor as 

function get_elapsed_seconds_ptile (
   p_force_matching_signature in number,
   p_value in number
   ) return number deterministic is 
   x number;
   pragma autonomous_transaction;
begin
   select
     case
       when p_value <= percentile_disc(0.1) within group (order by elapsed_seconds) then .1
       when p_value <= percentile_disc(0.2) within group (order by elapsed_seconds) then .2
       when p_value <= percentile_disc(0.3) within group (order by elapsed_seconds) then .3
       when p_value <= percentile_disc(0.4) within group (order by elapsed_seconds) then .4
       when p_value <= percentile_disc(0.5) within group (order by elapsed_seconds) then .5
       when p_value <= percentile_disc(0.6) within group (order by elapsed_seconds) then .6
       when p_value <= percentile_disc(0.7) within group (order by elapsed_seconds) then .7
       when p_value <= percentile_disc(0.8) within group (order by elapsed_seconds) then .8
       when p_value <= percentile_disc(0.9) within group (order by elapsed_seconds) then .9
       else 1
     end as ptile into x
     from sql_log
    where force_matching_signature=p_force_matching_signature 
      and datetime >= sysdate-app_config.get_param_num('sql_log_ref_days', 14);
   -- debug('x='||x);
   return x;
end;

function get_elapsed_seconds_ptile (
   p_sql_id in varchar2,
   p_value in number
   ) return number deterministic is 
   x number;
   pragma autonomous_transaction;
begin
   select
     case
       when p_value <= percentile_disc(0.1) within group (order by elapsed_seconds) then .1
       when p_value <= percentile_disc(0.2) within group (order by elapsed_seconds) then .2
       when p_value <= percentile_disc(0.3) within group (order by elapsed_seconds) then .3
       when p_value <= percentile_disc(0.4) within group (order by elapsed_seconds) then .4
       when p_value <= percentile_disc(0.5) within group (order by elapsed_seconds) then .5
       when p_value <= percentile_disc(0.6) within group (order by elapsed_seconds) then .6
       when p_value <= percentile_disc(0.7) within group (order by elapsed_seconds) then .7
       when p_value <= percentile_disc(0.8) within group (order by elapsed_seconds) then .8
       when p_value <= percentile_disc(0.9) within group (order by elapsed_seconds) then .9
       else 1
     end as ptile into x
     from sql_log
    where sql_id=p_sql_id 
      and datetime >= sysdate-app_config.get_param_num('sql_log_ref_days', 14)
      and force_matching_signature=0;
   -- debug('x='||x);
   return x;
end;

function get_elap_secs_per_exe_ptile (
   p_force_matching_signature in number,
   p_value in number
   ) return number deterministic is 
   x number;
   pragma autonomous_transaction;
begin
   select
     case
       when p_value <= percentile_disc(0.1) within group (order by elap_secs_per_exe) then .1
       when p_value <= percentile_disc(0.2) within group (order by elap_secs_per_exe) then .2
       when p_value <= percentile_disc(0.3) within group (order by elap_secs_per_exe) then .3
       when p_value <= percentile_disc(0.4) within group (order by elap_secs_per_exe) then .4
       when p_value <= percentile_disc(0.5) within group (order by elap_secs_per_exe) then .5
       when p_value <= percentile_disc(0.6) within group (order by elap_secs_per_exe) then .6
       when p_value <= percentile_disc(0.7) within group (order by elap_secs_per_exe) then .7
       when p_value <= percentile_disc(0.8) within group (order by elap_secs_per_exe) then .8
       when p_value <= percentile_disc(0.9) within group (order by elap_secs_per_exe) then .9
       else 1
     end as ptile into x
     from sql_log
    where force_matching_signature=p_force_matching_signature 
      and datetime >= sysdate-app_config.get_param_num('sql_log_ref_days', 14);
   -- debug('x='||x);
   return x;
end;

function get_elap_secs_per_exe_ptile (
   p_sql_id in varchar2,
   p_value in number
   ) return number deterministic is 
   x number;
   pragma autonomous_transaction;
begin
   select
     case
       when p_value <= percentile_disc(0.1) within group (order by elap_secs_per_exe) then .1
       when p_value <= percentile_disc(0.2) within group (order by elap_secs_per_exe) then .2
       when p_value <= percentile_disc(0.3) within group (order by elap_secs_per_exe) then .3
       when p_value <= percentile_disc(0.4) within group (order by elap_secs_per_exe) then .4
       when p_value <= percentile_disc(0.5) within group (order by elap_secs_per_exe) then .5
       when p_value <= percentile_disc(0.6) within group (order by elap_secs_per_exe) then .6
       when p_value <= percentile_disc(0.7) within group (order by elap_secs_per_exe) then .7
       when p_value <= percentile_disc(0.8) within group (order by elap_secs_per_exe) then .8
       when p_value <= percentile_disc(0.9) within group (order by elap_secs_per_exe) then .9
       else 1
     end as ptile into x
     from sql_log
    where sql_id=p_sql_id
      and force_matching_signature=0 
      and datetime >= sysdate-app_config.get_param_num('sql_log_ref_days', 14);
   -- debug('x='||x);
   return x;
end;

function get_executions_ptile (
   p_force_matching_signature in number,
   p_value in number
   ) return number deterministic is 
   x number;
   pragma autonomous_transaction;
begin
   select
     case
       when p_value <= percentile_disc(0.1) within group (order by executions) then .1
       when p_value <= percentile_disc(0.2) within group (order by executions) then .2
       when p_value <= percentile_disc(0.3) within group (order by executions) then .3
       when p_value <= percentile_disc(0.4) within group (order by executions) then .4
       when p_value <= percentile_disc(0.5) within group (order by executions) then .5
       when p_value <= percentile_disc(0.6) within group (order by executions) then .6
       when p_value <= percentile_disc(0.7) within group (order by executions) then .7
       when p_value <= percentile_disc(0.8) within group (order by executions) then .8
       when p_value <= percentile_disc(0.9) within group (order by executions) then .9
       else 1
     end as ptile into x
     from sql_log
    where force_matching_signature=p_force_matching_signature 
      and datetime >= sysdate-app_config.get_param_num('sql_log_ref_days', 14);
   -- debug('x='||x);
   return x;
end;

function get_executions_ptile (
   p_sql_id in varchar2,
   p_value in number
   ) return number deterministic is 
   x number;
   pragma autonomous_transaction;
begin
   select
     case
       when p_value <= percentile_disc(0.1) within group (order by executions) then .1
       when p_value <= percentile_disc(0.2) within group (order by executions) then .2
       when p_value <= percentile_disc(0.3) within group (order by executions) then .3
       when p_value <= percentile_disc(0.4) within group (order by executions) then .4
       when p_value <= percentile_disc(0.5) within group (order by executions) then .5
       when p_value <= percentile_disc(0.6) within group (order by executions) then .6
       when p_value <= percentile_disc(0.7) within group (order by executions) then .7
       when p_value <= percentile_disc(0.8) within group (order by executions) then .8
       when p_value <= percentile_disc(0.9) within group (order by executions) then .9
       else 1
     end as ptile into x
     from sql_log
    where sql_id=p_sql_id
      and force_matching_signature=0 
      and datetime >= sysdate-app_config.get_param_num('sql_log_ref_days', 14);
   -- debug('x='||x);
   return x;
end;

procedure update_refs is 
begin
   debug('sql_monitor.update_refs: ');
    update sql_log a
      set a.elap_secs_per_exe_med=(
         select round(median(b.elap_secs_per_exe), 2)
           from sql_log b 
          where b.datetime >= sysdate-app_config.get_param_num('sql_log_ref_days', 14)
            and a.force_matching_signature=b.force_matching_signature
            and b.force_matching_signature != 0)
    where a.datetime=trunc(sysdate, 'HH24')
      and a.force_matching_signature != 0
      and a.elap_secs_per_exe_med is null;
   update sql_log a
      set a.elap_secs_per_exe_avg=(
         select round(avg(b.elap_secs_per_exe), 2)
           from sql_log b 
          where b.datetime >= sysdate-app_config.get_param_num('sql_log_ref_days', 14)
            and a.force_matching_signature=b.force_matching_signature
            and b.force_matching_signature != 0)
    where a.datetime=trunc(sysdate, 'HH24')
      and a.force_matching_signature != 0
      and a.elap_secs_per_exe_avg is null;
   update sql_log a
      set a.elap_secs_per_exe_med=(
         select round(median(b.elap_secs_per_exe), 2)
           from sql_log b 
          where b.datetime >= sysdate-app_config.get_param_num('sql_log_ref_days', 14)
            and a.sql_id=b.sql_id
            and b.force_matching_signature = 0)
    where a.datetime=trunc(sysdate, 'HH24')
      and a.force_matching_signature = 0
      and a.elap_secs_per_exe_med is null;
   update sql_log a
      set a.elap_secs_per_exe_avg=(
         select round(avg(b.elap_secs_per_exe), 2)
           from sql_log b 
          where b.datetime >= sysdate-app_config.get_param_num('sql_log_ref_days', 14)
            and a.sql_id=b.sql_id
            and b.force_matching_signature = 0)
    where a.datetime=trunc(sysdate, 'HH24')
      and a.force_matching_signature = 0
      and a.elap_secs_per_exe_avg is null;
    update sql_log a 
       set a.fms_elapsed_seconds=(
           select sum(elapsed_seconds)
              from sql_log b
            where b.datetime=trunc(sysdate, 'HH24') 
              and b.force_matching_signature=a.force_matching_signature
              and b.force_matching_signature!=0)
     where a.datetime = trunc(sysdate, 'HH24')
       and a.force_matching_signature!=0;
end;

procedure update_ptiles is 
   cursor force_matching_signatures is 
    select force_matching_signature
      from sql_log 
     where datetime=trunc(sysdate, 'HH24') 
    having sum(elapsed_seconds) >= app_config.get_param_num('sql_log_ref_elapsed_mins_limit', 5)*60
       and force_matching_signature != 0
     group by force_matching_signature;
   cursor sql_ids is 
    select sql_id 
      from sql_log 
     where datetime=trunc(sysdate, 'HH24') 
       and force_matching_signature = 0
    having sum(elapsed_seconds) >= app_config.get_param_num('sql_log_ref_elapsed_mins_limit', 5)*60
     group by sql_id;
   x number;
   c number := 0;
begin 
   debug('sql_monitor.update_ptiles: ');
   for s in force_matching_signatures loop
      -- debug('force_matching_signature='||s.force_matching_signature);
      c := c + 1;
      update sql_log
         set elap_secs_per_exe_ptile=sql_monitor.get_elap_secs_per_exe_ptile (
                p_force_matching_signature=>s.force_matching_signature, 
                p_value=>elap_secs_per_exe),
             elapsed_seconds_ptile=sql_monitor.get_elapsed_seconds_ptile (
                p_force_matching_signature=>s.force_matching_signature, 
                p_value=>elapsed_seconds),
             executions_ptile=sql_monitor.get_executions_ptile (
                p_force_matching_signature=>s.force_matching_signature, 
                p_value=>executions)
      where force_matching_signature=s.force_matching_signature
        and datetime=trunc(sysdate, 'HH24');
      -- debug(sql%rowcount||' rows updated');
   end loop;
   -- debug('update_ptiles:force_matching_signature: Executed '||c||' updates.');
   -- 
   c := 0;
   for s in sql_ids loop
      c := c + 1;
      update sql_log
         set elap_secs_per_exe_ptile=sql_monitor.get_elap_secs_per_exe_ptile (
                p_sql_id=>s.sql_id, 
                p_value=>elap_secs_per_exe),
             elapsed_seconds_ptile=sql_monitor.get_elapsed_seconds_ptile (
                p_sql_id=>s.sql_id, 
                p_value=>elapsed_seconds),
             executions_ptile=sql_monitor.get_executions_ptile (
                p_sql_id=>s.sql_id, 
                p_value=>executions)
      where sql_id=s.sql_id
        and datetime=trunc(sysdate, 'HH24');
      -- debug(sql%rowcount||' rows updated.');
   end loop;
   -- debug('update_ptiles:sql_id: Executed '||c||' updates.');
   commit;
end;

procedure sql_log_take_snapshot is
   -- Takes a snapshot of the records returned by sql_snap_view.
   -- Rows are simply inserted into sql_snap. These rows can 
   -- later be compared back to the current values in the view.
   n number;
begin
   -- @todo Convert to param
   n := 100;
   insert into sql_snap (
      sql_id,
      insert_datetime,
      sql_text,
      executions,
      plan_hash_value,
      elapsed_time,
      force_matching_signature,
      user_io_wait_time,
      rows_processed,
      cpu_time,
      service,
      module,
      action) (select sql_id,
      sysdate,
      substr(sql_text, 1, n),
      executions,
      plan_hash_value,
      elapsed_time,
      force_matching_signature,
      user_io_wait_time,
      rows_processed,
      cpu_time,
      service,
      module,
      action
     from sql_snap_view);
end;

function get_mins_since_last_snap return number is
   d date;
begin 
   select nvl(max(update_time), sysdate-1) into d from sql_log;
   return (sysdate-d)*24*60;
end;

procedure monitor_large_sorts is 
begin
   insert into large_sort_hist (select * from large_sorts);
   commit;
end;

procedure monitor (
   p_interval_mins in number default 18) is
   cursor busy_sql is
   -- Matches rows in both sets.
   select a.sql_id,
          a.sql_text,
          a.plan_hash_value,
          a.force_matching_signature,
          b.executions-a.executions executions,
          b.elapsed_time-a.elapsed_time elapsed_time,
          b.user_io_wait_time-a.user_io_wait_time user_io_wait_time,
          b.rows_processed-a.rows_processed rows_processed,
          b.cpu_time-a.cpu_time cpu_time,
          round((sysdate-a.insert_datetime)*24*60*60) secs_between_snaps,
          a.service,
          a.module,
          a.action
     from sql_snap a,
          sql_snap_view b
    where a.sql_id=b.sql_id
      and a.plan_hash_value=b.plan_hash_value
      and a.force_matching_signature=b.force_matching_signature
      -- @todo This is one second, need to change to a parameter everywhere.
      and b.elapsed_time-a.elapsed_time >= 1*1000000
      and b.executions-a.executions > 0
   union all
   -- These are new rows which are not in the snapshot.
   select a.sql_id,
          a.sql_text,
          a.plan_hash_value,
          a.force_matching_signature,
          a.executions,
          a.elapsed_time,
          a.user_io_wait_time,
          a.rows_processed,
          a.cpu_time,
          0,
          a.service,
          a.module,
          a.action
     from sql_snap_view a
    where a.elapsed_time >= 1*1000000
      and a.executions > 0
      and not exists (select 'x'
                        from sql_snap b
                       where a.sql_id=b.sql_id
                         and a.plan_hash_value=b.plan_hash_value
                         and a.force_matching_signature=b.force_matching_signature);
   n number;
   last_elap_secs_per_exe  number;
   v_sql_log sql_log%rowtype;
   v_new_inserts boolean := false;
begin
   if get_mins_since_last_snap < app_config.get_param_num(p_name=>'monitor_sql_repeat_interval', p_default=>15) then
      return;
   end if;

   monitor_large_sorts;

   select count(*) into n from sql_snap where rownum < 2;
   if n = 0 then
      sql_log_take_snapshot;
   else
      for s in busy_sql loop

         update sql_log set
            executions=executions+s.executions,
            elapsed_seconds=round(elapsed_seconds+s.elapsed_time/1000000, 1),
            cpu_seconds=round(cpu_seconds+s.cpu_time/1000000, 1),
            rows_processed=rows_processed+s.rows_processed,
            user_io_wait_secs=round(user_io_wait_secs+s.user_io_wait_time/1000000, 1),
            update_time=sysdate,
            update_count=update_count+1,
            secs_between_snaps=s.secs_between_snaps,
            elap_secs_per_exe = round((elapsed_seconds+s.elapsed_time/1000000) / (executions+s.executions), 3),
            service = s.service,
            module = s.module,
            action = s.action
          where sql_id=s.sql_id
            and plan_hash_value=s.plan_hash_value
            and force_matching_signature=s.force_matching_signature
            and datetime=trunc(sysdate, 'HH24');

         if sql%rowcount = 0 then

            v_new_inserts := true;

            -- Try to load previous record if it exist.
            select max(datetime) into v_sql_log.datetime 
              from sql_log
             where sql_id=s.sql_id 
               and plan_hash_value=s.plan_hash_value 
               and force_matching_signature=s.force_matching_signature 
               and datetime!=trunc(sysdate, 'HH24');

            if not v_sql_log.datetime is null then 
               select * into v_sql_log
                 from sql_log 
                where sql_id=s.sql_id 
                  and plan_hash_value=s.plan_hash_value 
                  and force_matching_signature=s.force_matching_signature 
                  and datetime=v_sql_log.datetime;
            end if;

            -- This is a new SQL or new hour and we need to insert it.
            insert into sql_log ( 
               sql_id, 
               sql_text, 
               plan_hash_value, 
               force_matching_signature, 
               datetime, 
               executions, 
               elapsed_seconds, 
               cpu_seconds, 
               user_io_wait_secs, 
               rows_processed, 
               update_count, 
               update_time, 
               elap_secs_per_exe, 
               secs_between_snaps,
               service,
               module,
               action) values ( 
               s.sql_id, 
               substr(s.sql_text, 1, 100),
               s.plan_hash_value, 
               s.force_matching_signature, 
               trunc(sysdate, 'HH24'), 
               s.executions, 
               round(s.elapsed_time/1000000, 1), 
               round(s.cpu_time/1000000, 1), 
               round(s.user_io_wait_time/1000000, 1), 
               s.rows_processed, 
               1, sysdate, 
               round(s.elapsed_time/1000000/s.executions, 3), 
               s.secs_between_snaps,
               s.service,
               s.module,
               s.action);

         end if;

         if s.executions = 0 then
            last_elap_secs_per_exe := 0;
         else
            last_elap_secs_per_exe := round(s.elapsed_time/1000000/s.executions, 3);
         end if;

         if last_elap_secs_per_exe < 2 then
            update sql_log set secs_0_1=round(secs_0_1+s.elapsed_time/1000000, 1) where sql_id=s.sql_id and plan_hash_value=s.plan_hash_value and force_matching_signature=s.force_matching_signature and datetime=trunc(sysdate, 'HH24');
         elsif last_elap_secs_per_exe < 6 then
            update sql_log set secs_2_5=round(secs_2_5+s.elapsed_time/1000000, 1) where sql_id=s.sql_id and plan_hash_value=s.plan_hash_value and force_matching_signature=s.force_matching_signature and datetime=trunc(sysdate, 'HH24');
         elsif last_elap_secs_per_exe < 11 then
            update sql_log set secs_6_10=round(secs_6_10+s.elapsed_time/1000000, 1) where sql_id=s.sql_id and plan_hash_value=s.plan_hash_value and force_matching_signature=s.force_matching_signature and datetime=trunc(sysdate, 'HH24');
         elsif last_elap_secs_per_exe < 61 then
            update sql_log set secs_11_60=round(secs_11_60+s.elapsed_time/1000000, 1) where sql_id=s.sql_id and plan_hash_value=s.plan_hash_value and force_matching_signature=s.force_matching_signature and datetime=trunc(sysdate, 'HH24');
         else
            update sql_log set secs_61_plus=round(secs_61_plus+s.elapsed_time/1000000, 1) where sql_id=s.sql_id and plan_hash_value=s.plan_hash_value and force_matching_signature=s.force_matching_signature and datetime=trunc(sysdate, 'HH24');
         end if;
      end loop;
      delete from sql_snap;
      sql_log_take_snapshot;
      if v_new_inserts then 
         update_refs;
      end if;
      if get_timer_min('sql_monitor_ptile_update') > 19 or get_timer_min('sql_monitor_ptile_update') = 0 then 
         update_ptiles;
         start_timer('sql_monitor_ptile_update');
      end if;
   end if;
end;

end;
/
