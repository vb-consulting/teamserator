call sys.check();
call sys.drop('auth.login_with_password_internal');
call sys.drop('auth.login_with_password');

create function auth.login_with_password_internal(
    _email text,
    _password text,
    _now timestamptz
)
returns table (
    status int,
    name_identifier text, 
    name text
)
language plpgsql
as
$$
declare
    _record record;
    _attempt int;
    _algorithm constant text = auth.consts('algorithm');
    _max_attempts constant int = auth.consts('max_attempts')::int;
    _lockout_interval constant interval = auth.consts('lockout_interval')::interval;
begin 
    if auth.validate_email(_email) is false then
        raise info 'Invalid email in logging attempt. %', _email;
        return query select 400, null, null;
        return;
    end if;

    select user_id, email, expires_at, active_after, confirmed, password_hash 
    into _record
    from auth.users
    where email = _email;

    if _record is null then
        raise info 'User does not exist in logging attempt. %', _email;
        return query select 404, null, null;
        return;
    end if;

    if _record.expires_at is not null and _record.expires_at < _now then
        raise info 'User is expired in logging attempt. %', _email;
        return query select 423, null, null;
        return;
    end if;

    if _record.active_after is not null and _record.active_after > _now then
        raise info 'User is not active in logging attempt. %', _email;
        return query select 425, null, null;
        return;
    end if;

    if _record.confirmed is false then
        raise info 'User is not confirmed in logging attempt. %', _email;
        return query select 403, null, null;
        return;
    end if;

    if _record.password_hash is null then
        raise info 'User does not have a password in logging attempt. %', _email;
        return query select 406, null, null;
        return;
    end if;

    if crypt(_password, _record.password_hash) <> _record.password_hash then
        update auth.users
        set password_attempts = password_attempts + 1
        where user_id = _record.user_id
        returning password_attempts 
        into _attempt;

        if _attempt >= _max_attempts then
            update auth.users
            set active_after = _now + _lockout_interval
            where user_id = _record.user_id;

            raise info 'User % is locked out in logging attempt until %', _email, _now + _lockout_interval;
            return query select 423, null, null;
            return;
        end if;

        raise info 'Invalid password in logging attempt. %', _email;
        return query select 401, null, null;
        return;
    end if;

    update auth.users
    set 
        password_attempts = 0,
        password_hash = crypt(_password, gen_salt(_algorithm))
    where 
        user_id = _record.user_id;

    return query 
    select 200, _record.user_id::text, _email;
end
$$;

create function auth.login_with_password(
    _email text,
    _password text
)
returns table (
    status int,
    name_identifier text, 
    name text
)
language sql as 'select status, name_identifier, name from auth.login_with_password_internal(_email, _password, now());';

call sys.annotate(
    'auth.login_with_password', 
    'HTTP POST /auth/login',
    'anonymous'
);
