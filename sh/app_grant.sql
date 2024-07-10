select * from stat_table where value_time >= systimestamp - interval '1' day and hh24_avg > ref_val*2 or ddd_avg > ref_val*2 or mm_avg > ref_val*2 order by stat_value desc;

select * from v$instance;

select * from v$database;

