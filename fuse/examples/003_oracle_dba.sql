


exec drop_procedure('list_all_db_users');

create or replace procedure list_all_db_users as 
begin
   fuse.x := convert_to_csv_row('select username from dba_users');
end;
/

exec drop_procedure('lock_user_account');

exec drop_procedure('get_row_count_from_table');
create or replace procedure get_row_count_from_table (p_table_name in varchar2) is 
begin
   execute immediate 'select count(*) from '||p_table_name into fuse.x;
end;
/

-- create or replace procedure lock_user_account (p_user_name in varchar2) is 
-- begin 
--    execute immediate 'alter user :x account lock' using p_user_name;
-- end;
-- /


delete from fuse_tool;

begin
   fuse.add_tool(
      p_tool_group=>'oracle_functions',
      p_function_name=>'list_all_db_users',
      p_function_desc=>'Returns a comma delimited list of all database user accounts.');
end;
/

begin
   fuse.add_tool(
      p_tool_group=>'oracle_functions',
      p_function_name=>'get_row_count_from_table',
      p_function_desc=>'Return the number of rows from the specified table or view.',
      p_parm1=>'p_table_name',
      p_parm1_type=>'string',
      p_parm1_desc=>'The name of the table or view.');
end;
/


select * from fuse_tool;

delete from log_table;
delete from json_data;

exec fuse.init;
exec fuse.randomness := 0;
exec fuse.create_session(p_session_name=>'oracle_agent', p_model_name=>fuse_config.default_model_name);
exec fuse.system('You are a function calling LLM that uses the data extracted from a function to answer questions and perform actions.');
exec fuse.user('How many rows are in the SQL_LOG table?', p_tool_group=>'oracle_functions');

select * from log_table order by 1 desc;
select * from json_data order by 1 desc;

declare 
   r clob;
   n number;
begin
   -- Assume the user asks this question.
   r := 'Does user WORK1 exist?';
   fuse.user('Evaluate this statement. ```'||r||'``` Is the user asking me to determine if a user exists? Simply answer yes or no.');
   if instr(lower(fuse.response), 'yes') > 0 then 
      fuse.user('What is the name of the user? Simply answer with the username.');
      select count(*) from dba_users where lower(username) = lower(fuse.response);
      if n > 0 then 
         fuse.assistant('Yes the user exists.');
      end if;
      execute immediate 'alter user '||fuse.response||' account lock';
   end if;
end;
/

select * from dba_users where username='WORK1';
alter user WORK1 account unlock;
