
exec drop_view('standby_avg_completion_time');

create or replace view standby_completion_time_detail as
select a.sequence#,
       a.inst_id,
       a.thread#,
       a.completion_time,
       round((b.completion_time-a.completion_time)*24*60, 1) mins
  from (select sequence#, completion_time, inst_id, creator, thread# from gv$archived_log where dest_id=1 and creator != 'RMAN') a,
       (select sequence#, completion_time, inst_id, creator, thread# from gv$archived_log where dest_id=2 and creator != 'RMAN') b
 where a.sequence#=b.sequence#
   and a.inst_id=b.inst_id
   and a.thread#=b.thread#;
 
exec drop_view('standby_completion_time_summary');

create or replace view standby_completion_time as 
select trunc(completion_time) completion_date,
       inst_id,
       thread#,
       sum(decode(sign(mins), -1, 0, mins)) mins,
       count(*) log_count
  from standby_completion_time_detail
 group
    by trunc(completion_time),
       inst_id,
       thread#;    
 

