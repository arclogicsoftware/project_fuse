create or replace trigger stat_table_before_update 
   before update on stat_table for each row 
declare
   mm_changed boolean := false;
   ddd_changed boolean := false;
   hh24_changed boolean := false;
   last_hh24 number;
   this_hh24 number;
   last_mm number;
   this_mm number;
   last_d number;
   this_d number;
   hr_val number;
   ref_val number;
begin

   /* 
   If a user runs an update on this table we may not want this trigger to fire.
   This is likely the case when 'value' is not being updated.
   But we also do not want to fire this trigger if the row is not 'active' yet.
   */
   if not updating('value') or :new.status != 'active' then 
      return;
   end if;

   -- The value_time can be specified but usually defaults to systimestamp.
   if not updating('value_time') then
      :new.value_time := systimestamp;
   end if;

   /*
   We need to know things like when the hour, day, or month changes.
   We compare the last time the value was updated to the current time.
   */

   last_mm := to_number(to_char(:old.value_time ,'MM')); -- Not used but may be so leave here.
   this_mm := to_number(to_char(:new.value_time ,'MM'));
   mm_changed := to_char(:old.value_time ,'YYYY-MM') != to_char(:new.value_time ,'YYYY-MM');

   -- Sun = 1 and Sat = 7
   last_d := to_number(to_char(:old.value_time ,'D')); -- Not used but may be so leave here.
   this_d := to_number(to_char(:new.value_time ,'D'));
   ddd_changed := to_char(:old.value_time ,'YYYY-DDD') != to_char(:new.value_time ,'YYYY-DDD');

   last_hh24 := to_number(to_char(:old.value_time ,'HH24')); -- Not used but may be so leave here.
   this_hh24 := to_number(to_char(:new.value_time ,'HH24'));
   :new.hour := this_hh24;
   hh24_changed := to_char(:old.value_time ,'YYYY-DDD-HH24') != to_char(:new.value_time ,'YYYY-DDD-HH24');

   -- Things we need to do when the hour changes.
   if hh24_changed then 
      :new.hh24_total := 0;
      :new.hh24_count := 0;
      if :old.hh24_pct_of_ref is not null then
         :new.rolling_hh24_pct_of_ref := ltrim(shift_list (
            p_list=>:old.rolling_hh24_pct_of_ref,
            p_token=>',',
            p_max_items=>72) || ','|| to_char(:old.hh24_pct_of_ref), ',');
      end if;
      /*
      In the next two blocks we reset *ref_hrs and *ref_days. We do not reset *ref_mins here.
      *ref_mins is a consecutive value and resets when hh24_pct_of_ref is over or under the defined range.
      To grok this search for above_ref_mi and below_ref_mi in this file.
      */
   end if;

   -- Things we need to do when the day changes.
   if ddd_changed then 
      :new.ddd_total := 0;
      :new.ddd_count := 0;
   end if;

   -- Things we need to do when the month changes.
   if mm_changed then
      :new.mm_total := 0;
      :new.mm_count := 0;
   end if;

   :new.time_delta := secs_between_timestamps(:old.value_time, :new.value_time);

   :new.delta_value := :new.value - :old.value;

   -- This is calculated even if the stat type is 'value' which is fine. We are not 
   -- using any of this data when 'value'.
   if :new.delta_value < 0 then 
      :new.neg_delta_count := :old.neg_delta_count + 1;
   end if;

   if :new.zero_neg_deltas = 1 and :new.delta_value < 0 then 
      :new.delta_value := 0;
   end if;

   if :new.time_delta > 0 then 
      :new.rate_per_sec := round(:new.delta_value / :new.time_delta, 2);
   else 
      :new.rate_per_sec := 0;
   end if;

   :new.hh24_count := :new.hh24_count + 1;
   :new.ddd_count := :new.ddd_count + 1;
   :new.mm_count := :new.mm_count + 1;

   if :new.stat_type = 'value' then 
      :new.stat_value := :new.value;
      if :new.value_convert is not null then 
         :new.stat_value := str_eval_math(:new.stat_value||:new.value_convert);
      end if;
      :new.hh24_total := :new.hh24_total + :new.stat_value;
      :new.ddd_total := :new.ddd_total + :new.stat_value;
      :new.mm_total := :new.mm_total + :new.stat_value;
   elsif :new.stat_type = 'delta' then 
      :new.stat_value := :new.delta_value;
      if :new.value_convert is not null then 
         :new.stat_value := str_eval_math(:new.stat_value||:new.value_convert);
      end if;
      :new.hh24_total := :new.hh24_total + :new.stat_value;
      :new.ddd_total := :new.ddd_total + :new.stat_value;
      :new.mm_total := :new.mm_total + :new.stat_value;
   elsif :new.stat_type = 'rate' then 
      :new.stat_value := :new.rate_per_sec;
      if :new.value_convert is not null then 
         :new.stat_value := str_eval_math(:new.stat_value||:new.value_convert);
      end if;
      :new.hh24_total := :new.hh24_total + :new.stat_value;
      :new.ddd_total := :new.ddd_total + :new.stat_value;
      :new.mm_total := :new.mm_total + :new.stat_value;
   end if;

   if hh24_changed then
      -- When the hour changes get the top N hours in last 24 
      -- and the avg of that becomes the value we use as our 
      -- baseline for the current day.
      ref_val := round(str_avg_list(str_top_n_list(
         p_values=>:old.hour0||','||:old.hour1||','||:old.hour2||','||:old.hour3||','||:old.hour4||','||:old.hour6||','||:old.hour7||','||:old.hour8||','||:old.hour9||','||:old.hour10||','||:old.hour11||','||:old.hour12||','||:old.hour13||','||:old.hour14||','||:old.hour15||','||:old.hour16||','||:old.hour17||','||:old.hour18||','||:old.hour19||','||:old.hour20||','||:old.hour21||','||:old.hour22||','||:old.hour23,
         p_top_count=>6)), 2);
      case this_d
         when 1 then 
            :new.sun_ref := ref_val;
         when 2 then 
            :new.mon_ref := ref_val;
         when 3 then
            :new.tue_ref := ref_val;
         when 4 then
            :new.wed_ref := ref_val;
         when 5 then
            :new.thu_ref := ref_val;
         when 6 then
            :new.fri_ref := ref_val;
         when 7 then
            :new.sat_ref := ref_val;
      end case;
      -- The baseline we compare to is the top 5 daily refs above.
      :new.ref_val := round(str_avg_list(str_top_n_list(
         p_values=>:new.sun_ref||','||:new.mon_ref||','||:new.tue_ref||','||:new.wed_ref||','||:new.thu_ref||','||:new.fri_ref||','||:new.sat_ref,
         p_top_count=>5)), 2);
   end if;

   :new.rolling_stat_value := ltrim(shift_list (
      p_list=>:old.rolling_stat_value,
      p_token=>',',
      p_max_items=>12*1) || ','|| to_char(:new.stat_value), ',');

   -- Average value of the stat for the current day
   :new.hh24_avg := round(:new.hh24_total / :new.hh24_count, 2);

   if :new.ref_val is null or :new.ref_val = 0 then 
      :new.hh24_pct_of_ref := 100;
   else
      :new.hh24_pct_of_ref := round((:new.hh24_avg/:new.ref_val)*100);
   end if;

   case this_hh24 
      when 0 then
         :new.hour0 := :new.hh24_avg;
      when 1 then 
         :new.hour1 := :new.hh24_avg;
      when 2 then 
         :new.hour2 := :new.hh24_avg;
      when 3 then 
         :new.hour3 := :new.hh24_avg;
      when 4 then 
         :new.hour4 := :new.hh24_avg;
      when 5 then 
         :new.hour5 := :new.hh24_avg;
      when 6 then 
         :new.hour6 := :new.hh24_avg;
      when 7 then 
         :new.hour7 := :new.hh24_avg;
      when 8 then 
         :new.hour8 := :new.hh24_avg;
      when 9 then 
         :new.hour9 := :new.hh24_avg;
      when 10 then 
         :new.hour10 := :new.hh24_avg;
      when 11 then 
         :new.hour11 := :new.hh24_avg;
      when 12 then 
         :new.hour12 := :new.hh24_avg;
      when 13 then 
         :new.hour13 := :new.hh24_avg;
      when 14 then 
         :new.hour14 := :new.hh24_avg;
      when 15 then 
         :new.hour15 := :new.hh24_avg;
      when 16 then 
         :new.hour16 := :new.hh24_avg;
      when 17 then 
         :new.hour17 := :new.hh24_avg;
      when 18 then 
         :new.hour18 := :new.hh24_avg;
      when 19 then 
         :new.hour19 := :new.hh24_avg;
      when 20 then 
         :new.hour20 := :new.hh24_avg;
      when 21 then 
         :new.hour21 := :new.hh24_avg;
      when 22 then 
         :new.hour22 := :new.hh24_avg;
      when 23 then 
         :new.hour23 := :new.hh24_avg;
   end case;

   :new.ddd_avg := round(:new.ddd_total / :new.ddd_count, 2);

   case this_d
      when 1 then 
         :new.sun := :new.ddd_avg;
      when 2 then 
         :new.mon := :new.ddd_avg;
      when 3 then
         :new.tue := :new.ddd_avg;
      when 4 then
         :new.wed := :new.ddd_avg;
      when 5 then
         :new.thu := :new.ddd_avg;
      when 6 then
         :new.fri := :new.ddd_avg;
      when 7 then
         :new.sat := :new.ddd_avg;
   end case;

   if :new.mm_count != 0 and :new.mm_count is not null then
      :new.mm_avg := round(:new.mm_total / :new.mm_count, 2);
   end if;

   case this_mm
      when 1 then
         :new.jan := :new.mm_avg;
      when 2 then
         :new.feb := :new.mm_avg;
      when 3 then
         :new.mar := :new.mm_avg;
      when 4 then
         :new.apr := :new.mm_avg;
      when 5 then
         :new.may := :new.mm_avg;
      when 6 then
         :new.jun := :new.mm_avg;
      when 7 then
         :new.jul := :new.mm_avg;
      when 8 then
         :new.aug := :new.mm_avg;
      when 9 then 
         :new.sep := :new.mm_avg;
      when 10 then
         :new.oct := :new.mm_avg;
      when 11 then
         :new.nov := :new.mm_avg;
      when 12 then 
         :new.dec := :new.mm_avg;
   end case;

end;
/
