create procedure sys.check()
language plpgsql
as 
$$
declare 
    _db             constant text = 'teamserator_db';
    _test_schema    constant text = 'test';
    _user           constant text = 'teamserator_usr';
    _rec            record;
begin
    if (current_database() <> _db) then
        raise exception 'Database name must be "%" but it is %. Are you sure you are connected to the right database?', _db, current_database();
    end if;

    if not exists(select 1 from information_schema.schemata where schema_name = _test_schema) then
        execute format('create schema %s', _test_schema);
    end if;

    select * into _rec from pg_roles where rolname = _user;

    if _rec is null then
        raise exception 'Role "%" does not exist. Please create the role and try again.', _user;
    end if;

    if _rec.rolsuper is true then
        raise exception 'Role "%" must not be a superuser. Please revoke the superuser privilege and try again.', _user;
    end if;

    if _rec.rolcanlogin is not true then
        raise exception 'Role "%" must be able to login. Please grant the login privilege and try again.', _user;
    end if;

    if _rec.rolcreaterole is true then
        raise exception 'Role "%" must not be able to create roles. Please revoke the createrole privilege and try again.', _user;
    end if;

    set search_path = public;
end;
$$;
