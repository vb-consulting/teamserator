call sys.check();

create table auth.users (
    user_id bigint generated always as identity primary key,
    email text not null,
    password_hash text null,
    providers text[] not null default '{}',

    confirmed boolean not null default false,

    expires_at timestamptz null,
    active_after timestamptz null,

    password_attempts int not null default 0,

    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),

    constraint providers_check check (providers <@ array['password', 'google', 'github'])
);

create unique index on auth.users (email);