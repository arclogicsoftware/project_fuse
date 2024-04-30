begin 
   drop_table('item_stage');
   execute immediate 'create table item_stage (item_name varchar2(1024))';
end;
/

create or replace procedure add_item (p_item_name in varchar2) is 
begin
   insert into item_stage (item_name) values (p_item_name);
end;
/

begin
   fuse.init;
   fuse.create_session (
      p_session_name=>'item_stage',
      p_model_name=>'gpt-3.5-turbo-0125');
   fuse.system('I am going to give you a topic and you are going to return 10 things you would teach in a class about the topic. You will return the list as a series of PL/SQL procedure calls to the add_item procedure which takes one parameter within an anonymous PL/SQL block, the item name.');
   fuse.randomness := .2;
   fuse.user('Oracle Database Managment');
end;
/

exec dbms_output.put_line(extract_text(fuse.response, '```sql', '```'));

begin
   execute immediate extract_text(fuse.response, '```sql', '```');
end;
/

select * from item_stage;

commit;

drop procedure add_item;