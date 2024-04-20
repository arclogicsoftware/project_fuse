## Fuse

Fuse is primarily an Oracle PL/SQL AI API focused project. However, I have integrated the latest version of Oracle monitoring, development, and automation tooling that I use. While most of the development will revolve around AI, I will also provide details and improvements to the other tools in this project.

This project supersedes any previous work I have undertaken on "K2". If/when I return to APEX development, I may migrate some of the techniques and knowledge gained from "K2" to "Fuse".

## Install

1. Create a user.
2. Run the ./sh/app_grant.sql script as an admin to grant your user the required priviledges.
   * Make sure you modify the user name at the top of the script.
   * Expect a lot of errors. This script trys to grant privs in a number of different ways to support the most environment types possible.
3. Log on as the new user.
4. Rename or copy ./fuse/fuse_config.sql to ./fuse/fuse_config.secret and put your secret API tokens in it.
5. Run ./app_install.sql

Note:
   * This will create a bunch of scheduled jobs. Most of these should only be running once within a DB. If you install in multiple accounts you will get a lot of redundant jobs so they should be removed or disabled. I will fix this eventually.
