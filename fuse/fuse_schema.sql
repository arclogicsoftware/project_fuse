
-- Patch
exec drop_table('request_queue');

exec drop_table('api_response');
begin
   if not does_table_exist('api_response') then 
      execute immediate '
      create table api_response (
      api_response_id number generated by default on null as identity cache 20 noorder nocycle nokeep noscale not null,
      response clob not null,
      created timestamp default systimestamp)';
   end if;
   add_primary_key('api_response', 'api_response_id');
end;
/

comment on table api_response is 'Each row contains the raw response of an external API call.';

exec drop_table('fuse_provider');
begin
   if not does_table_exist('fuse_provider') then 
      execute immediate '
      create table fuse_provider (
      provider_id number generated by default on null as identity cache 20 noorder nocycle nokeep noscale not null,
      provider_name varchar2(512) not null,
      created timestamp default systimestamp)';
   end if;
   add_primary_key('fuse_provider', 'provider_id');
   if not does_index_exist('fuse_provider_01') then
      execute immediate 'create unique index fuse_provider_01 on fuse_provider(provider_name)';
   end if;
end;
/

comment on table fuse_provider is 'Each row contains the name of a provider.';

begin
   insert into fuse_provider (provider_name) values ('together');
   insert into fuse_provider (provider_name) values ('anthropic');
   insert into fuse_provider (provider_name) values ('openai');
   insert into fuse_provider (provider_name) values ('groq');
end;
/

exec drop_table('provider_model');
begin
   if not does_table_exist('provider_model') then 
      execute immediate '
      create table provider_model (
      model_id number generated by default on null as identity cache 20 noorder nocycle nokeep noscale not null,
      model_name varchar2(512) not null,
      -- chat, lang, code, image
      model_type varchar2(32) not null,
      api_url varchar2(512) default null,
      -- Will only be used to store the api_key in g_model memory.
      api_key varchar2(512) default null,
      provider_id number not null,
      context_length number not null,
      json_mode varchar2(1) default ''N'')';
   end if;
   add_primary_key('provider_model', 'model_id');
   if not does_constraint_exist('fk_provider_model_provider_id') then
      execute immediate 'alter table provider_model add constraint fk_provider_model_provider foreign key (provider_id) references fuse_provider(provider_id)';
   end if;
   if not does_index_exist('provider_model_01') then
      execute immediate 'create unique index provider_model_01 on provider_model(model_name)';
   end if;
end;
/

comment on table provider_model is 'Each row contains a model that is supported by the specified provider_id.';

create or replace procedure add_model (
   p_model_name in varchar2,
   p_model_type in varchar2,
   p_api_url in varchar2,
   p_provider_name in varchar2,
   p_context_length in number) is
begin
   insert into provider_model (
      model_name,
      model_type,
      api_url,
      provider_id,
      context_length) values (
      p_model_name,
      p_model_type,
      p_api_url,
      (select provider_id from fuse_provider where provider_name=p_provider_name),
      p_context_length);
end;
/

declare
   v_provider fuse_provider.provider_name%type := 'together';
   v_api_url provider_model.api_url%type := 'https://api.together.xyz/v1/chat/completions';
begin
   add_model('codellama/CodeLlama-7b-Instruct-hf', 'chat', v_api_url, v_provider, 16384);
   add_model('codellama/CodeLlama-13b-Instruct-hf', 'chat', v_api_url, v_provider, 16384);
   add_model('codellama/CodeLlama-34b-Instruct-hf', 'chat', v_api_url, v_provider, 16384);
   add_model('codellama/CodeLlama-70b-Instruct-hf', 'chat', v_api_url, v_provider, 4096);
   add_model('mistralai/Mistral-7B-Instruct-v0.2', 'chat', v_api_url, v_provider, 32768);
   add_model('google/gemma-7b-it', 'chat', v_api_url, v_provider, 8192);
   add_model('databricks/dbrx-instruct', 'chat', v_api_url, v_provider, 32768);
