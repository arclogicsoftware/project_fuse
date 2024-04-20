


## Fuse

Fuse is primarily a AI API focused project but I have included it within the latest version of Oracle monitoring, development, and automation tooling that I use, so there is a lot more here than just eh "fuse" AI API package. Most of the development will be focused on "fuse" package but I will be sharing details on how to use the other capabilities as well.

This project supercedes any work I have done on "K2" and if I get back to more APEX development I will likely migrate some of the things I used/learned from "K2" to "Fuse".

## Install

1. Create a user.
2. Run the ./sh/app_grant.sql script as an admin to grant your user the required priviledges.
   * Make sure you modify the user name at the top of the script.
   * Expect a lot of errors. This script trys to grant privs in a number of different ways to support the most environment types possible.
3. Log on as the new user.
4. Run ./app_install.sql

Note:
   * This will create a bunch of scheduled jobs. Most of these should only be running once within a DB. If you install in multiple accounts you will get a lot of redundant jobs so they should be removed or disabled. I will fix this eventually.
