
-- exec drop_package('sql_monitor');
create or replace package sql_monitor as 

   sql_log_analyze_min_secs number := 1;

   function get_elapsed_seconds_ptile (
      p_force_matching_signature in number,
      p_value in number
      ) return number deterministic;

   function get_elapsed_seconds_ptile (
      p_sql_id in varchar2,
      p_value in number
      ) return number deterministic;

   function get_elap_secs_per_exe_ptile (
      p_force_matching_signature in number,
      p_value in number
      ) return number deterministic;

   function get_elap_secs_per_exe_ptile (
      p_sql_id in varchar2,
      p_value in number
      ) return number deterministic;

   function get_executions_ptile (
      p_force_matching_signature in number,
      p_value in number
      ) return number deterministic;

   function get_executions_ptile (
      p_sql_id in varchar2,
      p_value in number
      ) return number deterministic;

   procedure update_ptiles;
   procedure update_refs;
   
   procedure monitor (
      p_interval_mins in number default 18);

end;
/
