-- exec drop_package('collect_stat');
create or replace package collect_stat as 

   type timer_type is table of date index by varchar2(120);
   g_timer timer_type;

   function has_tag (
      p_tags in varchar2,
      p_check_tag in varchar2)
      return number deterministic;
   
   procedure auto_activate;

   procedure process_stat_views;

   function add_tag (
      p_tags in varchar2,
      p_add_tag in varchar2)
      return varchar2;

   procedure collect;

   procedure collect_stat (
      -- 'stat_name' and 'stat_group' uniquely identify a stat.
      p_stat_name in varchar2,
      p_stat_group in varchar2,
      p_value in number,
      -- Can be one of 'delta', 'rate', or 'value'.
      p_stat_type in varchar2 default 'value',
      p_tags in varchar2 default null,
      -- Mathmatical string expression to append to the calculated value. Example, if value is seconds, use '/60' to convert to minutes.
      p_value_convert in varchar2 default null,
      -- Custom label for the stat. Highly recommended if you are using p_value_convert.
      p_stat_label in varchar2 default null);

   procedure collect_meta_stats;

   procedure collect_waitstats;

   procedure collect_system_waits;

   procedure collect_database_stats;

   procedure collect_sga_stats;

   procedure collect_file_stats;

end;
/
