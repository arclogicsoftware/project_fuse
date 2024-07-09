# Fuse Documentation

If you got this far, you have successfully installed Fuse and are ready to see what you can do with it.

## Alerting

> **Alerts should be easy to create, customize, manage, and distribute. Alerts should be intelligent/adaptable.**

Fuse is delivered with a number of existing alerts. Most of which can be found in the `alerts` folder. 

Alerts are created by adding a row to the `ALERT_TABLE` using one of the methods described below.

### Basic Alert View

A basic alert view returns 0-1 rows. Views must begin with the name `ALERT__` (note the double underscore). An alert is open when a row is returned. Alerts are automatically closed when the view stops returning rows. Views are typically polled every 5 minutes.

#### Example 1

This view opens an alert when the session count exceeds 1000. When the view contains a column called `VALUE`, the value returned will be stored in the `ALERT_TABLE.ALERT_INFO` column. Using `VALUE` as a column name is optional.

```sql
CREATE OR REPLACE VIEW alert__too_many_sessions AS 
SELECT COUNT(*) value 
FROM v$session
WHERE type != 'BACKGROUND'
HAVING COUNT(*) > 1000;
```

#### Example 2

The value returned in the `VALUE` column can also be a string, as shown in this example.

```sql
CREATE OR REPLACE VIEW alert__too_many_sessions AS 
SELECT 'session_count=' || COUNT(*) value 
FROM v$session
WHERE type != 'BACKGROUND'
HAVING COUNT(*) > 1000;
```

#### Example 3

This example demonstrates that the `VALUE` column is optional. We use `X` in this example.

```sql
CREATE OR REPLACE VIEW alert__too_many_sessions AS 
SELECT 'Too Many Sessions' x 
FROM v$session 
WHERE type != 'BACKGROUND'
HAVING COUNT(*) > 1000;
```

### Advanced Alert View

This example is taken from the actual Blocked Sessions delivered alert. We can also see in this example how to generate a modifiable parameter in the `CONFIG_TABLE` and reference it in our view.

Advanced views require the following columns: `ALERT_LEVEL`, `ALERT_TYPE`, `ALERT_NAME`, `ALERT_INFO`, `NOTIFY_INTERVAL`, and `ALERT_DELAY`.

Advanced views can return more than one row as long as each row provides a unique `ALERT_NAME`.  Each row will result in a unique alert.

#### Example 

```sql
BEGIN
   -- The value in the CONFIG_TABLE will not get changed if it already exists.
   app_config.add_param_num(p_name=>'blocked_sessions_alert_mins', p_num=>5);
END;
/

CREATE OR REPLACE VIEW alert__blocked_sessions AS 
SELECT 'warning' alert_level,
       'database' alert_type,
       'blocked_sessions' alert_name,
       value || ' BLOCKED SESSIONS' alert_info,
       60 notify_interval,
       0 alert_delay
FROM (
    SELECT COUNT(*) value
    FROM blocked_sessions
    WHERE block='IS BLOCKED' 
    AND last_call_et > 60 * app_config.get_param_num('blocked_sessions_alert_mins', 5)
    HAVING COUNT(*) > 0
);
```

#### Column Descriptions

| Name            | Description                                                                                         |
|-----------------|-----------------------------------------------------------------------------------------------------|
| `ALERT_LEVEL`   | Alert levels can be anything you want (e.g., info, warning, critical, error, fatal, etc.).          |
| `ALERT_TYPE`    | Alert type is a category for the alert (e.g., db, os, app, etc.).                                   |
| `ALERT_NAME`    | Alert names should be unique!                                                                       |
| `ALERT_INFO`    | Extra alert details. You can update this throughout the life of the alert if you want.              |
| `NOTIFY_INTERVAL` | Number of minutes to wait between repeat notifications.                                              |
| `ALERT_DELAY`   | Number of minutes to wait before this row is allowed to notify.                                      |

### PL/SQL API

You can also call `APP_ALERT.OPEN_ALERT` and `APP_ALERT.CLOSE_ALERT` directly.

