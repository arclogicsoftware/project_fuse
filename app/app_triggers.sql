

create or replace trigger stat_table_before_update 
   before update on stat_table for each row 
begin 
   if updating('value_convert') then 
      :new.stat_value := str_eval_math(:new.stat_value||:new.value_convert);
      if :new.hh24_avg is not null then 
         :new.hh24_avg := str_eval_math(:new.hh24_avg||:new.value_convert);
      end if;
      if :new.ref_val is not null then 
         :new.ref_val := str_eval_math(:new.ref_val||:new.value_convert);
      end if;
      if :new.ddd_avg is not null then 
         :new.ddd_avg := str_eval_math(:new.ddd_avg||:new.value_convert);
      end if;
      if :new.mm_avg is not null then
         :new.mm_avg := str_eval_math(:new.mm_avg||:new.value_convert);
      end if;
      if :new.hour0 is not null then 
         :new.hour0 := str_eval_math(:new.hour0||:new.value_convert);
      end if;
      if :new.hour1 is not null then 
         :new.hour1 := str_eval_math(:new.hour1||:new.value_convert);
      end if;
      if :new.hour2 is not null then 
         :new.hour2 := str_eval_math(:new.hour2||:new.value_convert);
      end if;
      if :new.hour3 is not null then 
         :new.hour3 := str_eval_math(:new.hour3||:new.value_convert);
      end if;
      if :new.hour4 is not null then 
         :new.hour4 := str_eval_math(:new.hour4||:new.value_convert);
      end if;
      if :new.hour5 is not null then 
         :new.hour5 := str_eval_math(:new.hour5||:new.value_convert);
      end if;
      if :new.hour6 is not null then 
         :new.hour6 := str_eval_math(:new.hour6||:new.value_convert);
      end if;
      if :new.hour7 is not null then 
         :new.hour7 := str_eval_math(:new.hour7||:new.value_convert);
      end if;
      if :new.hour8 is not null then 
         :new.hour8 := str_eval_math(:new.hour8||:new.value_convert);
      end if;
      if :new.hour9 is not null then 
         :new.hour9 := str_eval_math(:new.hour9||:new.value_convert);
      end if;
      if :new.hour10 is not null then 
         :new.hour10 := str_eval_math(:new.hour10||:new.value_convert);
      end if;
      if :new.hour11 is not null then 
         :new.hour11 := str_eval_math(:new.hour11||:new.value_convert);
      end if;
      if :new.hour12 is not null then 
         :new.hour12 := str_eval_math(:new.hour12||:new.value_convert);
      end if;
      if :new.hour13 is not null then 
         :new.hour13 := str_eval_math(:new.hour13||:new.value_convert);
      end if;
      if :new.hour14 is not null then 
         :new.hour14 := str_eval_math(:new.hour14||:new.value_convert);
      end if;
      if :new.hour15 is not null then 
         :new.hour15 := str_eval_math(:new.hour15||:new.value_convert);
      end if;
      if :new.hour16 is not null then 
         :new.hour16 := str_eval_math(:new.hour16||:new.value_convert);
      end if;
      if :new.hour17 is not null then 
         :new.hour17 := str_eval_math(:new.hour17||:new.value_convert);
      end if;
      if :new.hour18 is not null then 
         :new.hour18 := str_eval_math(:new.hour18||:new.value_convert);
      end if;
      if :new.hour19 is not null then 
         :new.hour19 := str_eval_math(:new.hour19||:new.value_convert);
      end if;
      if :new.hour20 is not null then 
         :new.hour20 := str_eval_math(:new.hour20||:new.value_convert);
      end if;
      if :new.hour21 is not null then 
         :new.hour21 := str_eval_math(:new.hour21||:new.value_convert);
      end if;
      if :new.hour22 is not null then 
         :new.hour22 := str_eval_math(:new.hour22||:new.value_convert);
      end if;
      if :new.hour23 is not null then 
         :new.hour23 := str_eval_math(:new.hour23||:new.value_convert);
      end if;
      if :new.mon is not null then
         :new.mon := str_eval_math(:new.mon||:new.value_convert);
      end if;
      if :new.tue is not null then
         :new.tue := str_eval_math(:new.tue||:new.value_convert);
      end if;
      if :new.wed is not null then
         :new.wed := str_eval_math(:new.wed||:new.value_convert);
      end if;
      if :new.thu is not null then
         :new.thu := str_eval_math(:new.thu||:new.value_convert);
      end if;
      if :new.fri is not null then
         :new.fri := str_eval_math(:new.fri||:new.value_convert);
      end if;
      if :new.sat is not null then
         :new.sat := str_eval_math(:new.sat||:new.value_convert);
      end if;
      if :new.sun is not null then
         :new.sun := str_eval_math(:new.sun||:new.value_convert);
      end if;
      if :new.jan is not null then
         :new.jan := str_eval_math(:new.jan||:new.value_convert);
      end if;
      if :new.feb is not null then
         :new.feb := str_eval_math(:new.feb||:new.value_convert);
      end if;
      if :new.mar is not null then
         :new.mar := str_eval_math(:new.mar||:new.value_convert);
      end if;
      if :new.apr is not null then
         :new.apr := str_eval_math(:new.apr||:new.value_convert);
      end if;
      if :new.may is not null then
         :new.may := str_eval_math(:new.may||:new.value_convert);
      end if;
      if :new.jun is not null then
         :new.jun := str_eval_math(:new.jun||:new.value_convert);
      end if;
      if :new.jul is not null then
         :new.jul := str_eval_math(:new.jul||:new.value_convert);
      end if;
      if :new.aug is not null then
         :new.aug := str_eval_math(:new.aug||:new.value_convert);
      end if;
      if :new.sep is not null then
         :new.sep := str_eval_math(:new.sep||:new.value_convert);
      end if;
      if :new.oct is not null then
         :new.oct := str_eval_math(:new.oct||:new.value_convert);
      end if;
      if :new.nov is not null then
         :new.nov := str_eval_math(:new.nov||:new.value_convert);
      end if;
      if :new.dec is not null then
         :new.dec := str_eval_math(:new.dec||:new.value_convert);
      end if;
      if :new.hh24_total is not null then
         :new.hh24_total := str_eval_math(:new.hh24_total||:new.value_convert);
      end if;
      if :new.ddd_total is not null then
         :new.ddd_total := str_eval_math(:new.ddd_total||:new.value_convert);
      end if;
      if :new.mm_total is not null then
         :new.mm_total := str_eval_math(:new.mm_total||:new.value_convert);
      end if;
   end if;
end;
/

create or replace trigger stat_table_before_insert 
   before insert on stat_table for each row 
begin 
   null;
   -- if :new.stat_type not in ('rate', 'delta') then 
   --    :new.hh24_total := :new.value;
   --    :new.ddd_total := :new.value;
   --    :new.mm_total := :new.value;
   --    :new.hh24_total_count := 1;
   --    :new.ddd_total_count := 1;
   --    :new.mm_total_count := 1;
   --    :new.stat_value := :new.value;
   -- end if;
end;
/

