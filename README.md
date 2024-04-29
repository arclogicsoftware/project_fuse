**Warning: This project is in development and I will do things like rebuild/rename objects, delete data, and so on.**

## Fuse

Fuse is an Oracle PL/SQL API that supports multiple AI provider/models. Fuse makes it easy to add robust AI functionality to your databases.

```sql
begin
   fuse.create_session(
      p_session_name=>'xyz', 
      p_model_name=>'codellama/CodeLlama-7b-Instruct-hf');
   fuse.system('
      You are an Oracle ACE and noted expert instructor.');
   fuse.user('
      Help me create a lesson plan for the next four weeks. 
      I’m teaching high school graduates about Oracle RDMS.');
end;
/
```

This project also includes utilities which support development, monitoring, alerting, and automation.

If you want to follow along, please subscribe to my [YouTube](https://www.youtube.com/channel/UC8cIGO-lRvWM-mPtJdO_9XQ) channel.

## Installation

1. Create a user or select an existing user account.
2. Run the ./sh/app_grant.sql script as an admin to grant the user the required priviledges.
   * Make sure you modify the user name at the top of the script.
   * Expect a lot of errors. This script grants privs in a number of ways to support as environments like RDS and Oracle Cloud.
3. Log on as the user.
4. Rename or copy ./fuse/fuse_config.sql to ./fuse/fuse_config.secret and put your secret API tokens in it.
5. Run ./app_install.sql
6. The ./fuse folder will contain one or more test files which you can use as examples.

**Note**:
   * I create a number of scheduled jobs. Some of these only need to run once within a database across all schemas. If you install in multiple accounts you will get a redundant jobs so they should be removed or disabled. I will fix this eventually.

## Supported Providers

1. [OpenAI](https://platform.openai.com/docs/introduction)
2. [Together](https://docs.together.ai/docs/quickstart)
3. [Anthropic](https://docs.anthropic.com/claude/reference/getting-started-with-the-api)



