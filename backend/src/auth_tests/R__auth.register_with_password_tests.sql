call sys.check();
call sys.drop('auth_tests.register_with_password__bad_path');
call sys.drop('auth_tests.register_with_password__good_path');

create procedure auth_tests.register_with_password__bad_path()
language plpgsql as
$$
begin
    insert into auth.users (email) values ('test@test.com');

    assert auth.register_with_password('', '', '')::jsonb = '{"code":1,"message":"Invalid email."}'::jsonb,
        'Invalid email assert failed.';
    assert auth.register_with_password('xxx', '', '')::jsonb = '{"code":1,"message":"Invalid email."}'::jsonb, 
        'Invalid email assert failed.';
    assert auth.register_with_password('test@test.com', '', '')::jsonb = '{"code":2,"message":"User already exists."}'::jsonb, 
        'User already exists assert failed.';
    assert auth.register_with_password('test2@test2.com', '', '')::jsonb = '{"code":3,"message":"Password is required."}'::jsonb, 
        'Password is required assert failed.';
    assert auth.register_with_password('test2@test2.com', '123456', '654321')::jsonb = '{"code":4,"message":"Passwords do not match."}'::jsonb, 
        'Passwords do not match assert failed.';
    assert auth.register_with_password('test2@test2.com', '12345', '12345')::jsonb = '{"code":5,"message":"Password must be at least 6 characters."}'::jsonb,
        'Password must be at least 6 characters assert failed.';
    assert auth.register_with_password('test2@test2.com', repeat('x', 73), repeat('x', 73))::jsonb = '{"code":6,"message":"Password must be less than 72 characters."}'::jsonb,
        'Password must be less than 72 characters assert failed.';
    assert auth.register_with_password('test2@test2.com', 'abcxyz', 'abcxyz')::jsonb = '{"code":7,"message":"Password must contain at least 1 uppercase letter."}'::jsonb,
        'Password must contain at least 1 uppercase letter assert failed.';
    assert auth.register_with_password('test2@test2.com', 'ABCXYZ', 'ABCXYZ')::jsonb = '{"code":8,"message":"Password must contain at least 1 lowercase letter."}'::jsonb,
        'Password must contain at least 1 lowercase letter assert failed.';
    assert auth.register_with_password('test2@test2.com', 'Abcxyz', 'Abcxyz')::jsonb = '{"code":9,"message":"Password must contain at least 1 number."}'::jsonb,
        'Password must contain at least 1 number assert failed.';
    assert auth.register_with_password('test2@test2.com', 'Abcxyz1', 'Abcxyz1')::jsonb = '{"code":10,"message":"Password must contain at least 1 special character."}'::jsonb, 
        'Password must contain at least 1 special character assert failed.';

    rollback;
end
$$;

create procedure auth_tests.register_with_password__good_path()
language plpgsql as
$$
begin
    assert auth.register_with_password('test2@test2.com', 'Abcxyz1*', 'Abcxyz1*')::jsonb = '{"code":0,"message":"Success."}'::jsonb, 
        'Success assert failed.';

    assert (
        select count(*) 
        from auth.users 
        where 
            email = 'test2@test2.com' 
            and password_hash = crypt('Abcxyz1*', password_hash) 
            and confirmed = false 
            and providers = array['password']
    ) = 1,
    'User not created assert failed.';
    
    rollback;
end
$$;

--call auth_tests.register_with_password__bad_path();
--call auth_tests.register_with_password__good_path();
