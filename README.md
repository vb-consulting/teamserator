
# The Teamserator (Full of Agile)

[![build-and-test](https://github.com/vb-consulting/teamserator/actions/workflows/build-and-test.yml/badge.svg)](https://github.com/vb-consulting/teamserator/actions/workflows/build-and-test.yml)
![License](https://img.shields.io/badge/license-MIT-green)
![GitHub Stars](https://img.shields.io/github/stars/vb-consulting/teamserator?style=social)
![GitHub Forks](https://img.shields.io/github/forks/vb-consulting/teamserator?style=social)

Project Management System Where the Entire Backend is Implemented as PostgreSQL User-Defined Functions

## What is this?

The Teamserator is a **technology demonstration project**.

This project demonstrates an approach to building business web applications - where **the entire backend logic, including all business logic - is implemented as the PostgreSQL user-defined database functions.**

All of it. 
Everything.
To the last bit. 
Even web pages that are server-rendered are PostgreSQL user-defined database functions.

### But why?

- Extreme simplicity.
- Super productivity.
- General awesomeness.
- Why not?

### Seriously, why?

Because logic should be as close as possible to data. 

And because SQL is an ideal language for declaring business logic. 

Why?

Because SQL is 4th generation declarative data programming language. It's a domain language where the domain is data itself. It abstracts the entire hardware, including memory and storage devices. It even has elements of a 5th generation language, because it abstracts algorithms too. The optimizer is usually able to find the most suitable algorithm for your declarations.

So, if it abstracts the hardware and it does, if it abstracts memory and storage and it does, and if it abstracts even algorithms, and it does, what is left then? 

That's right, your precious business logic.

So, yeah, SQL is the ideal place to do this. Change my mind.

However, it is not without challenges. This project intends to explore those challenges and possibilities.

### Ok, but how?

This project utilizes two important components:

1) [`NpgsqlRest` PostgreSQL Automatic REST API](https://github.com/vb-consulting/NpgsqlRest) acts like an automatic middleware that exposes PostgreSQL user-defined functions (and procedures) as HTTP endpoints. Once configured it never changes. 

It is, basically what is considered as a backend in a traditional setup where the database is the detail. In this setup, the database itself (PostgreSQL) is a backend and the middleware (`NpgsqlRest` component) is completely automated and is the real detail.

PostgreSQL user-defined functions and procedures that are exposed through HTTP endpoints are the public part of the backend. Database tables, private functions and procedures and all other PostgreSQL database objects are private parts of the backend.

2) [`@vbilopav/pgmigrations`](https://www.npmjs.com/package/@vbilopav/pgmigrations) is the PostgreSQL tool to manage migrations, schema versions, and database unit tests.

It works similarly to the Flyway database migration tool. The idea is to use file naming conventions to set the migration types: 
- Before and after migrations that will run always in order.
- Repeatable migrations that run only when changed.
- Versioned migrations that run once per version in version order.

It can also run functions that are configured as database tests to utilize unit testing and perhaps TDD approach as needed.

### But what does it do anyway?

It is also supposed to be a software development project management and task-tracking tool. 

The reason this domain is chosen is only because:
- It is business logic heavy.
- It requires the use of roles and permissions concepts.
- I know this domain (unlike others).

To be able to track this project's tasks - I opened the [Teamserator Project Board](https://github.com/orgs/vb-consulting/projects/3) so that I can track software development project tasks project with the GitHub software development project tasks.

Sounds about right.

Visit the [Teamserator Project Board](https://github.com/orgs/vb-consulting/projects/3).

## Structure

The directory structure:

- `backend` - main backend directory.
  - `src` - backend source code.
  - `cfg` - backend configuration.
  - `http` - HTTP files for testing (generated automatically by `NpgsqlRest`).
  - `logs` - backend log files (generated automatically by `NpgsqlRest` and git ignored).
  
- `fronted` - main fronted directory.
  - `src` - fronted source code (SvelteJS, Typescript, SCSS Styles, etc).
  - `cfg` - fronted configuration and build scripts.

- `wwwroot` - web server root to server the web static files. Contains output (JS and CSS files) from the frontend build process (git ignored).

## NPM Commands:

- `upgrade` - upgrade NPM packages.
- `audit` - audit NPM packages.
- `postinstall` - postinstallation script.
- `start` - starts `NpgsqlRest` middleware server by using these configurations: default, server, build id headers (optional), development, local (optional).
- `build` - builds all frontend files in parallel.
- `build-index` - build index page and styles.
- `build-admin` - build admin page and styles.
- `watch` - build all frontend files in parallel with map files and watch for changes.
- `watch-index` - build index page and styles with map files and watch for changes.
- `watch-admin` - build admin page and styles with map files and watch for changes.
- `scss` - build styles only.
- `scss-watch` - build styles only with map files and watch for changes.
- `data` - open the backend source directory with the azuredatastudio (recommended).
- `up` - run database migrations up.
- `up-list` - list available database migrations.
- `up-dump` - dump migration up a script to the console.
- `history` - see the history of the migration.
- `test` - run the tests.
- `test-list` - see the available tests.
- `schema` - dump the entire database schema to the console.
- `psql` - enter psql interactive mode.

## Configuration

...

## Concept

...

## Installation 

> IMPORTANT NOTE:
> 
> [npgsqlrest](https://www.npmjs.com/package/npgsqlrest) currenlty can only be installed **only on Windows-64 and Linux-64 machines**. The Mac OS builds are missing because I don't have a Mac machine. 
> 
> If someone could help me out with this I'd be grateful. 
> Sorry Mac bros.

> IMPORTANT NOTE 2:
>
> [`@vbilopav/pgmigrations`](https://www.npmjs.com/package/@vbilopav/pgmigrations) tool spawns `psql` or `pg_dump` external processes to execute database commands. That means, that PostgreSQL client tools must be installed on the system to be able to use this package. PostgreSQL client tools are distributed with the default installation so most likely you already have them pre-installed.
>
> If you don't, there is an option to install client tools only:
> - On Linux systems, there is a `postgresql-client` package, the apt installation would be then: `$ apt-get install -y postgresql-client` for the latest version.
> - On Windows systems, there is an option to install client tools only in the official installer.


To install and run the source code on your local machine you will have to have super-user access to the PostgreSQL instance at least 16 or higher. Either local or remote or containerized, doesn't matter, it only needs to be 16 or higher and the access user has to have super-user privileges.

NOTE: Check out the [GitHub Action CI/CD Pipeline YML file](https://github.com/vb-consulting/teamserator/blob/master/.github/workflows/build-and-test.yml) for help with your local installation. 

Steps:

1) Connect to the PostgreSQL database and create a fresh database for the application named `teamserator_db` and and new application user `teamserator_usr`. You can use this script too:

```sql
create database teamserator_db;
create role teamserator_usr with login password 'teamserator_usr';
```

2) Clone this repository and navigate to the `teamserator` directory:

```console
~$ git clone https://github.com/vb-consulting/teamserator.git
Cloning into 'teamserator'...
remote: Enumerating objects: 46, done.
remote: Counting objects: 100% (46/46), done.
remote: Compressing objects: 100% (42/42), done.
remote: Total 46 (delta 3), reused 43 (delta 3), pack-reused 0
Unpacking objects: 100% (46/46), 78.31 KiB | 1.57 MiB/s, done.
~$ cd teamserator/
~/teamserator$
```

3) Run `npm install`

4) Configure database access

Application is already configured to access PostgreSQL on localhost using port 5432, database `teamserator_db` and user `teamserator_usr`.

If you happen to have a different setup, just create a new local configuration named `/backend/cfg/appsettings-local.json` with the following content:

```json
{
  "ConnectionStrings": {
    "Default": "Host=127.0.0.1;Port=5432;Database=teamserator_db;Username=teamserator_usr;Password=teamserator_usr"
  }
}
```

And local file with pattern `*-local` is git ignored by default so you can configure this file any way you want.

Also, the `pgmigrations` need to be configured to use the same database but with the super-user account.

Default configuration `pgmigrations` configuration file  `/backend/cfg/pgmigrations.js` already uses localhost with 5432 and points to the `teamserator_db` database. Username and password are missing assuming that super-user credentials are supplied from the [environment variables](https://www.postgresql.org/docs/current/libpq-envars.html).

You can override these values with local, git ignored configuration. Create `/backend/cfg/pgmigrations-local.js` file with the following content:

```javascript
module.exports = {
    host: "localhost",
    port: "5432",
    dbname: "teamserator_db",
    username: "postgres",
    password: "postgres",
}
```

And override and configure as you need.

But you can also use the [environment variables](https://www.postgresql.org/docs/current/libpq-envars.html) on Linux like this:

```console
$ PGPASSWORD=postgres PGUSER=postgres npm run up
```

```console
$ PGPASSWORD=postgres PGUSER=postgres npm run test
```

5) Run migrations up: `npm run up`

6) Run build to build static files (JS and CSS in the `wwwroot`): `npm run build`

7) Start the application `npm run start`

8) Navigate to the URL.

## License

This project is licensed under the terms of the MIT license.
