select sys.check();
select sys.drop('pages.index');

create function pages.index(
    _user_id text = null,
    _user_name text = null, 
    _user_roles text[] = null,
    _permissions text[] = null,
    _headers json = null
)
returns text
language sql
immutable
parallel safe
as
$$
select format($html$<!DOCTYPE html>
<html lang="en" data-bs-theme="light">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title></title>
    <link href="/style.css?%1$s" rel="stylesheet" />
    <link href="index.css?%1$s" rel="stylesheet" />
    <script>user = JSON.parse('%2$s');</script>
    <script defer src="index.js"></script>
</head>
<body>
</body>
</html>$html$, 
    coalesce(_headers->>'X-build-id', ''),
    json_build_object(
        'id', _user_id, 
        'name', _user_name, 
        'roles', coalesce(_user_roles, array[]::text[]),
        'permissions', coalesce(_permissions, array[]::text[])
    )
);
$$;

select sys.annotate('pages.index', 
    'HTTP GET /', 
    'Content-Type: text/html', 
    'allow-anonymous'
);

create or replace function test.pages_index_has_user_script() 
returns text 
language sql 
as 
$$
select 
    case 
        when position('<script>user = JSON.parse(''{"id" : null, "name" : null, "roles" : [], "permissions" : []}'');</script>' in pages.index()) > 0 
        then 'ok' 
        else 'not ok: user script not found in pages.admin()' 
    end
$$;

select test.pages_index_has_user_script();