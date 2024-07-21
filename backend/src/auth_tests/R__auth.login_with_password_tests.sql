call sys.check();
call sys.drop('auth_tests.login_with_password__bad_path');
call sys.drop('auth_tests.login_with_password__good_path');

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

--call auth_tests.login_with_password__bad_path();
--call auth_tests.login_with_password__good_path();
