

/*

## Alert Views

Alert views should contain the following columns.

#### alert_level
   
   Text, any string you want to define the alert level. Suggestions are high, medium, low, warning, info, critical, fatal. The default alert level can be define in app_config.default_alert_level or you can override this value by using the config_table table.

#### alert_name

   Text, the name of the alert. This is the key used to identify the alert. A new alert name = a new alert. 

#### alert_info
   
   Text, any information you want to display about the alert. This info can be updated each time the alert is checked and if the alert is already open this info will be updated in the alert table.

*/

create or replace view alert__example as
select 'info' alert_level,
       'Example Alert' alert_name,
       'This is an example alert.' alert_info,
       'test' alert_type
  from dual a
 where 1=1;

 -- An simpler form of an alert view only returns a column called value. Value can be a number or text. It will get stored in the alert_info column of the alert_table.

create or replace view alert__example_value as 
select 'This is a simple alert.' value 
  from dual where 1=1;

-- The simplest form of an alert view is triggered if the view returns rows. The values of any columns are ignored.

create or replace view alert__example_simple as 
select * from dual where 1=1;