-- These models support function calling and json_mode.
   add_model('togethercomputer/CodeLlama-34b-Instruct', 'chat', v_api_url, v_provider, 16384);
   add_model('mistralai/Mistral-7B-Instruct-v0.1', 'chat', v_api_url, v_provider, 8192);
   add_model('mistralai/Mixtral-8x7B-Instruct-v0.1', 'chat', v_api_url, v_provider, 0);
   -- Some confusion on which endpoint to use for images.
   -- The example here for images uses the inferance end point (https://docs.together.ai/docs/examples#image-generation).
   -- add_model('stabilityai/stable-diffusion-2-1', 'image', 'https://api.together.xyz/inference', v_provider, 0);
   -- The docs here for images say to use the completions end point (https://docs.together.ai/docs/inference-models).
   -- I have tested both and they both work without any modification to Fuse code.
   add_model('stabilityai/stable-diffusion-2-1', 'image', 'https://api.together.xyz/v1/completions', v_provider, 0);
end;
/

declare
   v_provider fuse_provider.provider_name%type := 'anthropic';
   v_api_url provider_model.api_url%type := 'https://api.anthropic.com/v1/messages';
begin
   add_model('claude-3-opus-20240229', 'chat', v_api_url, v_provider, 200000);
   add_model('claude-3-sonnet-20240229', 'chat', v_api_url, v_provider, 200000);
   add_model('claude-3-haiku-20240307', 'chat', v_api_url, v_provider, 200000);
end;
/

declare
   v_provider fuse_provider.provider_name%type := 'openai';
   v_api_url provider_model.api_url%type := 'https://api.openai.com/v1/chat/completions';
begin
   add_model('gpt-3.5-turbo-0125', 'chat', v_api_url, v_provider, 16385);
end;
/

declare
   v_provider fuse_provider.provider_name%type := 'groq';
   v_api_url provider_model.api_url%type := 'https://api.groq.com/openai/v1/chat/completions';
begin
   add_model('llama3-8b-8192', 'chat', v_api_url, v_provider, 8192);
   add_model('llama3-70b-8192', 'chat', v_api_url, v_provider, 8192);
   add_model('mixtral-8x7b-32768', 'chat', v_api_url, v_provider, 32768);
   add_model('gemma-7b-it', 'chat', v_api_url, v_provider, 8192);
end;
/

-- As of Apr 2024 together supports JSON mode for the following models.
update provider_model set json_mode='Y'
 where model_name in (
   'mistralai/Mixtral-8x7B-Instruct-v0.1', 
   'mistralai/Mistral-7B-Instruct-v0.1', 
   'togethercomputer/CodeLlama-34b-Instruct');

exec drop_table('fuse_session');
begin
   if not does_table_exist('fuse_session') then 
      execute immediate '
      create table fuse_session (
      session_id number generated by default on null as identity cache 20 noorder nocycle nokeep noscale not null,
      session_name varchar2(512) not null,
      user_name varchar2(128) default null,
      session_title varchar2(512) default null,
      model_id number default null,
      tool_group_id number default null,
      pause number default 0,
      total_tokens number default 0 not null,
      elapsed_seconds number default 0,
      call_count number default 0,
      status varchar2(32) default ''active'',
      created timestamp default systimestamp)';
   end if;
   add_primary_key('fuse_session', 'session_id');
   if not does_index_exist('fuse_session_01') then
      execute immediate 'create index fuse_session_01 on fuse_session(session_name)';
   end if;
   if not does_constraint_exist('fk_fuse_session_model_id') then
      execute immediate 'alter table fuse_session add constraint fk_fuse_session_model foreign key (model_id) references provider_model(model_id)';
   end if;
   if not does_constraint_exist('fk_fuse_session_tool_group_id') then
      execute immediate 'alter table fuse_session add constraint fk_fuse_session_tool_group foreign key (tool_group_id) references tool_group(tool_group_id) on delete cascade';
   end if;
end;
/

comment on table fuse_session is 'Each row represents a Fuse session that is associated with a specific model.';

exec drop_table('session_prompt');
begin
   if not does_table_exist('session_prompt') then 
      execute immediate '
      create table session_prompt (
      session_prompt_id number generated by default on null as identity cache 20 noorder nocycle nokeep noscale not null,
      session_id number not null,
      start_time timestamp default systimestamp,
      end_time timestamp default null,
      elapsed_seconds number default 0,
      finish_reason varchar2(32) default ''n/a'',
      total_tokens number default 0 not null,
      prompt_role varchar2(32) not null,
      randomness number default null,
      max_tokens number default null,
      prompt clob not null,
      schema clob default null,
      tool_call_id varchar2(64) default null,
      function_name varchar2(128) default null,
      parm1 varchar2(512) default null,
      parm2 varchar2(512) default null,
      -- When 1 will not be included in prompt reconstruction.
      exclude number default 0,
      created timestamp default systimestamp)';
   end if;
   add_primary_key('session_prompt', 'session_prompt_id');
   add_foreign_key('session_prompt', 'session_id', 'fuse_session', 'session_id', true);
end;
/

comment on table session_prompt is 'Each row represents a prompt that is associated with a specific session.';

exec drop_table('session_image');
begin
   if not does_table_exist('session_image') then 
      execute immediate '
      create table session_image (
      session_image_id number generated by default on null as identity cache 20 noorder nocycle nokeep noscale not null,
      session_id number not null,
      prompt clob not null,
      -- Number of images to return if image model.
      images number default null,
      -- Number of image steps if image model.
      steps number default null,
      seed number default null,
      image_id number not null,
      image_data blob not null,
      created timestamp default systimestamp)';
   end if;
   add_primary_key('session_image', 'session_image_id');
   add_foreign_key('session_image', 'session_id', 'fuse_session', 'session_id', true);
end;
/

comment on table session_image is 'Each row represents an image prompt that is associated with a specific session.';


exec drop_table('tool_group');
begin
   if not does_table_exist('tool_group') then 
      execute immediate '
      create table tool_group (
      tool_group_id number generated by default on null as identity cache 20 noorder nocycle nokeep noscale not null,
      tool_group_name varchar2(512) not null,
      description varchar2(512) default null,
      created timestamp default systimestamp)';
   end if;
   add_primary_key('tool_group', 'tool_group_id');
   if not does_index_exist('tool_group_01') then
      execute immediate 'create unique index tool_group_01 on tool_group(tool_group_name)';
   end if;
end;
/

comment on table tool_group is 'Each row represents a group of tools.';

exec drop_table('fuse_tool');
begin
   if not does_table_exist('fuse_tool') then 
      execute immediate '
      create table fuse_tool (
      tool_id number generated by default on null as identity cache 20 noorder nocycle nokeep noscale not null,
      tool_group_id number not null,
      function_name varchar2(512) not null,
      function_desc varchar2(512) not null,
      parm1 varchar2(512) default null,
      parm1_type varchar2(32) default null,
      parm1_desc varchar2(512) default null,
      parm1_req number default 0,
      parm2 varchar2(512) default null,
      parm2_type varchar2(32) default null,
      parm2_desc varchar2(512) default null,
      parm2_req number default 0,
      created timestamp default systimestamp)';
   end if;
   add_primary_key('fuse_tool', 'tool_id');
   if not does_index_exist('fuse_tool_01') then
      execute immediate 'create unique index fuse_tool_01 on fuse_tool(function_name)';
   end if;
   if not does_constraint_exist('fk_fuse_tool_tool_group_id') then
      execute immediate 'alter table fuse_tool add constraint fk_fuse_tool_tool_group foreign key (tool_group_id) references tool_group(tool_group_id) on delete cascade';
   end if;
end;
/

comment on table fuse_tool is 'Each row represents a tool (function) which can be used if a model supports tools.';
