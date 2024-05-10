
/*
This script demonstrates a method for generating content and capturing the output to a table. **This is a work in progress**.
*/

begin 
   drop_table('data_stage');
   execute immediate 'create table data_stage (item_id number generated always as identity, item_data varchar2(1024), item_prompt varchar2(1024))';
end;
/

create or replace procedure add_data (p_item_data in varchar2) is 
begin
   insert into data_stage (item_data) values (p_item_data);
end;
/

desc add_data;

begin
   fuse.init;
   fuse.create_session (
      p_session_name=>'data_generator',
      p_model_name=>fuse_config.default_model_name);
   fuse.system('You are a classical historic Cambridge scholar from the 1920s. I am going to give you a topic and you are going to return 10 things you would teach in a class about the topic. You will return the list as a series of PL/SQL procedure calls to the add_data procedure which takes one parameter within an anonymous PL/SQL block, the item name.');
   fuse.randomness := .1;
   delete from data_stage;
   fuse.user('The Iliad');
end;
/

exec dbms_output.put_line(extract_text(fuse.response, '```', '```'));

begin
   execute immediate extract_text(fuse.response, '```', '```');
end;
/

select * from data_stage;

commit;

exec drop_table('topic_headings');
create table topic_headings (
      topic_heading_id number generated always as identity,
      heading_name varchar2(1024));
insert into topic_headings (heading_name) (select item_data from data_stage);
delete from data_stage;
commit;

declare 
   cursor headings is select * from topic_headings;
begin
   fuse.init;
   fuse.create_session (
      p_session_name=>'data_stage',
      p_model_name=>'gpt-3.5-turbo-0125');
   fuse.system('I am going to give you a topic and you are going to return 10 things you would teach in a class about the topic. You will return the list as a series of PL/SQL procedure calls to the add_data procedure which takes one parameter within an anonymous PL/SQL block, the item name.');
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

select * from data_stage;

drop procedure add_data;