call sys.check();
call sys.drop('auth.register_with_password');

create function auth.register_with_password(
    _email text,
    _password text,
    _repeat text
)
returns json
language plpgsql
volatile
as
$$
declare
    _max_password_length constant int = 72; -- max blowfish password length
    _min_password_length constant int = 6;
    _required_uppercase constant int = 1;
    _required_lowercase constant int = 1;
    _required_number constant int = 1;
    _required_special constant int = 1;
begin 
    if auth.validate_email(_email) is false then
        return json_build_object(
            'code', 1,
            'message', 'Invalid email.'
        );
    end if;

    if exists(select 1 from auth.users where email = _email) then
        return json_build_object(
            'code', 2,
            'message', 'User already exists.'
        );
    end if;

    if _password is null or _password = '' then
        return json_build_object(
            'code', 3,
            'message', 'Password is required.'
        );
    end if;

    if _password <> _repeat then
        return json_build_object(
            'code', 4,
            'message', 'Passwords do not match.'
        );
    end if;

    if length(_password) < _min_password_length then
        return json_build_object(
            'code', 5,
            'message', format('Password must be at least %s characters.', _min_password_length)
        );
    end if;

    if length(_password) > _max_password_length then
        return json_build_object(
            'code', 6,
            'message', format('Password must be less than %s characters.', _max_password_length)
        );
    end if;

    if coalesce(_required_uppercase, 0) > 0 and (select count(*) from regexp_matches(_password, '[A-Z]', 'g')) < _required_uppercase then
        return json_build_object(
            'code', 7,
            'message', format('Password must contain at least %s uppercase letter.', _required_uppercase)
        );
    end if;

    if coalesce(_required_lowercase, 0) > 0 and (select count(*) from regexp_matches(_password, '[a-z]', 'g')) < _required_lowercase then
        return json_build_object(
            'code', 8,
            'message', format('Password must contain at least %s lowercase letter.', _required_lowercase)
        );
    end if;

    if coalesce(_required_number, 0) > 0 and (select count(*) from regexp_matches(_password, '[0-9]', 'g')) < _required_number then
        return json_build_object(
            'code', 9,
            'message', format('Password must contain at least %s number.', _required_number)
        );
    end if;

    if coalesce(_required_special, 0) > 0 and (select count(*) from regexp_matches(_password, '[^a-zA-Z0-9]', 'g')) < _required_special then
        return json_build_object(
            'code', 10,
            'message', format('Password must contain at least %s special character.', _required_special)
        );
    end if;

    insert into auth.users (
        email, 
        password_hash, 
        providers, 
        confirmed, 
        locked
    ) 
    values (
        _email, 
        crypt(_password, gen_salt('bf')),
        array['password'],
        false, 
        false
    );

    return json_build_object(
        'code', 0,
        'message', 'Success.'
    );
end
$$;


call sys.annotate(
    'auth.register_with_password', 
    'HTTP POST /auth/register',
    'anonymous'
);


create or replace procedure test.register_with_password__bad_path()
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
--call test.register_with_password__bad_path();

create or replace procedure test.register_with_password__good_path()
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
            and locked = false
            and providers = array['password']
    ) = 1,
    'User not created assert failed.';
    
    rollback;
end
$$;
--call test.register_with_password__good_path();
