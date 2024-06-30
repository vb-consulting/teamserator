/***********************************************

Configuration for the database migration and testing managament tool (pgmigrations).
Tool requires a superuser connection to the database in order to run migrations and commands.

See https://www.npmjs.com/package/@vbilopav/pgmigrations for more information.

To create a local development configuration, create a db-local.js file in the same directory as this file. It will be git ignored.

NPM Commands:

- Migrations UP                     "db-up": "pgmigrations up --config=./scripts/db.js --config=./scripts/db-local.js"
- List availabkle UP migrations     "db-up-list": "pgmigrations up --list --config=./scripts/db.js --config=./scripts/db-local.js"
- Dump to cionsole UP migrations    "db-up-dump": "pgmigrations up --dump --config=./scripts/db.js --config=./scripts/db-local.js"
- See current migrations history    "db-history": "pgmigrations history --config=./scripts/db.js --config=./scripts/db-local.js"
- Run tests                         "db-test": "pgmigrations test --config=./scripts/db.js --config=./scripts/db-local.js",
- See the test lists                "db-test-list": "pgmigrations test --list --config=./scripts/db.js --config=./scripts/db-local.js"
- Dump current schema               "db-schema": "pgmigrations schema --config=./scripts/db.js --config=./scripts/db-local.js"
- Enter into psql interactive mode  "psql": "pgmigrations psql --config=./scripts/db.js --config=./scripts/db-local.js"

***********************************************/
module.exports = {
    host: "localhost",
    port: "5432",
    dbname: "teamserator_db",

    migrationDir: "./backend/src/",
    recursiveDirs: true,

    historyTableName: "history",
    historyTableSchema: "sys",
    skipPattern: "scrap",
    
    testFunctionsSchemaSimilarTo: "%_tests",
}