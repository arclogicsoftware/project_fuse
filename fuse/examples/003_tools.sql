


select * from fuse_tool;

delete from log_table;
delete from json_data;
delete from fuse_session;

exec fuse.init;
exec fuse.create_session(p_session_name=>'oracle_tools', p_model_name=>fuse_config.default_model_name, p_tool_group=>'oracle_tools');
exec fuse.system('You are a function calling LLM that uses the data extracted from a function to answer questions and perform actions.');
exec fuse.user('How many rows are in the SQL_LOG table?');
exec fuse.user('Which user accounts begin with the letter E?');
exec fuse.user('Is there an account called TEST?');
exec fuse.user('Lock the account called TEST');

create or replace procedure lock_user_account (p_user_name in varchar2) is 
begin 
   debug('lock_user_account: '||p_user_name);
   execute immediate 'alter user '||p_user_name||' account lock';
end;
/

-- Halucinates here
exec fuse.user('Are there any accounts you think should be locked?');

select * from log_table order by 1 desc;
select * from json_data order by 1 desc;
select * from session_prompt order by 1 desc;

select * from dba_users order by created desc;
alter user test account unlock;

exec lock_user_account('TEST');


exec drop_procedure('list_all_db_users');
exec drop_procedure('get_row_count_from_table');
