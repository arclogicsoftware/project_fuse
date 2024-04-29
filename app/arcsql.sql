
-- drop procedure execute_sql;
create or replace procedure execute_sql (
  sql_text varchar2, 
  ignore_errors boolean := false) authid current_user is
begin
   execute immediate sql_text;
exception
   when others then
      if not ignore_errors then
         raise;
      end if;
end;
/

-- drop procedure drop_object;
create or replace procedure drop_object (object_name varchar2, object_type varchar2) is
   n number;
begin
   select count(*) into n
     from user_objects 
    where object_name=upper(drop_object.object_name)
      and object_type=upper(drop_object.object_type);
   if n > 0 then
      if upper(drop_object.object_type) = 'TABLE' then 
         execute immediate 'drop table '||upper(drop_object.object_name)||' cascade constraints purge';
      else 
         execute immediate 'drop '||upper(drop_object.object_type)||' '||upper(drop_object.object_name);
      end if;
   end if;
exception
   when others then
      raise;
end;
/

-- drop function does_object_exist;
create or replace function does_object_exist (object_name varchar2, object_type varchar2) return boolean authid current_user is
   n number;
begin
   if upper(does_object_exist.object_type) = 'TYPE' then
      select count(*) into n 
        from user_types
       where type_name=upper(does_object_exist.object_name);
   elsif upper(does_object_exist.object_type) = 'CONSTRAINT' then
      select count(*) into n 
        from user_constraints
       where constraint_name=upper(does_object_exist.object_name);
   elsif upper(does_object_exist.object_type) = 'PACKAGE' then
      select count(*) into n 
        from all_source 
       where name=upper(does_object_exist.object_name) 
         and type='PACKAGE';
   else
      select count(*) into n 
        from user_objects 
       where object_type = upper(does_object_exist.object_type)
         and object_name = upper(does_object_exist.object_name);
   end if;
   if n > 0 then
      return true;
   else
      return false;
   end if;
end;
/

-- drop procedure drop_view;
create or replace procedure drop_view (view_name in varchar2) is 
begin 
  if does_object_exist(drop_view.view_name, 'VIEW') then 
     execute_sql('drop view '||drop_view.view_name);
  end if;
end;
/

-- drop procedure drop_function;
create or replace procedure drop_function (function_name in varchar2) is 
begin 
  if does_object_exist(drop_function.function_name, 'FUNCTION') then 
     execute_sql('drop function '||drop_function.function_name);
  end if;
end;
/

-- drop procedure drop_procedure;
create or replace procedure drop_procedure (procedure_name in varchar2) is 
begin 
  if does_object_exist(drop_procedure.procedure_name, 'PROCEDURE') then 
     execute_sql('drop procedure '||drop_procedure.procedure_name);
  end if;
end;
/

-- drop procedure drop_type;
create or replace procedure drop_type (type_name in varchar2) is 
begin 
  if does_object_exist(drop_type.type_name, 'TYPE') then 
     execute_sql('drop type '||drop_type.type_name);
  end if;
end;
/

create or replace procedure drop_trigger (trigger_name in varchar2) is 
begin 
  if does_object_exist(drop_trigger.trigger_name, 'TRIGGER') then 
     execute_sql('drop trigger '||drop_trigger.trigger_name);
  end if;
end;
/

-- drop function does_package_exist;
create or replace function does_package_exist (package_name in varchar2) return boolean is 
begin 
  if does_object_exist(does_package_exist.package_name, 'PACKAGE') then
      return true;
   else
      return false;
   end if;
end;
/

-- drop function does_procedure_exist;
create or replace function does_procedure_exist (procedure_name in varchar2) return boolean is 
begin 
  if does_object_exist(does_procedure_exist.procedure_name, 'PROCEDURE') then
      return true;
   else
      return false;
   end if;
end;
/

-- drop procedure drop_package;
create or replace procedure drop_package (package_name in varchar2) is 
begin 
   if does_package_exist(drop_package.package_name) then 
      execute_sql('drop package '||drop_package.package_name);
   end if;
end;
/

-- drop function does_table_exist;
create or replace function does_table_exist (table_name varchar2) return boolean is
begin
   if does_object_exist(does_table_exist.table_name, 'TABLE') then
      return true;
   else
      return false;
   end if;
end;
/

-- drop function does_column_exist;
create or replace function does_column_exist (table_name varchar2, column_name varchar2) return boolean is
   n number;
begin
   select count(*) into n from user_tab_columns 
    where table_name=upper(does_column_exist.table_name)
      and column_name=upper(does_column_exist.column_name);
   if n > 0 then
      return true;
   else
      return false;
   end if;
exception 
   when others then
      raise;
end;
/

-- drop function is_column_nullable;
create or replace function is_column_nullable (table_name varchar2, column_name varchar2) return boolean is
   n number;
