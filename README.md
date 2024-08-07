

# Fuse Documentation

If you got this far, you have successfully installed Fuse and are ready to see what you can do with it.

## SQL MONITORING

SQL monitoring is accomplished using the SQL_LOG tool. This table will become an indispensable tool for monitoring and reviewing resource-intensive SQL statements.

The `SQL_LOG` table logs SQL statements in hourly intervals. It captures a range of performance metrics, including execution time, CPU usage, and I/O wait times for each SQL statement executed within a specified timeframe. This table also includes percentile ratings and historical references, enabling users to easily identify SQL statements or execution plans that fall outside typical performance parameters.

Designed for efficiency, the `SQL_LOG` table is able to store extensive SQL history for periods up to 1+ years with low storage overhead. This long-term retention capability allows for in-depth performance analysis and trend identification over longer periods of time.

Fuse includes several pre-built SQL views that streamline the querying and examination of data within the `SQL_LOG` table. Additionally, delivered alerts within the Fuse monitoring tool provide proactive notifications of SQL performance issues or anomalies, ensuring timely identification and resolution of potential bottlenecks.

## STATS

## SENSORS

## Sensors in the Toolkit

Sensors are specialized views prefixed with `SENSOR__`. They monitor specific data points in the database, track changes, and log modifications over time. When a sensor view is accessed, it updates the sensor's timestamp, inserts new data, and compares it with previous data to identify and log changes. Automated monitoring reduces the need for manual checks. Sensors quickly identify important changes and irregularities.

Sensors provide continuous tracking of database changes, log modifications to create a detailed record, and help ensure the consistency and security of the database.

The toolkit includes default sensors such as `sensor_accounts_of_interest.sql` and `sensor_database_parameters.sql` to help users start monitoring essential database aspects quickly.

## STORAGE/SPACE/GROWTH

## ALERTING

> **Alerts should be easy to create, customize, manage, and distribute. Alerts should be intelligent and adaptable.**

Fuse is delivered with a number of existing alerts. Most of which can be found in the `alerts` folder. 

Alerts are created by adding a row to the `ALERT_TABLE` using one of the methods described below.

Alerts views are checked every 5 minutes by default. The longer an alert runs the less frequent it can run. For example, an alert that takes 20 seconds to process will not be able to run for at least another 20 minutes (20 * 60 seconds). An alert that takes 60 seconds to run will not be able to run for at least another hour (60 * 60 seconds). Ideally your views should be designed to run as fast and efficiently as possible.

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

| Name             | Description                                                                                         |
|------------------|-----------------------------------------------------------------------------------------------------|
| `ALERT_LEVEL`    | Alert levels can be anything you want (e.g., info, warning, critical, error, fatal, etc.).          |
| `ALERT_TYPE`     | Alert type is a category for the alert (e.g., db, os, app, etc.).                                   |
| `ALERT_NAME`     | Alert names should be unique!                                                                       |
| `ALERT_INFO`     | Extra alert details. You can update this throughout the life of the alert if you want.              |
| `NOTIFY_INTERVAL`| Number of minutes to wait between repeat notifications.                                             |
| `ALERT_DELAY`    | Number of minutes to wait before this row is allowed to notify.                                     |

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

