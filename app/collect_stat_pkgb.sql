create or replace package body collect_stat as 

procedure collect is 
begin
   -- @todo There should be stats on each collect here to know how long they are taking!
   collect_waitstats;
   collect_system_waits;
   collect_database_stats;
   collect_sga_stats;
   collect_file_stats;
   collect_meta_stats;
   process_stat_views;
   if round(dbms_random.value(1,10)) = 1 then
      auto_activate;
   end if;
end;

procedure collect_stat (
   p_stat_name in varchar2,
   p_stat_group in varchar2,
   p_value in number,
   p_stat_type in varchar2 default 'value',
   p_tags in varchar2 default null,
   p_value_convert in varchar2 default null,
   p_stat_label in varchar2 default null) is
begin 
   update stat_table 
      set value=p_value
    where stat_name=p_stat_name
      and stat_group=p_stat_group;
   if sql%rowcount = 0 then
      insert into stat_table (
         stat_name,
         stat_group,
         tags,
         value,
         stat_type,
         value_convert,
         stat_label) values (
         p_stat_name,
         p_stat_group,
         p_tags,
         p_value,
         p_stat_type,
         p_value_convert,
         p_stat_label);
   end if;
end;

procedure register_error (
   p_view_name in varchar2) is
begin 
   increment_counter(p_key=>p_view_name||'_errors', p_num=>1);
end;

procedure process_stat_views is 
   cursor stat_views is 
   select view_name
     from user_views
    where view_name like 'STAT\_\_%' escape '\';
   c sys_refcursor;
   s stat_table%rowtype;
   elapsed_secs number;
   epoch_now number := get_epoch_from_date;
   target_secs_per_hr number := 50;
   max_checks_per_hour number;
   next_check number;
begin 
   for v in stat_views loop
      next_check := get_cache_num(p_key=>v.view_name||'_next_check', p_default=>0);
      if epoch_now < next_check then 
         continue;
      end if;
      g_timer(v.view_name) := sysdate;
      begin
         open c for 'select stat_name, stat_group, value, stat_type, tags, value_convert, stat_label from '||v.view_name; 
         loop
            fetch c into s.stat_name, s.stat_group, s.value, s.stat_type, s.tags, s.value_convert, s.stat_label;
            exit when c%notfound;
            collect_stat (
               p_stat_name=>s.stat_name,
               p_stat_group=>s.stat_group,
               p_value=>s.value,
               p_stat_type=>s.stat_type,
               p_tags=>s.tags,
               p_value_convert=>s.value_convert,
               p_stat_label=>s.stat_label);
         end loop;
      exception 
         when others then
            log_text(p_text=>v.view_name||': '||sqlerrm, p_type=>'error', p_expires=>systimestamp+7);
            register_error(p_view_name=>v.view_name);
      end;
      elapsed_secs := round((sysdate-nvl(g_timer(v.view_name), sysdate))*24*60*60, 1);
      increment_counter(p_key=>v.view_name||'_elapsed_secs', p_num=>elapsed_secs);
      increment_counter(p_key=>v.view_name||'_num_checks', p_num=>1);
      if elapsed_secs > 0 then 
         max_checks_per_hour := target_secs_per_hr/elapsed_secs;
         next_check := epoch_now + (60/max_checks_per_hour*60);
         cache_num(p_key=>v.view_name||'_next_check', p_num=>next_check);
      end if;
   end loop;
end;

procedure auto_activate is 
begin 
   update stat_table 
      set status='active' 
    where status='stage'
      and created < systimestamp - interval '1' hour;
end;

function has_tag (
   -- Existing string of tags
   p_tags in varchar2,
   -- The tag you want to check for
   p_check_tag in varchar2)
   return number deterministic is 
begin 
   if nvl(instr(lower(p_tags), lower(p_check_tag)), 0) = 0 then
      return 0;
   else 
      return 1;
   end if; 
end;

function add_tag (
   -- Existing string of tags
   p_tags in varchar2,
   -- The tag you want to add
   p_add_tag in varchar2)
   return varchar2 is 
   n number;
begin 
   if nvl(instr(lower(p_tags), lower(p_add_tag)), 0) = 0 then 
      return trim(ltrim(nvl(p_tags, '') ||', '||p_add_tag, ','));
   end if;
   return p_tags;
end;

procedure collect_meta_stats is 
   n number;
begin 
   select round(avg(nvl(hh24_pct_of_ref, 0))) into n 
     from stat_table 
    where value > 0 
      and delta_value != 0 
      and has_tag(tags, '[!]') = 1;
   collect_stat(p_stat_name=>'Avg(hh24_pct_of_ref) tag=[!]', p_stat_group=>'meta', p_value=>n);
   update stat_table set status='active' where status='stage' and stat_group='meta';
end;

procedure collect_file_stats is 
   v_stat_group varchar2(128);
