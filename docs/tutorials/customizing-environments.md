---
title: Customizing the environment shell hooks
description: Building an enviornment with custom shell hooks.
---

# Customizing the environment shell hook

This guide uses the [environment's][environment_concept]
[shell hooks][hook_concept] to set up a PostgreSQL development database.

## Create a PostgreSQL environment

Say your project has a variable it expects to be set and you need to generate
the value for development.
This is a great use for the environment's **[shell hooks][hook_concept]**. 

Let's set up a Flox [environment][environment_concept] using the `postgresql_15`
package in your environment:

``` console
$ flox init --name postgres-example

✨ Created environment postgres-example (aarch64-darwin)

Next:
  $ flox search <package>    <- Search for a package
  $ flox install <package>   <- Install a package into an environment
  $ flox activate            <- Enter the environment
```

``` console
$ flox install postgresql_15
✅ 'postgresql_15' installed to environment postgres-example at /Users/youruser
```

## Customize the environment's shell hook

Let's add some properties PostgreSQL needs to run properly in this
[environment][environment_concept].

``` console
$ flox edit
```

Specifically, let's modify the **[hook section][hook_concept]**
and create a **script**.
All hook scripts inherit variables defined in the `[vars]` section of the manifest,
and environment variables set in the `hook.on-activate` script
are in turn inherited by the `[profile]` scripts that follow.


``` toml title="manifest.toml"

[install]
postgresql_15.pkg-path = "postgresql_15"

...

[hook]
on-activate = """
    export PGPORT="${PGPORT:-5432}"

    export PGUSER=pg-example
    export PGPASS=pg-example
    export PGDATABASE=example-database
    export SESSION_SECRET="$USER-session-secret"

    # Postgres environment variables
    export PGDATA=$PWD/postgres_data
    export PGHOST=$PWD/postgres
    export LOG_PATH=$PGHOST/LOG
    export DATABASE_URL="postgresql:///$PGDATABASE?host=$PGHOST&port=$PGPORT"
...

```

We can also use the **on-activate** hook
to add initialization logic that runs conditionally.

``` toml title="manifest.toml"
[hook]
on-activate = """
...
    mkdir -p $PGHOST
    if [ ! -d $PGDATA ]; then
      echo 'Initializing postgresql database...'
      initdb $PGDATA --username $PGUSER -A md5 --pwfile=<(echo $PGPASS) --auth=trust
      echo "listen_addresses='*'" >> $PGDATA/postgresql.conf
      echo "unix_socket_directories='$PGHOST'" >> $PGDATA/postgresql.conf
      echo "unix_socket_permissions=0700" >> $PGDATA/postgresql.conf
    fi
...
"""
```

!!! note "Note"
    The `hook.on-activate` script is always run in a `bash` shell.

**Save and exit your editor**, you should see a confirmation after Flox
validates the environment. 

```
✅ Environment successfully updated.
```

## Test the environment

You can now [`flox activate`][flox_activate] the environment to see the result
of your hard work!

``` 
$ flox activate
✅ You are now using the environment postgres-example at /Users/youruser.
To stop using this environment, type 'exit'

Initializing postgresql database...
The files belonging to this database system will be owned by user "youruser".
This user must also own the server process.

The database cluster will be initialized with locale "en_US.UTF-8".
The default database encoding has accordingly been set to "UTF8".
The default text search configuration will be set to "english".

Data page checksums are disabled.

creating directory /Users/youruser/postgres_data ... ok
creating subdirectories ... ok
selecting dynamic shared memory implementation ... posix
selecting default max_connections ... 100
selecting default shared_buffers ... 128MB
selecting default time zone ... America/New_York
creating configuration files ... ok
running bootstrap script ... ok
performing post-bootstrap initialization ... ok
syncing data to disk ... ok

Success. You can now start the database server using:

    pg_ctl -D /Users/youruser/postgres_data -l logfile start
```


## Where to next?

- :simple-readme:{ .flox-purple .flox-heart } [Multiple architecture environments][multi-arch-guide]

[flox_edit]: ../reference/command-reference/flox-edit.md
[flox_search]: ../reference/command-reference/flox-search.md
[flox_activate]: ../reference/command-reference/flox-activate.md
[create_enviornments_guide]: ./creating-environments.md
[multi-arch-guide]: ./multi-arch-environments.md
[manifest_concept]: ../concepts/manifest.md
[environment_concept]: ../concepts/environments.md
[hook_concept]: ../concepts/manifest.md#hook-section
