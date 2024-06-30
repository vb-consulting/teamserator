call sys.check();
create schema if not exists auth;
grant usage on schema auth to teamserator_usr;
create extension if not exists pgcrypto;
