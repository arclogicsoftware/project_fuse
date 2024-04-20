


begin 
   fuse.create_session (
      p_session_name=>'test1',
      p_model_name=>'claude-3-haiku-20240307');
   fuse.user('Hello');
end;
/
