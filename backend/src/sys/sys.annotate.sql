create procedure sys.annotate(
    _name text,
    variadic _annotations text[]
)
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
        if _rec.kind = 'f' then
            _cmd = 'comment on function ' || _rec.proc || ' is ' || quote_literal(array_to_string(_annotations, E'\n'));
        elsif _rec.kind = 'p' then
            _cmd = 'comment on procedure ' || _rec.proc || ' is ' || quote_literal(array_to_string(_annotations, E'\n'));
        else
            continue;
        end if;

        raise info '%', _cmd;
        execute _cmd;
        _executed = true;
    end loop;

    if not _executed then
        raise exception 'Function or procedure "%" does not exist', _name;
    end if;
end;
$$;

call sys.annotate('sys.check', 'Performs a series of checks to ensure the database is set up correctly for the application.');
call sys.annotate('sys.drop', 'Drops all function or procedure overloads in a single command.');
call sys.annotate('sys.annotate', 'Comments all function or procedure overloads in a single command.');