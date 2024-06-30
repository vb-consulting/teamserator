do
$sys$
begin
    if not exists(select 1 from pg_roles where rolname = 'teamserator_usr') then
        -- development application role
        -- for production environment, create a new role with a different password
        create role teamserator_usr with
            login
            nosuperuser
            nocreatedb
            nocreaterole
            noinherit
            noreplication
            connection limit -1
            password 'teamserator_usr';
        raise warning 'Role teamserator_usr created with a default password. Please change the password for role teamserator_usr';
    end if;

    if not exists(select 1 from information_schema.schemata where schema_name = 'sys') then
        raise exception 'Schema sys does not exist. Please create the schema and try again or use pgmigration tool.';
    end if;

    if not exists(select 1 from information_schema.routines where routine_schema = 'sys' and routine_name = 'check') then
        -- # import ./backend/src/_sys/sys.check.sql
    end if;

    call sys.check();

    if (select current_setting('TimeZone') != 'UTC') then
        alter database teamserator_db set timezone to 'UTC';
        set time zone 'UTC';
    end if;

    if not exists(select 1 from information_schema.routines where routine_schema = 'sys' and routine_name = 'drop') then
        -- # import ./backend/src/_sys/sys.drop.sql
    end if;

    if not exists(select 1 from information_schema.routines where routine_schema = 'sys' and routine_name = 'annotate') then
        -- # import ./backend/src/_sys/sys.annotate.sql
    end if;
end;
$sys$;
