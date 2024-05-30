

begin
  dbms_audit_mgmt.set_last_archive_timestamp(
    audit_trail_type => dbms_audit_mgmt.audit_trail_unified, 
    last_archive_time => systimestamp - interval '12' month);
end;
/

begin
  dbms_audit_mgmt.clean_audit_trail(
    audit_trail_type => dbms_audit_mgmt.audit_trail_unified, 
    use_last_arch_timestamp => true);
end;
/
