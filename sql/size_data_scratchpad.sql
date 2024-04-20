



select * from obj_size_data;

select round(sum(start_size)/1024) starting_gb, 
       round(sum(last_size)/1024) last_gb, 
       round(sum(jan)/1024, 1) jan_gb, 
       round(sum(feb)/1024, 1) feb_gb,
       round(sum(mar)/1024, 1) mar_gb, 
       round(sum(apr)/1024, 1) apr_gb,
       round(sum(may)/1024, 1) may_gb,
       round(sum(jun)/1024, 1) jun_gb,
       round(sum(jul)/1024, 1) jul_gb,
       round(sum(aug)/1024, 1) aug_gb,
       round(sum(sep)/1024, 1) sep_gb,
       round(sum(oct)/1024, 1) oct_gb,
       round(sum(nov)/1024, 1) nov_gb,
       round(sum(dec)/1024, 1) dec_gb
  from obj_size_data;