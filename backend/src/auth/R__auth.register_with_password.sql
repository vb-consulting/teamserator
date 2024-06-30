call sys.check();
call sys.drop('auth.register_with_password');

create function auth.register_with_password(
    _email text,
    _password text,
    _repeat text
)
returns json
language plpgsql
as
$$
declare
    _algorithm constant text = auth.consts('algorithm');
    _max_password_length constant int = auth.consts('max_password_length')::int;
    _min_password_length constant int = auth.consts('min_password_length')::int;
    _required_uppercase constant int = auth.consts('required_uppercase')::int;
    _required_lowercase constant int = auth.consts('required_lowercase')::int;
    _required_number constant int = auth.consts('required_number')::int;
    _required_special constant int = auth.consts('required_special')::int;
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
        confirmed
    ) 
    values (
        _email, 
        crypt(_password, gen_salt(_algorithm)),
        array['password'],
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
