call sys.check();
call sys.drop('auth.consts');

create function auth.consts(
    _key text
)
returns text
language sql
immutable
parallel safe
as
$$
select case _key
    when 'algorithm' then 'bf'
    when 'max_attempts' then '5'
    when 'lockout_interval' then '5 minutes'
    when 'max_password_length' then '72'
    when 'min_password_length' then '6'
    when 'required_uppercase' then '1'
    when 'required_lowercase' then '1'
    when 'required_number' then '1'
    when 'required_special' then '1'
    else null
end;
$$;