begin 
   select count(*) into n from user_tab_columns 
    where table_name=upper(is_column_nullable.table_name)
      and column_name=upper(is_column_nullable.column_name)
      and nullable='Y';
   if n > 0 then
      return true;
   else
      return false;
   end if;
exception 
   when others then
      raise;
end;
/

-- drop procedure drop_column;
create or replace procedure drop_column (
   table_name in varchar2,
   column_name in varchar2) is 
n number;
begin 
   if does_column_exist(
      table_name, column_name) then 
      execute_sql('alter table '||table_name||' drop column '||column_name);
   end if;
exception 
   when others then
      raise;
end;
/

-- drop function does_index_exist;
create or replace function does_index_exist (index_name varchar2) return boolean is
begin
   if does_object_exist(does_index_exist.index_name, 'INDEX') then
      return true;
   else
      return false;
   end if;
exception
   when others then
   raise;
end;
/

-- drop function does_constraint_exist;
create or replace function does_constraint_exist (constraint_name varchar2) return boolean is
begin
   if does_object_exist(does_constraint_exist.constraint_name, 'CONSTRAINT') then
      return true;
   else
      return false;
   end if;
exception
   when others then
   raise;
end;
/

-- drop procedure add_primary_key;
create or replace procedure add_primary_key (
   table_name in varchar2,
   column_name in varchar2) is 
begin 
   if not does_constraint_exist('pk_'||table_name) then 
      execute_sql('alter table '||table_name||' add constraint pk_'||table_name||' primary key ('||column_name||')');
   end if;
end;
/

-- drop procedure drop_constraint;
create or replace procedure drop_constraint (p_constraint_name varchar2) is 
   x user_constraints%rowtype;
begin 
   if does_constraint_exist(p_constraint_name) then 
      select table_name, constraint_name into x.table_name, x.constraint_name from user_constraints where constraint_name=upper(p_constraint_name);
      execute immediate 'alter table '||x.table_name||' drop constraint '||x.constraint_name;
   end if;
end;
/

-- drop procedure drop_index;
create or replace procedure drop_index(index_name varchar2) is 
begin
  if does_object_exist(drop_index.index_name, 'INDEX') then
    drop_object(drop_index.index_name, 'INDEX');
  end if;
exception
  when others then
     raise;
end;
/


-- drop procedure drop_table;
create or replace procedure drop_table ( -- | Drop a table if it exists. No error if it doesn't.
   table_name varchar2,
   bool_test in boolean default true) -- | Pass in a boolean test and table is only dropped if it is true.
   is
begin
   if bool_test then 
      drop_object(drop_table.table_name, 'TABLE');
   end if;  
end;
/


-- drop function does_sequence_exist;
create or replace function does_sequence_exist (sequence_name varchar2) return boolean is
   n number;
begin
   select count(*) into n 
     from user_sequences
    where sequence_name=upper(does_sequence_exist.sequence_name);
   if n = 0 then
      return false;
   else
      return true;
   end if;
exception
   when others then
      raise; 
end;
/


-- drop procedure drop_sequence;
create or replace procedure drop_sequence (sequence_name varchar2) is 
begin  
    drop_object(sequence_name, 'SEQUENCE');
end;
/


-- drop procedure create_sequence;
create or replace procedure create_sequence (sequence_name in varchar2) is 
begin
   if not does_sequence_exist(sequence_name) then
      execute_sql('create sequence '||sequence_name, false);
   end if;
end;
/


-- drop function does_scheduler_job_exist;
create or replace function does_scheduler_job_exist (p_job_name in varchar2) return boolean is
   n number;
begin 
   select count(*) into n from all_scheduler_jobs
    where job_name=upper(p_job_name);
   if n = 0 then 
      return false;
   else 
      return true;
   end if;
end;
/

-- drop procedure drop_scheduler_job;
create or replace procedure drop_scheduler_job (p_job_name in varchar2) is 
begin
   if does_scheduler_job_exist(p_job_name) then 
      dbms_scheduler.drop_job(p_job_name);
   end if;
end;
/

-- Needs to be a standalong func here and not in arcsql package becuase authid current user is used.
-- drop function num_get_val_from_sql;
create or replace function num_get_val_from_sql(sql_text in varchar2) return number authid current_user is 
   n number;
begin
   execute immediate sql_text into n;
   return n;
end;
/


-- drop function does_database_account_exist;
create or replace function does_database_account_exist (username varchar2) return boolean is 
   n number;
begin
   select count(*) into n from all_users 
    where username=upper(does_database_account_exist.username);
   if n = 1 then 
      return true;
   else 
      return false;
   end if;
end;
/

-- drop procedure fix_identity_sequences;
create or replace procedure fix_identity_sequences is 
   cursor c_identify_sequences is 
      select table_name, column_name, sequence_name 
        from user_tab_identity_cols
       -- These are deleted table in recycle bin and the $ in table name raises error in one of the statements below.
       where table_name not like 'BIN$%';
   max_value number;
   next_value number;
