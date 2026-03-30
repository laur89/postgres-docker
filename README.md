provides an [upstream](https://hub.docker.com/_/postgres) postgres image
with cron extension preinstalled

## installing pg_cron

- see https://github.com/citusdata/pg_cron#installing-pg_cron
- tl;dr: see [Dockerfile](./Dockerfile)


## upgrading major pgres versions

- option 1: use [pg_upgrade](https://www.postgresql.org/docs/current/pgupgrade.html)
- option 2: via `pg_dumpall` [docs](https://www.postgresql.org/docs/16/upgrading.html#UPGRADING-VIA-PGDUMPALL)
    - supposedly safer


- note [docs](https://www.postgresql.org/docs/16/upgrading.html) mention:
  > Though you can upgrade from one major version to another without upgrading to intervening versions, you should read the major release notes of all intervening versions

  Does that imply we can upgrade from say v15->18, or does it mean no need to
  do the intervening minor versions?

### pg_dumpall

- recommended to use `pg_dump*` programs from the newer version, but so far
  I've been ignoring it and dumping w/ the pg_dump from old container.

1. either stop all services using db, or better yet disable their access:
    - `nvim /mnt/user/appdata/postgres/pg_hba.conf`
    - sroll to the bottom
    - change all entries' `METHOD` value from `trust` to `reject` that do _not_
      start with `local`
      - likely just changing the last line `host all all all scram-sha-256`
        to `host all all all reject` should suffice, as long as it's the only
        rule that applies to _non-local_ connections
1. restart container/server
1. ssh/dbash to our pgres container
1. run `pg_dumpall -U postgres > "/config/dumpall-$(date '+%Y-%m-%d_%R')"; echo $?`
1. stop the server/container
1. on host, rename our postgres dir: `mv /mnt/user/appdata/postgres /mnt/user/appdata/postgres.old`
1. upgrade image to next version
1. start the container/service
1. restore `pg_hba.conf` & `postgresql.conf`
    - optionally diff them from host beforehand:
    - `vimdiff /mnt/user/appdata/postgres.old/postgresql.conf /mnt/user/appdata/postgres/postgresql.conf`
    - `vimdiff /mnt/user/appdata/postgres.old/pg_hba.conf /mnt/user/appdata/postgres/pg_hba.conf`
      - make sure not to revert access resjection yet!
    - `cp -- /mnt/user/appdata/postgres.old/{postgresql.conf,pg_hba.conf} /mnt/user/appdata/postgres/`
1. restart the container
1. on host, move dump to new dir: `cp /mnt/user/appdata/postgres.old/dumpall-* /mnt/user/appdata/postgres/`
1. restore data: `psql -d postgres -U postgres -f /config/dumpall-???; echo $?`
1. revert our modifications to `pg_hba.conf`
1. restart
1. nuke dump: `rm /mnt/user/appdata/postgres/dumpall-*`
1. if all good, nuke our old backup: `rm -r /mnt/user/appdata/postgres.old`

### pg_upgrade

TODO