#### Example

The following example demonstrates how to use these procedures to manage alerts based on session count.

```sql
DECLARE
   n NUMBER;
BEGIN
   -- Count the number of active sessions excluding background sessions.
   SELECT COUNT(*) INTO n FROM v$session WHERE type != 'BACKGROUND';

   IF n > 1000 THEN 
      app_alert.open_alert(
         p_alert_name => 'SESSION COUNT TOO HIGH!',
         p_alert_type => 'database',
         p_alert_level => 'warning',
         p_alert_info => 'session_count=' || n,
         p_notify_interval => 0,
         p_alert_delay => 0
      );
   ELSE 
      app_alert.close_alert(p_alert_name => 'SESSION COUNT TOO HIGH!');
   END IF;
END;
/
```

#### Explanation

- **Counting Sessions**: The `SELECT COUNT(*) INTO n FROM v$session WHERE type != 'BACKGROUND'` statement counts the number of active sessions excluding background sessions.
- **Opening an Alert**: If the session count exceeds 1000, `app_alert.open_alert` is called to open an alert. If the alert is already open, it updates the `alert_info` value if it has changed.
- **Closing an Alert**: If the session count is 1000 or below, `app_alert.close_alert` is called to close the alert. If the alert is not open, this call does not raise an error.


Your section on alert customization and control is clear, but it could benefit from a few enhancements for better readability and comprehension. Here are some suggestions:

1. **Clarify the purpose of the `modifications.sql` file**.
2. **Improve the explanation of the `alert_can_open_yn` function**.
3. **Add a detailed example to demonstrate customization**.
4. **Ensure consistent formatting**.

### Alert Customization and Control

When you run `app_install.sql` for the first time, Fuse generates an empty `modifications.sql` file. You can use this file to customize and modify the environment as required.

#### `alert_can_open_yn` Function

The `alert_can_open_yn` function is used to determine if an alert should be opened. You can customize this function to allow or prevent alerts based on the provided parameters. The parameters are passed to the function automatically from the `app_alert` package.

```sql
-- Source: app/app_alert.sql
CREATE OR REPLACE FUNCTION alert_can_open_yn (
   p_alert_name IN VARCHAR2,
   p_alert_level IN VARCHAR2,
   p_alert_info IN VARCHAR2,
   p_alert_type IN VARCHAR2,
   p_alert_view IN VARCHAR2
) RETURN VARCHAR2 IS 
BEGIN
   RETURN 'y';
END;
/
```

Here’s an example of how you might customize the `alert_can_open_yn` function to allow alerts only for critical database issues:

```sql
-- Source: app/app_alert.sql
CREATE OR REPLACE FUNCTION alert_can_open_yn (
   p_alert_name IN VARCHAR2,
   p_alert_level IN VARCHAR2,
   p_alert_info IN VARCHAR2,
   p_alert_type IN VARCHAR2,
   p_alert_view IN VARCHAR2
) RETURN VARCHAR2 IS 
BEGIN
   IF p_alert_level = 'critical' AND p_alert_type = 'database' THEN
      RETURN 'y';
   ELSE
      RETURN 'n';
   END IF;
END;
/
```

In this example, the function allows an alert to open only if it is of `critical` level and the type is `database`. For all other alerts, the function returns 'n', preventing the alert from being opened.

#### `alert_can_notify_yn` Function

The `alert_can_notify_yn` function determines if an alert should trigger a notification. You can customize this function to prevent or allow notifications based on the provided parameters. The parameters are passed to the function automatically from the `app_alert` package.

```sql
CREATE OR REPLACE FUNCTION alert_can_notify_yn (
   p_alert_name IN VARCHAR2,
   p_alert_level IN VARCHAR2,
   p_alert_info IN VARCHAR2,
   p_alert_type IN VARCHAR2,
   p_alert_view IN VARCHAR2
) RETURN VARCHAR2 IS 
BEGIN
   IF p_alert_level = 'info' THEN 
      RETURN 'n';
   END IF;
   RETURN 'y';
END;
/
```

