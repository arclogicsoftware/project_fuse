
/*
This script demonstrates a method for generating content and capturing the output to a table. **This is a work in progress**.
*/

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

exec drop_table('topic_headings');
create table topic_headings (
      topic_heading_id number generated always as identity,
      heading_name varchar2(1024));
insert into topic_headings (heading_name) (select item_name from item_stage);
delete from item_stage;
commit;

declare 
   cursor headings is select * from topic_headings;
begin
   fuse.init;
   fuse.create_session (
      p_session_name=>'item_stage',
      p_model_name=>'gpt-3.5-turbo-0125');
   fuse.system('I am going to give you a topic and you are going to return 10 things you would teach in a class about the topic. You will return the list as a series of PL/SQL procedure calls to the add_item procedure which takes one parameter within an anonymous PL/SQL block, the item name.');
   for h in headings loop
      fuse.user(
         p_prompt=>h.heading_name, 
         -- This prompt and its response won't be included in future conversation history, minimizing data and size.
         p_exclude=>true);
      execute immediate fuse.response;
      exit;
   end loop;
end;
/

select * from item_stage;

drop procedure add_item;