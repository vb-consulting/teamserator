drop schema if exists auth_tests cascade;
create schema auth_tests;

create procedure auth_tests.auth_validate_emails()
language plpgsql as
$$
declare
    _record record;
begin
    for _record in (select * from (values
        ('ValidDomain', 'email@example.com', TRUE),
        ('WebIsDomain', 'email@example.web', TRUE),
        ('DotInAddress', 'firstname.lastname@example.com', TRUE),
        ('DotInSubdomain', 'email@subdomain.example.com', TRUE),
        ('PlusInAddress', 'firstname+lastname@example.com', TRUE),
        ('DomainIsValidIPAddress', 'email@123.123.123.123', TRUE),
        ('DomainIsValidIPAddressInBrackets', 'email@[123.123.123.123]', TRUE),
        ('QuotedAddress', '"email"@example.com', TRUE),
        ('DigitsInAddress', '1234567890@example.com', TRUE),
        ('DashInDomain', 'email@example-one.com', TRUE),
        ('UnderscoreAddress', '_______@example.com', TRUE),
        ('DashInAddress', 'firstname-lastname@example.com', TRUE),
        ('ListOfAddresses1', 'email1@example.com, email2@example.com', FALSE),
        ('ListOfAddresses2', 'email1@example.com; email2@example.com', FALSE),
        ('ListOfAddresses3', 'email1@example.com email2@example.com', FALSE),
        ('EmptyString', '', FALSE),
        ('MissingAtAndDomain', 'plainaddress', FALSE),
        ('Garbage', '#@%^%#$@#$@#.com', FALSE),
        ('MisingAddress', '@example.com', FALSE),
        ('EncodedHtml', 'Joe Smith <email@example.com>', FALSE),
        ('MissingAt', 'email.example.com', FALSE),
        ('TwoAtSigns', 'email@example@example.com', FALSE),
        ('LeadingDot', '.email@example.com', FALSE),
        ('TrailingDotInAddress', 'email@example.com.', FALSE),
        ('MultipleDotsAddress', 'email..email@example.com', FALSE),
        ('UnicodeInAddress', 'あいうえお@example.com', FALSE),
        ('TextAfterEmail', 'email@example.com (Joe Smi)', FALSE),
        ('MissingTopLevelDomain', 'email@example', TRUE),
        ('LeadingDashDomain', 'email@-example.com', TRUE),
        ('MultipleDotsInDomain', 'email@example..com', FALSE),
        ('NotRight1', '"(),:;<>[\]@example.com', FALSE),
        ('MultipleQuotes', 'just"not"right@example.com', FALSE),
        ('NotAllowed', 'this\isreally"not\allowed@example.com', FALSE),
        ('VeryVeryUnusual1', 'very."(),:;<>[]".VERY."very@\"very".unusual@strange.example.com', TRUE),
        ('VeryVeryUnusual2', 'very."(),:;<>[]".VERY."very"very".unusual@strange.example.com', FALSE),
        ('MuchMoreUnusal', 'much."more\ unusual"@example.com', TRUE),
        ('VeryUnusual', 'very.unusual."@".unusual.com@example.com', TRUE)) t (id, test, expected)
    ) loop
        assert auth.validate_email(_record.test) = _record.expected, 'Test ' || _record.id || ' failed.';
    end loop;
end
$$;

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

create procedure auth_tests.login_with_password__bad_path()
language plpgsql as
$$
declare
    _record record;
    _now timestamptz = '2020-01-01 00:00:00';
begin
    select * into _record from auth.login_with_password('xx', '');
    assert _record.status = 400, 'Invalid email should return 400';

    select * into _record from auth.login_with_password('notexsists@notexsists', '');
    assert _record.status = 404, 'User does not exist should return 404';

    insert into auth.users (email, expires_at) values ('user@expired', _now - interval '1 day');
    select * into _record from auth.login_with_password_internal('user@expired', '', _now);
    assert _record.status = 423, 'User expired should return 423';

    insert into auth.users (email, active_after) values ('user@inactive', _now + interval '1 day');
    select * into _record from auth.login_with_password_internal('user@inactive', '', _now);
    assert _record.status = 425, 'User inactive should return 425';

    insert into auth.users (email, confirmed) values ('user@unconfirmed', false);
    select * into _record from auth.login_with_password('user@unconfirmed', '');
    assert _record.status = 403, 'User unconfirmed should return 403';

    insert into auth.users (email, password_hash, confirmed) values ('user@nopassword', null, true);
    select * into _record from auth.login_with_password('user@nopassword', '');
    assert _record.status = 406, 'User without password should return 406';

    insert into auth.users (email, password_hash, confirmed) values ('user@badpassword', crypt('password', gen_salt('bf')), true);
    select * into _record from auth.login_with_password('user@badpassword', 'badpassword');
    assert _record.status = 401, 'Invalid password should return 401';

    perform auth.login_with_password('user@badpassword', 'badpassword'); --attempt 2
    perform auth.login_with_password('user@badpassword', 'badpassword'); --attempt 3
    perform auth.login_with_password('user@badpassword', 'badpassword'); --attempt 4
    select * into _record from auth.login_with_password('user@badpassword', 'badpassword'); --attempt 5

    assert _record.status = 423, 'User locked out should return 423';

    ROLLBACK;
end;
$$;

create procedure auth_tests.login_with_password__good_path()
language plpgsql as
$$
declare
    _record record;
begin

    insert into auth.users (email, password_hash, confirmed) values ('user@goodpassword', crypt('password', gen_salt('bf')), true);
    select * into _record from auth.login_with_password('user@goodpassword', 'password');
    assert _record.status = 200, 'Valid password should return 200';

    select * into _record from auth.login_with_password('user@goodpassword', 'password');
    assert _record.status = 200, 'Valid password should return 200';

    ROLLBACK;
end;
$$;

/*
call auth_tests.auth_validate_emails();
call auth_tests.register_with_password__bad_path();
call auth_tests.register_with_password__good_path();
call auth_tests.login_with_password__bad_path();
call auth_tests.login_with_password__good_path();
*/
