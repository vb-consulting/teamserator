call sys.check();
call sys.drop('pages_tests.pages_index_has_user_script');

create procedure pages_tests.pages_index_has_user_script() 
language plpgsql
as 
$$
begin
    assert 
        position('<script>user = JSON.parse(''{"id" : null, "name" : null, "roles" : [], "permissions" : []}'');</script>' in pages.index()) > 0, 
        'user script not found in pages.index()';
end;
$$;
--call pages_tests.pages_index_has_user_script();
