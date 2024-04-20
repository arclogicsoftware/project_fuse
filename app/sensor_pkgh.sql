
create or replace package sensor as

	procedure check_view (
	   p_view_name in varchar2);

	procedure check_sensor_views;

end;
/