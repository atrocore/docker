# Getting started

## Environment Setup

Our docker-compose stack come with preconfigured Traefik and Let's Encrypt SSL certificate provider. If you already have
Traefik on your server, please delete `docker-compose.override.yaml` file from this directory.
Don't forget to attach `web` container to your Traefik network.

If you don't need an SSL certificate, please remove or comment marked sections inside `traefik.yml`,
`docker-compose.yaml` and `docker-compose.override.yaml` files in this directory.

Following variables in `.env` file are required to have working AtroPIM instance:

- `SKELETON_VARIANT` (`pim-no-demo`, `pim` are allowed variants). Default is `pim-no-demo`
- `PRODUCTION_DOMAIN` — domain of your main AtroPIM instance
- `PRODUCTION_STABILITY` (`stable`, `rc`) — stability branch of your AtroPIM instance. Default value is `stable`
- `POSTGRES_PASSWORD` — password of the `postgres` user of database. Do not use it to install AtroPIM
- `POSTGRES_PIM_USER`, `POSTGRES_PIM_PASSWORD`, and `POSTGRES_PIM_DB` — credentials of database user and database name
  to install AtroPIM instance.
- `PROXY_PRODUCTION_ROUTER` — identifier of Traefik router for main AtroPIM instance. Do not use dots in the value
- `PROXY_TESTING_ROUTER` — the same meaning as `PROXY_PRODUCTION_ROUTER`, but for testing instance

Please note that `PROXY_PRODUCTION_ROUTER` and `PROXY_TESTING_ROUTER` should be unique if you have multiple copies of
current docker-compose environment on the same server.

If you need to use Let's Encrypt certificate provider, also provide your email in `LETS_ENCRYPT_EMAIL` variable.

### Enable testing AtroPIM instance

If you need to install testing AtroPIM alongside with main AtroPIM instance, fill next variables:

- `TESTING_DOMAIN`, `TESTING_STABILITY` — the same meaning as `PRODUCTION_DOMAIN`, `PRODUCTION_STABILITY`, but it's for
  testing instance
- `POSTGRES_PIM_DB_TEST` — database name for the testing AtroPIM instance

Also, uncomment all labels under the line `# Uncomment to enable testing AtroPIM instance` inside `docker-compose.yaml` file.

## Deployment

1. Clone this repository locally;
2. Create environmental file from example: `cp .env.example .env`;
3. Set values of variables inside `.env` file (refer to Environment Setup section);
4. Run `docker compose up -d` command to build your image and to start a server;
5. Finish WEB installation process in the browser.

## Tips

1. While installing AtroPIM, on the Database Configuration page enter `db` as a database host.
2. It's highly recommended of using volumes to store data, since you can remove your containers and recreate them
   without risk of losing data. By default, volumes are already configured.
   Follow [Docker Documentation](https://docs.docker.com/engine/storage/volumes/#back-up-restore-or-migrate-data-volumes)
   for instructions to back up your data inside volumes.
3. If you need to run additional scripts to configure database, copy your scripts to the `.docker/postgres/scripts`
   directory. Find more information in the [postgres docs](https://hub.docker.com/_/postgres/) in the Initialization
   scripts section.
4. After every change in `.env` file you need to rebuild your `web` container: `docker compose build web --no-cache`.
   Then you should delete your containers (`docker compose down`) and recreate them with a new version of image (
   `docker compose up -d`).
5. By default, HTTP requests automatically redirected by Traefik to HTTPS. You can disable this behaviour by deleting
   `entryPoints.web.http.redirections` configuration in `traefik.yml` file. Don't forget to restart Traefik container.
6. If you need to store all files on the host directory, not inside the volume, please uncomment marked lines in
   `docker-compose.yaml` file inside `volumes:` section. Or, you can create `docker-compose.override.yaml` file with the
   following content:

```
volumes:
  web-data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ./data/web/
  db-data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ./data/db/
```