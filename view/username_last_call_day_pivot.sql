
-- Patch
exec drop_view('username_last_call_day_dist');

create or replace view username_last_call_day_pivot as
select username||' ('||count(*)||')' username,
       sum(decode(last_call_days, 0, 1, 0)) "0",
       sum(decode(last_call_days, 1, 1, 0)) "1",
       sum(decode(last_call_days, 2, 1, 0)) "2",
       sum(decode(last_call_days, 3, 1, 0)) "3",
       sum(decode(last_call_days, 4, 1, 0)) "4",
       sum(decode(last_call_days, 5, 1, 0)) "5",
       sum(decode(last_call_days, 6, 1, 0)) "6",
       sum(decode(last_call_days, 7, 1, 0)) "7",
       sum(decode(last_call_days, 8, 1, 0)) "8",
       sum(decode(last_call_days, 9, 1, 0)) "9",
       sum(decode(last_call_days, 10, 1, 0)) "10",
       sum(decode(last_call_days, 11, 1, 0)) "11",
       sum(decode(last_call_days, 12, 1, 0)) "12",
       sum(decode(last_call_days, 13, 1, 0)) "13",
       sum(decode(last_call_days, 14, 1, 0)) "14",
       sum(decode(last_call_days, 15, 1, 0)) "15",
       sum(decode(last_call_days, 16, 1, 0)) "16",
       sum(decode(last_call_days, 17, 1, 0)) "17",
       sum(decode(last_call_days, 18, 1, 0)) "18",
       sum(decode(last_call_days, 19, 1, 0)) "19",
       sum(decode(last_call_days, 20, 1, 0)) "20",
       sum(decode(last_call_days, 21, 1, 0)) "21",
       sum(decode(last_call_days, 22, 1, 0)) "22",
       sum(decode(last_call_days, 23, 1, 0)) "23",
       sum(decode(last_call_days, 24, 1, 0)) "24",
       sum(decode(last_call_days, 25, 1, 0)) "25",
       sum(decode(last_call_days, 26, 1, 0)) "26",
       sum(decode(last_call_days, 27, 1, 0)) "27",
       sum(decode(last_call_days, 28, 1, 0)) "28",
       sum(decode(last_call_days, 29, 1, 0)) "29",
       sum(decode(last_call_days, 30, 1, 0)) "30",
       sum(case when last_call_days > 30 then 1 else 0 end) ">30"
  from (
        select username,
        round(last_call_et / 86400) last_call_days
          from gv$session
       )
 group by username
 order by username;