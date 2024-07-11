create or replace view ts_gb_per_day as
select tablespace_name,
       round(sum(mb_per_day)/1024, 1) gb_per_day
  from (
select tablespace_name,
       round(str_avg_list(avg_mb||','||max_mb)/30, 2) mb_per_day,
       segment_name,
       owner,
       last_size,
       jan
  from (
select nvl(round(str_avg_list(
       decode(jan, 0, null, jan)||','||
       decode(feb, 0, null, feb)||','||
       decode(mar, 0, null, mar)||','||
       decode(apr, 0, null, apr)||','||
       decode(may, 0, null, may)||','||
       decode(jun, 0, null, jun)||','||
       decode(jul, 0, null, jul)||','||
       decode(aug, 0, null, aug)||','||
       decode(sep, 0, null, sep)||','||
       decode(oct, 0, null, oct)||','||
       decode(nov, 0, null, nov)||','||
       decode(dec, 0, null, dec))), 0) avg_mb,
       str_max_list(jan||','||feb||','||mar||','||apr||','||may||','||jun||','||jul||','||aug||','||sep||','||oct||','||nov||','||dec) max_mb,
       a.*
  from obj_size_data a)) group by tablespace_name;
  
create or replace view tsinfo as
select a.tablespace_name,
       a.objects_gb,
       b.datafile_gb,
       b.datafile_gb-a.objects_gb free_gb,
       round(decode(b.datafile_gb, 0, 0, a.objects_gb/b.datafile_gb*100)) pct_full,
       c.gb_per_day,
       case 
          when c.gb_per_day = 0 then round((b.datafile_gb-a.objects_gb)/.01)
          else round((b.datafile_gb-a.objects_gb)/c.gb_per_day)
       end as estimated_days_remaining,
       b.datafile_max_gb,
       round(decode(b.datafile_max_gb, 0, 0, a.objects_gb/b.datafile_max_gb*100)) autoextend_pct_full,
       b.can_extend_gb,
       case 
          when c.gb_per_day = 0 then round((b.datafile_max_gb-a.objects_gb)/.01)
          else round((b.datafile_max_gb-a.objects_gb)/c.gb_per_day)
       end as max_days_remaining
  from (select tablespace_name,
               round(sum(bytes/1024/1024/1024), 1) objects_gb
          from dba_segments
         group 
            by tablespace_name) a,
        (select tablespace_name,
                sum(datafile_gb) datafile_gb,
                sum(can_extend_gb) can_extend_gb,
                sum(datafile_max_gb) datafile_max_gb
           from (
         select to_gb(decode(maxbytes, 0, bytes, maxbytes))-to_gb(bytes) can_extend_gb, 
                to_gb(decode(maxbytes, 0, bytes, maxbytes)) datafile_max_gb,
                to_gb(bytes) datafile_gb, 
                file_name,
                tablespace_name
           from dba_data_files a
           where online_status='ONLINE')
           group
              by tablespace_name) b,
        ts_gb_per_day c
 where a.tablespace_name=b.tablespace_name
   and a.tablespace_name=c.tablespace_name;

create or replace public synonym tsinfo for tsinfo;

-- select * from tsinfo order by 6 desc;