

-- This can probably be deleted since we got any changes to parameters covered by a sensor view.

create or replace view stat__database_parameters as
select 'parameter_'||name||' ('||inst_id||')' stat_name,
       'database' stat_group,
       to_number(value) value,
       'value' stat_type,
       null tags,
       null value_convert,
       null stat_label
  from gv$parameter
 where str_is_number_y_or_n(value)='Y' 
   and value is not null;