begin 
   v_stat_group := 'datafile_phyrds';

   merge into stat_table a
   using gv$filestat b on (a.stat_name=b.file#||' ('||b.inst_id||')' and a.stat_group=v_stat_group)
   when matched then
      update set a.value=b.phyrds
   when not matched then
      insert (a.stat_name, a.stat_group, a.status, a.value, a.stat_type, a.value_convert, a.stat_label)
      values (b.file#||' ('||b.inst_id||')', v_stat_group, 'stage', b.phyrds, 'rate', '/1000', 'k/sec');

   v_stat_group := 'datafile_phywrts';
   merge into stat_table a
   using gv$filestat b on (a.stat_name=b.file#||' ('||b.inst_id||')' and a.stat_group=v_stat_group)
   when matched then
      update set a.value=b.phywrts
   when not matched then
      insert (a.stat_name, a.stat_group, a.status, a.value, a.stat_type, a.value_convert, a.stat_label)
      values (b.file#||' ('||b.inst_id||')', v_stat_group, 'stage', b.phywrts, 'rate', '/1000', 'k/sec');

   v_stat_group := 'datafile_writetim';
   merge into stat_table a
   using gv$filestat b on (a.stat_name=b.file#||' ('||b.inst_id||')' and a.stat_group=v_stat_group)
   when matched then
      update set a.value=b.writetim
   when not matched then
      insert (a.stat_name, a.stat_group, a.status, a.value, a.stat_type, a.value_convert, a.stat_label)
      values (b.file#||' ('||b.inst_id||')', v_stat_group, 'stage', b.writetim, 'rate', '/100', 'seconds/sec');

   v_stat_group := 'datafile_readtim';
   merge into stat_table a
   using gv$filestat b on (a.stat_name=b.file#||' ('||b.inst_id||')' and a.stat_group=v_stat_group)
   when matched then
      update set a.value=b.readtim
   when not matched then
      insert (a.stat_name, a.stat_group, a.status, a.value, a.stat_type, a.value_convert, a.stat_label)
      values (b.file#||' ('||b.inst_id||')', v_stat_group, 'stage', b.readtim, 'rate', '/100', 'seconds/sec');

   v_stat_group := 'tempfile_phyrds';
   merge into stat_table a
   using gv$tempstat b on (a.stat_name=b.file#||' ('||b.inst_id||')' and a.stat_group=v_stat_group)
   when matched then
      update set a.value=b.phyrds
   when not matched then
      insert (a.stat_name, a.stat_group, a.status, a.value, a.stat_type, a.value_convert, a.stat_label)
      values (b.file#||' ('||b.inst_id||')', v_stat_group, 'stage', b.phyrds, 'rate', '/1000', 'k/sec');

   v_stat_group := 'tempfile_phywrts';
   merge into stat_table a
   using gv$tempstat b on (a.stat_name=b.file#||' ('||b.inst_id||')' and a.stat_group=v_stat_group)
   when matched then
      update set a.value=b.phywrts
   when not matched then
      insert (a.stat_name, a.stat_group, a.status, a.value, a.stat_type, a.value_convert, a.stat_label)
      values (b.file#||' ('||b.inst_id||')', v_stat_group, 'stage', b.phywrts, 'rate', '/1000', 'k/sec');

   v_stat_group := 'tempfile_writetim';
   merge into stat_table a
   using gv$tempstat b on (a.stat_name=b.file#||' ('||b.inst_id||')' and a.stat_group=v_stat_group)
   when matched then
      update set a.value=b.writetim
   when not matched then
      insert (a.stat_name, a.stat_group, a.status, a.value, a.stat_type, a.value_convert, a.stat_label)
      values (b.file#||' ('||b.inst_id||')', v_stat_group, 'stage', b.writetim, 'rate', '/1000', 'seconds/sec');

   v_stat_group := 'tempfile_readtim';
   merge into stat_table a
   using gv$tempstat b on (a.stat_name=b.file#||' ('||b.inst_id||')' and a.stat_group=v_stat_group)
   when matched then
      update set a.value=b.readtim
   when not matched then
      insert (a.stat_name, a.stat_group, a.status, a.value, a.stat_type, a.value_convert, a.stat_label)
      values (b.file#||' ('||b.inst_id||')', v_stat_group, 'stage', b.readtim, 'rate', '/1000', 'seconds/sec');

end;

procedure collect_waitstats is 
   v_stat_group varchar2(128);
begin
   v_stat_group := 'waitstat_waits';

   merge into stat_table a
   using gv$waitstat b on (a.stat_name=b.class||' ('||b.inst_id||')' and a.stat_group=v_stat_group)
   when matched then
      update set a.value=b.count
   when not matched then
      insert (a.stat_name, a.stat_group, a.status, a.value, a.stat_type)
      values (b.class||' ('||b.inst_id||')', v_stat_group, 'stage', count, 'rate');

   v_stat_group := 'waitstat_time_waited';
   merge into stat_table a
   using gv$waitstat b on (a.stat_name=b.class||' ('||b.inst_id||')' and a.stat_group=v_stat_group)
   when matched then
      update set a.value=b.time
   when not matched then
      insert (a.stat_name, a.stat_group, a.status, a.value, a.stat_type, a.value_convert, a.stat_label)
      values (b.class||' ('||b.inst_id||')', v_stat_group, 'stage', time, 'rate', '/100', 'seconds/sec');
end;

procedure collect_system_waits is 
   v_stat_group varchar2(128);
begin
   v_stat_group := 'database_wait_count';

   merge into stat_table a
   using gv$system_event b on (a.stat_name=b.event||' ('||b.inst_id||')' and a.stat_group=v_stat_group)
   when matched then
      update set a.value=b.total_waits
   when not matched then
      insert (a.stat_name, a.stat_group, a.status, a.value, a.stat_type, a.tags, a.value_convert, a.stat_label)
      values (b.event||' ('||b.inst_id||')', v_stat_group, 'stage', total_waits, 'rate', '['||b.wait_class||']', '*60', 'waits/min');

   v_stat_group := 'database_wait_time';
   merge into stat_table a
   using gv$system_event b on (a.stat_name=b.event||' ('||b.inst_id||')' and a.stat_group=v_stat_group)
   when matched then
      update set a.value=b.time_waited
   when not matched then
      insert (a.stat_name, a.stat_group, a.status, a.value, a.stat_type, a.tags, a.value_convert, a.stat_label)
      values (b.event||' ('||b.inst_id||')', v_stat_group, 'stage', time_waited, 'rate', '['||b.wait_class||']', '/100*60', 'seconds/min');

end;

procedure collect_database_stats is
   v_stat_group varchar2(128);
   n number;
begin 
   v_stat_group := 'database_stats';

   merge into stat_table a
   using gv$sysstat b on (a.stat_name=b.name||' ('||b.inst_id||')' and a.stat_group=v_stat_group)
   when matched then
      update set a.value=b.value
   when not matched then
      insert (a.stat_name, a.stat_group, a.status, a.value, a.stat_type)
      values (b.name||' ('||b.inst_id||')', v_stat_group, 'stage', b.value, 'rate');

   update stat_table 
      set stat_type='value',
          value_convert='/1024/1024/1024',
          stat_label='gb'
    where (stat_name like '%pga memory%' 
       or stat_name like '%uga memory%' 
       or stat_name like '%workarea memory allocated%')
      and status='stage'
      and stat_group=v_stat_group;

   update stat_table 
      set stat_type='rate',
          value_convert='/1024/1024',
          stat_label='mb/sec'
    where stat_name like '%byte%' 
      and stat_label is null
      and status='stage'
      and stat_group=v_stat_group;

   update stat_table 
      set tags=add_tag(tags, '[!]')
    where (stat_name like 'CPU used by this session%'
       or stat_name like 'parse time cpu%'
       or stat_name like 'recursive cpu usage%'
       or stat_name like 'physical read bytes%'
       or stat_name like 'physical read IO requests%'
       or stat_name like 'physical write IO requests%'
       or stat_name like 'physical write bytes%'
       or stat_name like 'physical writes%'
       or stat_name like 'physical writes direct%'
       or stat_name like 'redo entries%'
       or stat_name like 'redo size%'
       or stat_name like 'rollback changes - undo records applied%'
       or stat_name like 'data blocks consistent reads - undo records applied%'
       or stat_name like 'parse %'
       or stat_name like 'sorts%'
       or stat_name like 'enq%'
       or stat_name like '%corrupt%'
       or stat_name like 'DB time%'
       or stat_name like 'Effective IO time %'
       or stat_name like '%timeout%'
       or stat_name like '%file io %'
       or stat_name like 'user I/O wait time%'
       or stat_name like 'bytes received %'
       or stat_name like 'bytes sent %')
      and status='stage'
      and stat_group=v_stat_group;
   
   select count(*) into n from gv$archived_log where first_time >= sysdate-1;
   collect_stat(p_stat_name=>'archive_log_count_24h', 
      p_stat_group=>v_stat_group, 
      p_value=>n,
      p_tags=>'[!]');

end;

procedure collect_sga_stats is 
    v_stat_group varchar2(128);
begin 
   v_stat_group := 'sga_stats';

   merge into stat_table a
   using gv$sgastat b on (a.stat_name=b.pool||' '||b.name||' ('||b.inst_id||')' and a.stat_group=v_stat_group)
   when matched then
      update set a.value=b.bytes
   when not matched then
      insert (a.stat_name, a.stat_group, a.status, a.value, a.stat_type, a.value_convert, a.stat_label)
      values (b.pool||' '||b.name||' ('||b.inst_id||')', v_stat_group, 'stage', b.bytes, 'value', '/1024/1024/1024', 'gb');

end;

end;
/
