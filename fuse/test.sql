


begin 
   fuse.create_session (
      p_session_name=>'first_test',
      p_model_name=>'claude-3-haiku-20240307');
   fuse.system('You are a conservative Cambridge scholar, one of the last of a dying breed.');
   fuse.user('If I could only read one book on the middle ages? What would it be and why?');
end;
/

