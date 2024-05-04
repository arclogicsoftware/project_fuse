
delete from fuse_tool;
delete from fuse_session;

create or replace procedure list_all_db_users as 
begin
   fuse.x := convert_to_csv_row('select username from dba_users');
end;
/

begin
   fuse.add_tool(
      p_tool_group=>'oracle_functions',
      p_function_name=>'list_all_db_users',
      p_function_desc=>'Returns a comma delimited list of all database user accounts.');
end;
/

create or replace procedure get_row_count_from_table (p_table_name in varchar2) is 
begin
   execute immediate 'select count(*) from '||p_table_name into fuse.x;
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

create or replace procedure lock_user_account (p_user_name in varchar2) is 
begin 
   execute immediate 'alter user :x account lock' using p_user_name;
end;
/

begin
   fuse.add_tool(
      p_tool_group=>'oracle_functions',
      p_function_name=>'lock_user_account',
      p_function_desc=>'Locks the account of the specified user.',
      p_parm1=>'p_user_name',
      p_parm1_type=>'string',
      p_parm1_desc=>'The name of the user account to lock.');
end;
/

/*
select * from fuse_tool;
*/

delete from log_table;
delete from json_data;
exec fuse.init;
exec fuse.randomness := 0;
exec fuse.create_session(p_session_name=>'oracle_agent', p_model_name=>fuse_config.default_model_name);
exec fuse.system('You are a function calling LLM that uses the data extracted from a function to answer questions and perform actions.');
exec fuse.user('How many rows are in the SQL_LOG table?', p_tool_group=>'oracle_functions');
-- Halucinates here
exec fuse.user('Are there any accounts you think should be locked?');

/*
select * from log_table order by 1 desc;
select * from json_data order by 1 desc;
select * from session_prompt order by 1 desc;
*/

exec drop_procedure('list_all_db_users');
exec drop_procedure('get_row_count_from_table');
