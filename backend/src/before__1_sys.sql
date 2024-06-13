create or replace function sys.check()
returns void
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

select sys.check();

create or replace function sys.drop(
    variadic _names text[]
) 
returns void
language plpgsql
as 
$$
declare 
    _name text;
    _rec record;
    _cmd text;
    _executed boolean;
begin
    foreach _name in array _names loop
        _executed = false;
        for _rec in (
            select p.oid::regprocedure::text as proc, p.prokind as kind
            from pg_proc p join pg_namespace n 
            on p.pronamespace = n.oid and n.nspname = split_part(_name, '.', 1) and proname = split_part(_name, '.', 2)
            where p.prokind in ('f', 'p')
        )
        loop
            if _rec.kind = 'f' then
                _cmd = 'drop function ' || _rec.proc;
            elsif _rec.kind = 'p' then
                _cmd = 'drop procedure ' || _rec.proc;
            end if;
            raise info '%', _cmd;
            execute _cmd;
            _executed = true;
        end loop;

        if not _executed then
            raise warning 'Function or procedure "%" does not exist', _name;
        end if;
    end loop;
end;
$$;

create or replace function sys.annotate(
    _name text,
    variadic _annotations text[]
) 
returns void
language plpgsql
as 
$$
declare 
    _rec record;
    _cmd text;
    _executed boolean = false;
begin
    for _rec in (
        select p.oid::regprocedure::text as proc, p.prokind as kind
        from pg_proc p join pg_namespace n 
        on p.pronamespace = n.oid and n.nspname = split_part(_name, '.', 1) and proname = split_part(_name, '.', 2)
        where p.prokind in ('f', 'p')
    )
    loop
        _cmd = 'comment on function ' || _rec.proc || ' is ' || quote_literal(array_to_string(_annotations, E'\n'));
        raise info '%', _cmd;
        execute _cmd;
        _executed = true;
    end loop;

    if not _executed then
        raise exception 'Function or procedure "%" does not exist', _name;
    end if;
end;
$$;

select sys.annotate('sys.check', 'Performs a series of checks to ensure the database is set up correctly for the application.');
select sys.annotate('sys.drop', 'Drops all function or procedure overloads in a single command.');
select sys.annotate('sys.annotate', 'Comments all function or procedure overloads in a single command.');