begin 
   for c in c_identify_sequences loop 
      -- For debug only, usually this would not exist when this proc is first created and would throw error if run.
      -- arcsql.debug('fix_identity_sequences: '||c.table_name||', '||c.column_name||', '||c.sequence_name);
      execute immediate 'select max('||c.column_name||') from '||c.table_name into max_value;
      execute immediate 'select '||c.sequence_name||'.nextval from dual' into next_value;
      if max_value > next_value then 
         execute immediate 'alter table '||c.table_name||' modify '||c.column_name||' generated as identity (start with '||to_number(max_value+100)||')';
      end if;
   end loop;
end;
/

exec drop_procedure('add_pk_constraint');

create or replace procedure create_lookup_table (
   p_name in varchar2) is 
begin 
   if not does_table_exist(p_name) then 
      execute_sql('
         create table '||p_name||' (
         '||p_name||' varchar2(512)
         )');
      add_primary_key(p_name, p_name);
   end if;
end;
/

create or replace procedure add_lookup_value (
   p_name in varchar2,
   p_value in varchar2) is 
begin 
   execute immediate 'update '||p_name||' set '||p_name||'='''||p_value||''' where '||p_name||'='''||p_value||'''';
   if sql%notfound then
      execute immediate 'insert into '||p_name||' ('||p_name||') values ('''||p_value||''')';
   end if;
end;
/

create or replace procedure add_foreign_key (
   p_table in varchar2,
   p_column in varchar2,
   p_parent_table in varchar2,
   p_parent_column in varchar2,
   p_cascade in boolean default false) is 
   v_constraint_name varchar2(128);
begin 
   v_constraint_name := 'fk_'||p_table||'_'||p_column;
   if not does_constraint_exist(v_constraint_name) then 
      execute_sql('
         alter table '||p_table||'
         add constraint '||v_constraint_name||'
         foreign key ('||p_column||')
         references '||p_parent_table||' ('||p_parent_column||')'||(case when p_cascade then ' on delete cascade' else '' end));
   end if;
end;
/

create or replace function secs_between_timestamps (
   time_start in timestamp, 
   time_end in timestamp) return number is
   total_secs number;
   d interval day(9) to second(6);
begin
   d := time_end - time_start;
   total_secs := abs(extract(second from d) + extract(minute from d)*60 + extract(hour from d)*60*60 + extract(day from d)*24*60*60);
   return round(total_secs, 3);
end;
/

create or replace function mins_between_timestamps (
   time_start in timestamp, 
   time_end in timestamp) return number is
begin
   return round(secs_between_timestamps(time_start, time_end)/60);
end;
/

create or replace function str_count ( -- | Return number of occurrances of a string with another string.
   p_str varchar2, 
   p_char varchar2)
   return number is
   -- Not using regex functions. Don't want to deal with escaping chars like "|".
   /*
   http://www.oracle.com/technology/oramag/code/tips2004/121304.html
   Aui de la Vega, DBA, in Makati, Philippines
   This function provides the number of times a pattern occurs in a string (VARCHAR2).
   */

   c      number;
   next_index   number;
   s       varchar2 (2000);
   p      varchar2 (2000);
begin
   c := 0;
   next_index := 1;
   s := lower (p_str);
   p := lower (p_char);
   for i in 1 .. length (s)
   loop
      if     (length (p) <= length (s) - next_index + 1)
         and (substr (s, next_index, length (p)) = p)
      then
         c := c + 1;
      end if;
      next_index := next_index + 1;
   end loop;
   return c;
end;
/

create or replace function shift_list ( -- | Takes '1,2,3,4' and shifts it to '2,3,4'.
   p_list in varchar2,
   p_token in varchar2 default ',',
   p_shift_count in number default 1,
   p_max_items in number default null) return varchar2 is 
   token_count number;
   v_list varchar2(1000) := trim(p_list);
   v_shift_count number := p_shift_count;
begin 
   if p_list is null or 
      length(trim(p_list)) = 0 then
      return null;
   end if;
   if not p_max_items is null then 
      token_count := str_count(v_list, p_token);
      v_shift_count := (token_count + 1) - p_max_items;
   end if;
   if v_shift_count <= 0 then 
      return trim(v_list);
   end if;
   for i in 1 .. v_shift_count loop 
      token_count := str_count(v_list, p_token);
      if token_count = 0 then 
         return null;
      else 
         v_list := substr(v_list, instr(v_list, p_token)+1);
      end if;
   end loop;
   return trim(v_list);
end;
/

/*

### str_last_n_items (function)

Returns last N items in a delimited list.

* **p_list** - Deliminated list of items.
* **p_items** - The last N items to return.

If p_items is zero null is returned. If p_items in larger than the total number of items all items are returned.

*/

create or replace function str_last_n_items (
   -- Required
   p_list in varchar2,
   p_items in number,
   p_sep in varchar2 default ',')
   return varchar2 is 
   item_count number;
   start_position number;
begin
   if p_items = 0 then
      return null;
   end if;
   item_count := nvl(regexp_count(p_list, p_sep)+1, 0);
   if item_count > p_items then
      start_position := regexp_instr(p_list, '['||p_sep||']+', 1, item_count-p_items);
   else
      start_position := 0;
   end if;
   return trim(substr(p_list, start_position+1));
end;
/

exec drop_function('to_rows');
exec drop_type('csv_tab');
exec drop_type('csv_row');

create or replace type csv_row as object (
   token varchar2(120),
   token_level number);
/

create or replace type csv_tab is table of csv_row;
/

create or replace function to_rows (
   /*
   It works something like this
   select * from table(to_rows('foo, bar, baz'));
   */
   p_list in varchar2,
   p_sep varchar2 default ',') return csv_tab pipelined as
   cursor tokens is
   select replace(trim(regexp_substr(p_list,'[^'||p_sep||']+', 1, level)), ' ', ',') token, level
     from dual connect by regexp_substr(p_list, '[^'||p_sep||']+', 1, level) is not null
    order by level;
begin
   for x in tokens loop
     pipe row(csv_row(x.token, x.level));
   end loop;
   return;
end;
/

create or replace function str_avg_list (
   p_list in varchar2,
   p_sep in varchar2 default ',')
   return number is 
   n number;
begin
   select avg(to_number(token)) into n from table(to_rows(p_list=>p_list, p_sep=>p_sep));
   return n;
end;
/

create or replace function str_max_list (
   p_list in varchar2,
   p_sep in varchar2 default ',') 
   return number is 
   n number;
begin
   select max(to_number(token)) into n from table(to_rows(p_list=>p_list, p_sep=>p_sep));
   return n;
end;
/

create or replace function str_min_list (
   p_list in varchar2,
   p_sep in varchar2 default ',') 
   return number is 
   n number;
begin
   select min(to_number(token)) into n from table(to_rows(p_list=>p_list, p_sep=>p_sep));
   return n;
end;
/

create or replace function str_sum_list (
   p_list in varchar2,
   p_sep in varchar2 default ',')
   return number is 
   n number;
begin
   select sum(to_number(token)) into n from table(to_rows(p_list=>p_list, p_sep=>p_sep));
   return n;
end;
/

create or replace function str_top_n_list(
   p_values in varchar2, 
   p_top_count in number)
   return varchar2 is
   l_top_values varchar2(4000);
begin
   with val_list as (
      select to_number(trim(regexp_substr(p_values, '[^,]+', 1, level))) as value
      from dual
      connect by regexp_substr(p_values, '[^,]+', 1, level) is not null
   )
   select listagg(value, ',') within group (order by value desc)
   into l_top_values
   from (
      select to_number(value) value
      from val_list
      order by value desc
      fetch first p_top_count rows only
   );
   return l_top_values;
end;
/

create or replace function str_eval_math ( 
   p_expression in varchar2,
   p_decimals in number := 2) return number is
   n number;
begin
   -- dbms_aw.eval_text works but may require a license for OLAP or need OLAP installed. Avoid if possible.
   -- dbms_aw.eval_text('5+5/10')
   -- Not sure if below avoids a hard parse which version 1 most likely occurs.
   select
     xmlquery(
     replace(p_expression, '/', ' div ')
        returning content
     ).getNumberVal() into n
     from dual;
   return round(n, p_decimals);
end;
/

create or replace function get_token (
   p_list  varchar2,
   p_index number,
   p_sep varchar2 := ',') return varchar2 is 
   -- Return a single member of a list in the form of 'a,b,c'.
   -- Largely taken from https://glosoli.blogspot.com/2006/07/oracle-plsql-function-to-split-strings.html.
   start_pos number;
   end_pos   number;
begin
   if p_index = 1 then
       start_pos := 1;
   else
       start_pos := instr(p_list, p_sep, 1, p_index - 1);
       if start_pos = 0 then
           return null;
       else
           start_pos := start_pos + length(p_sep);
       end if;
   end if;

   end_pos := instr(p_list, p_sep, start_pos, 1);

   if end_pos = 0 then
       return substr(p_list, start_pos);
   else
       return substr(p_list, start_pos, end_pos - start_pos);
   end if;
exception
   when others then
      raise;
end;
/

exec drop_function('cron_match');
exec drop_function('test_cron_tf');
exec drop_function('test_cron_yn');

create or replace function cron_expression_yn (
   p_expression in varchar2,
   p_timestamp in timestamp default systimestamp) return varchar2 is 
   v_expression varchar2(120) := upper(p_expression);
   v_min varchar2(120);
   v_hr varchar2(120);
   v_dom varchar2(120);
   v_mth varchar2(120);
   v_dow varchar2(120);
   t_min number;
   t_hr number;
   t_dom number;
   t_mth number;
   t_dow number;

   function is_cron_multiple_true (v in varchar2, t in number) return boolean is 
   begin 
      if mod(t, to_number(replace(v, '/', ''))) = 0 then 
         return true;
      end if;
      return false;
   end;

   function is_cron_in_range_true (v in varchar2, t in number) return boolean is 
      left_side number;
      right_side number;
   begin 
      left_side := get_token(p_list=>v, p_index=>1, p_sep=>'-');
      right_side := get_token(p_list=>v, p_index=>2, p_sep=>'-');
      -- Low value to high value.
      if left_side < right_side then 
         if t >= left_side and t <= right_side then 
            return true;
         end if;
      else 
         -- High value to lower value can be used for hours like 23-2 (11PM to 2AM).
         -- Other examples: minutes 55-10, day of month 29-3, month of year 11-1.
         if t >= left_side or t <= right_side then 
            return true;
         end if;
      end if;
      return false;
   end;

   function is_cron_in_list_true (v in varchar2, t in number) return boolean is 
   begin 
      for x in (select trim(regexp_substr(v, '[^,]+', 1, level)) l
                  from dual
                       connect by 
                       level <= regexp_count(v, ',')+1) 
      loop
         if to_number(x.l) = t then 
            return true;
         end if;
      end loop;
      return false;
   end;

   function is_cron_part_true (v in varchar2, t in number) return boolean is 
   begin 
      if trim(v) = 'X' then 
         return true;
      end if;
      if instr(v, '/') > 0 then 
         if is_cron_multiple_true (v, t) then
            return true;
         end if;
      elsif instr(v, '-') > 0 then 
         if is_cron_in_range_true (v, t) then 
            return true;
         end if;
      elsif instr(v, ',') > 0 then 
         if is_cron_in_list_true (v, t) then 
            return true;
         end if;
      else 
         if to_number(v) = t then 
            return true;
         end if;
      end if;
      return false;
   end;

   function is_cron_true (v in varchar2, t in number) return boolean is 
   begin 
      if trim(v) = 'X' then 
         return true;
      end if;
      for x in (select trim(regexp_substr(v, '[^,]+', 1, level)) l
                  from dual
                       connect by 
                       level <= regexp_count(v, ',')+1) 
      loop
         if not is_cron_part_true(x.l, t) then 
            return false;
         end if;
      end loop;
      return true;
   end;

   function convert_dow (v in varchar2) return varchar2 is 
       r varchar2(120);
   begin 
       r := replace(v, 'SUN', 1);
       r := replace(r, 'MON', 2);
       r := replace(r, 'TUE', 3);
       r := replace(r, 'WED', 4);
       r := replace(r, 'THU', 5);
       r := replace(r, 'FRI', 6);
       r := replace(r, 'SAT', 7);
       return r;
   end;

   function convert_mth (v in varchar2) return varchar2 is 
      r varchar2(120);
   begin 
      r := replace(v, 'JAN', 1);
      r := replace(r, 'FEB', 2);
      r := replace(r, 'MAR', 3);
      r := replace(r, 'APR', 4);
      r := replace(r, 'MAY', 5);
      r := replace(r, 'JUN', 6);
      r := replace(r, 'JUL', 7);
      r := replace(r, 'AUG', 8);
      r := replace(r, 'SEP', 9);
      r := replace(r, 'OCT', 10);
      r := replace(r, 'NOV', 11);
      r := replace(r, 'DEC', 12);
      return r;
   end;

begin 
   -- Replace * with X.
   v_expression := replace(v_expression, '*', 'X');

   v_min := get_token(p_list=>v_expression, p_index=>1, p_sep=>' ');
   v_hr := get_token(p_list=>v_expression, p_index=>2, p_sep=>' ');
   v_dom := get_token(p_list=>v_expression, p_index=>3, p_sep=>' ');
   v_mth := convert_mth(get_token(p_list=>v_expression, p_index=>4, p_sep=>' '));
   v_dow := convert_dow(get_token(p_list=>v_expression, p_index=>5, p_sep=>' '));

   t_min := to_number(to_char(p_timestamp, 'MI'));
   t_hr := to_number(to_char(p_timestamp, 'HH24'));
   t_dom := to_number(to_char(p_timestamp, 'DD'));
   t_mth := to_number(to_char(p_timestamp, 'MM'));
   t_dow := to_number(to_char(p_timestamp, 'D'));

   if not is_cron_true(v_min, t_min) then 
      return 'n';
   end if;
   if not is_cron_true(v_hr, t_hr) then 
      return 'n';
   end if;
   if not is_cron_true(v_dom, t_dom) then 
      return 'n';
   end if;
   if not is_cron_true(v_mth, t_mth) then 
      return 'n';
   end if;
   if not is_cron_true(v_dow, t_dow) then 
      return 'n';
   end if;
   return 'y';
end;
/


create or replace function get_db_name 
   return varchar2 is 
   r varchar2(128);
begin
   select max(name) into r from gv$database;
   return r;
end;
/

create or replace procedure cache_num (
   p_key in varchar2, 
   p_num in number) is
begin
   update cache_table set value=to_char(p_num), updated=systimestamp where cache_key=lower(p_key);
   if sql%rowcount = 0 then 
      insert into cache_table (cache_key, value, updated) values (lower(p_key), to_char(p_num), systimestamp);
   end if;
end;
/

create or replace procedure cache_val (
   p_key in varchar2, 
   p_val in varchar2) is
begin
   update cache_table set value=p_val, updated=systimestamp where cache_key=lower(p_key);
   if sql%rowcount = 0 then 
      insert into cache_table (cache_key, value, updated) values (lower(p_key), p_val, systimestamp);
   end if;
end;
/

create or replace function get_cache_num (
   p_key in varchar2,
   p_default in number default null) return number is
   n number;
begin
   select count(*) into n from cache_table where cache_key=lower(p_key);
   if n = 1 then 
      select to_number(value) into n from cache_table where cache_key=lower(p_key);
      return to_number(n);
   else 
      return p_default;
   end if;
end;
/

create or replace function get_cache_val (
   p_key in varchar2,
   p_default in varchar2 default null) return varchar2 is
   n number;
   v cache_table.value%type;
begin
   select count(*) into n from cache_table where cache_key=lower(p_key);
   if n = 1 then 
      select value into v from cache_table where cache_key=lower(p_key);
      return v;
   else 
      return p_default;
   end if;
end;
/

create or replace function get_epoch_from_date ( -- | This function returns the epoch timestamp (number of seconds since 1970-01-01 00:00:00 UTC) corresponding to a given date input.
   p_date in date default sysdate)
   return number is 
begin 
   return round ((p_date-date'1970-01-01') * 86400);
end;
/

create or replace function get_epoch_from_timestamp ( -- | This function returns the epoch time (number of seconds since 1970-01-01 00:00:00 UTC) for a given timestamp.
   p_timestamp in timestamp default systimestamp)
   return number is 
begin 
   return round(secs_between_timestamps(p_timestamp, timestamp'1970-01-01 00:00:00'));
end;
/

create or replace procedure increment_counter (
   p_key in varchar2, p_num in number default 1) is 
begin 
   update counter_table set value=value+p_num, updated=systimestamp where counter_key=lower(p_key);
   if sql%rowcount = 0 then 
      insert into counter_table (counter_key, value, updated) values (lower(p_key), p_num, systimestamp);
   end if;
end;
/

create or replace procedure log_text (
   p_text in varchar2, 
   p_type in varchar2 default 'log',
   p_expires in timestamp default null,
   p_notify in number default 0
   ) is 
   pragma autonomous_transaction;
begin
   insert into log_table (
   log_text,
   log_type,
   log_expires,
   ready_notify) values (
   substr(p_text, 1, 4000),
   lower(p_type),
   p_expires,
   p_notify);
   commit;
exception 
   when others then 
      rollback;
      raise;
end;
/

create or replace procedure debug (
   p_text in varchar2) is 
begin
   log_text(p_text=>p_text, p_type=>'debug', p_expires=>systimestamp - interval '7' day, p_notify=>0);
end;
/

create or replace procedure debug2 (
   p_text in varchar2) is 
begin
   log_text(p_text=>p_text, p_type=>'debug', p_expires=>systimestamp - interval '1' day, p_notify=>0);
end;
/

create or replace procedure log_err (
   p_text in varchar2) is 
begin
   log_text(p_text=>p_text, p_type=>'error', p_expires=>systimestamp - interval '30' day, p_notify=>0);
end;
/

create or replace function to_gb(p_bytes in number) return number is
begin
   return round(p_bytes/1024/1024/1024, 1);
end;
/

create or replace function str_is_number_y_or_n (text varchar2) return varchar2 is
   -- Return true if the provided string evalutes to a number.
   x number;
begin
   x := to_number(text);
   return 'Y';
exception
   when others then
      return 'N';
end;
/

create or replace function to_jde_date (
   p_date in date default sysdate) return varchar2 is 
   x varchar2(16);
begin
   select to_char(substr(to_char(p_date, 'YYYY'), 1, 2)-19) into x from dual;
   select x||to_char(p_date, 'rrddd') into x from dual;
   return x;
end;
/

create or replace function from_jde_date (
   p_jde_date in varchar2) return date is 
   x varchar2(16);
   y varchar2(16);
begin
   if length(p_jde_date) = 5 then 
      return to_date(p_jde_date, 'RRDDD');
   else 
      return to_date(substr(p_jde_date, 2, 5), 'RRDDD');
   end if;
end;
/

create or replace function get_file_name(p_file_path in varchar2) return varchar2
is
  v_file_name varchar2(255);
begin
  v_file_name := substr(p_file_path, instr(p_file_path, '/', -1) + 1);
  return v_file_name;
end;
/

create or replace procedure update_stats (
    p_table in varchar2,
    p_owner in varchar2 default user) is 
begin
    dbms_stats.gather_table_stats (
       ownname=>p_owner,
       tabname=>upper(p_table),
       estimate_percent=>dbms_stats.auto_sample_size,
       method_opt=>'FOR ALL COLUMNS SIZE AUTO',
       cascade=>true);
end;
/

create or replace procedure dump_table (
   p_table in varchar2,
   p_owner in varchar2 default user) is 
   h number;
   file_name varchar2(256) := lower(p_table)||'_'||to_char(systimestamp, 'YYYYMMDD_HH24MISS')||'.dmp';
   log_file varchar2(256) := lower(p_table)||'_'||to_char(systimestamp, 'YYYYMMDD_HH24MISS')||'.log';
begin
   h := dbms_datapump.open(
      operation   => 'EXPORT',
      job_mode    => 'TABLE',
      remote_link => NULL,
      job_name    => lower(p_table)||'_export',
      version     => 'LATEST');

   dbms_datapump.add_file(
      handle    => h,
      filename  => file_name,
      directory => app_config.get_param_str('dump_table_dir'));

   dbms_datapump.add_file(
      handle    => h,
      filename  => log_file,
      directory => app_config.get_param_str('dump_table_dir'),
      filetype  => DBMS_DATAPUMP.KU$_FILE_TYPE_LOG_FILE);    

   dbms_datapump.metadata_filter(
      handle => h,
      name   => 'SCHEMA_EXPR',
      value  => '= '''||upper(p_owner)||'''');

   dbms_datapump.metadata_filter(
      handle => h,
      name   => 'NAME_EXPR',
      value  => '= '''||upper(p_table)||'''');

  dbms_datapump.start_job(h);
  dbms_datapump.detach(h);
end;
/

create or replace procedure set_last_time (
   p_name in varchar2) is 
begin 
   app_config.set_param_str(
      p_name=>'last_time_'||p_name,
      p_str=>to_char(sysdate, 'YYYYMMDDHH24MISS'));
end;
/

create or replace function get_last_time (
   p_name in varchar2) return date is 
   date_str varchar2(32);
begin 
   date_str := nvl(app_config.get_param_str(p_name=>'last_time_'||p_name), to_char(sysdate, 'YYYYMMDDHH24MISS'));
   return to_date(date_str, 'YYYYMMDDHH24MISS');
end;
/

create or replace procedure start_timer (
   p_name in varchar2) is 
begin
   app_config.add_param_str(p_name=>'_timer_'||p_name, p_str=>to_char(sysdate, 'YYYYMMDDHH24MISS'));
   app_config.set_param_str(p_name=>'_timer_'||p_name, p_str=>to_char(sysdate, 'YYYYMMDDHH24MISS'));
end;
/

create or replace function get_timer_min (
   p_name in varchar2) return number is 
   date_str varchar2(32);
begin 
   date_str := nvl(app_config.get_param_str(p_name=>'_timer_'||p_name), to_char(sysdate, 'YYYYMMDDHH24MISS'));
   return round((sysdate-to_date(date_str, 'YYYYMMDDHH24MISS'))*24*60, 1);
end;
/

create or replace function is_enterprise_edition return boolean is 
   n number;
begin
   select count(*) into n from v$version 
    where lower(banner) like '%enterprise%'
       or banner like '%EE%';
   return n>0;
end;
/

create or replace type sql_to_csv as table of varchar2(4000);
/

create or replace function sql_to_csv_pipe (
   p_sql     in varchar2,
   p_sep in varchar2 default ',') return sql_to_csv is
   v_cur     integer default dbms_sql.open_cursor;
   v_colval  varchar2(2000);
   v_status  integer;
   v_colcnt  number default 0;
   v_sep     varchar2(10) default '';
   l_cnt     number default 0;
   v_str     varchar2(2000) default '';
   v_result  sql_to_csv := sql_to_csv();
begin
   dbms_sql.parse(v_cur, p_sql, dbms_sql.native);
   for i in 1 .. 255 loop
      begin
         dbms_sql.define_column(v_cur, i, v_colval, 2000);
         v_colcnt := i;
      exception
         when others then
            if (sqlcode = -1007) then
               exit;
            else
               raise;
            end if;
      end;
   end loop;
   dbms_sql.define_column(v_cur, 1, v_colval, 2000);
   v_status := dbms_sql.execute(v_cur);
   loop
      exit when (dbms_sql.fetch_rows(v_cur) <= 0);
      v_sep := '';
      for i in 1 .. v_colcnt loop
         dbms_sql.column_value(v_cur, i, v_colval);
         v_str := v_str || v_sep || v_colval;
         v_sep := p_sep;
      end loop;
      v_result.extend;
      v_result(v_result.count) := v_str;
      v_str := '';
      l_cnt := l_cnt + 1;
   end loop;
   dbms_sql.close_cursor(v_cur);
   return v_result;
exception
   when others then
      dbms_output.put_line(dbms_utility.format_error_stack);
      debug('sql_to_csv_pipe: ' || dbms_utility.format_error_stack);
      return v_result;
end;
/

create or replace function sql_to_csv_clob (
   p_sql     in varchar2,
   p_sep in varchar2 default ',') return clob is
   v_cur     integer default dbms_sql.open_cursor;
   v_colval  varchar2(2000);
   v_status  integer;
   v_colcnt  number default 0;
   v_sep     varchar2(10) default '';
   l_cnt     number default 0;
   v_str     varchar2(2000) default '';
   v_result  clob;
begin
   dbms_sql.parse(v_cur, p_sql, dbms_sql.native);
   for i in 1 .. 255 loop
      begin
         dbms_sql.define_column(v_cur, i, v_colval, 2000);
         v_colcnt := i;
      exception
         when others then
            if (sqlcode = -1007) then
               exit;
            else
               raise;
            end if;
      end;
   end loop;
   dbms_sql.define_column(v_cur, 1, v_colval, 2000);
   v_status := dbms_sql.execute(v_cur);
   loop
      exit when (dbms_sql.fetch_rows(v_cur) <= 0);
      v_sep := '';
      for i in 1 .. v_colcnt loop
         dbms_sql.column_value(v_cur, i, v_colval);
         v_str := v_str || v_sep || v_colval;
         v_sep := p_sep;
      end loop;
      v_result := v_result || v_str;
      v_str := '';
      l_cnt := l_cnt + 1;
   end loop;
   dbms_sql.close_cursor(v_cur);
   return v_result;
exception
   when others then
      dbms_output.put_line(dbms_utility.format_error_stack);
      debug('sql_to_csv_clob: ' || dbms_utility.format_error_stack);
      return v_result;
end;
/


create or replace function base64decode(p_clob clob) return blob
-- -----------------------------------------------------------------------------------
-- File Name    : https://oracle-base.com/dba/miscellaneous/base64decode.sql
-- Author       : Tim Hall
-- Description  : Decodes a Base64 CLOB into a BLOB
-- Last Modified: 09/11/2011
-- -----------------------------------------------------------------------------------
is
  l_blob    blob;
  l_raw     raw(32767);
  l_amt     number := 7700;
  l_offset  number := 1;
  l_temp    varchar2(32767);
begin
  begin
    dbms_lob.createtemporary (l_blob, false, dbms_lob.call);
    loop
      dbms_lob.read(p_clob, l_amt, l_offset, l_temp);
      l_offset := l_offset + l_amt;
      l_raw    := utl_encode.base64_decode(utl_raw.cast_to_raw(l_temp));
      dbms_lob.append (l_blob, to_blob(l_raw));
    end loop;
  exception
    when no_data_found then
      null;
  end;
  return l_blob;
end;
/

-- select * from table(sql_to_csv_pipe('select sql_id, elapsed_seconds from sql_log where datetime > sysdate-2/24'));

create or replace function str_random (
   -- This function generates a random string of specified length and type, which can be alphabetic (a), numeric (n), or alphanumeric (an).
   length in number default 33, 
   string_type in varchar2 default 'an') return varchar2 is
   r varchar2(4000);
   x number := 0;
begin
   x := least(str_random.length, 4000);
   case lower(string_type)
      when 'a' then
         r := dbms_random.string('a', x);
      when 'n' then
         while x > 0 loop
            x := x - 1;
            r := r || to_char(round(dbms_random.value(0, 9)));
         end loop;
      when 'an' then
         r := dbms_random.string('x', x);
   end case;
   return r;
end;
/

create or replace function extract_text (
   -- This function extracts text between two patterns.
   -- Example: select extract_text('foo bar baz', 'foo', 'baz') from dual;
   p_text in clob,
   p_start_pattern in varchar2,
   p_end_pattern in varchar2) return varchar2 is
   v_start_index integer;
   v_end_index integer;
begin
   v_start_index := instr(p_text, p_start_pattern);
   v_end_index := instr(p_text, p_end_pattern, v_start_index + length(p_start_pattern));
   if v_start_index = 0 or v_end_index = 0 then
      return '';
   else
      return substr(p_text, v_start_index + length(p_start_pattern), v_end_index - v_start_index - length(p_start_pattern));
   end if;
end;
/