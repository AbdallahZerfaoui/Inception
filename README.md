# Inception

Based on the sources, here is a step-by-step plan to develop the 42 Inception project:

### Project Overview and Prerequisites

1.  **Understand the Project Goal**:
    *   The Inception project requires you to set up a small Docker-based infrastructure. This infrastructure must consist of **NGINX**, **WordPress**, and **MariaDB** services.
    *   The entire project needs to be done within a **Virtual Machine**.
    *   You must use **Docker Compose** for multi-container deployment and configuration.
    *   The infrastructure must comply with specific constraints, including custom configurations and security measures like **TLS**.

2.  **Prerequisites**:
    *   Ensure **Docker and Docker Compose are installed** on your host machine.
    *   Have a basic understanding of Docker, NGINX, WordPress, and MariaDB.

### Project Structure and General Guidelines

1.  **Set Up Directory Structure**:
    *   Create a **`srcs` folder** at the root of your project directory; all configuration files must be placed inside it.
    *   Place a **`Makefile` at the root** of your directory.
    *   Inside `srcs`, include your `docker-compose.yml` file and a `.env` file.
    *   Create a `requirements` folder within `srcs`, which will contain separate folders for each service (e.g., `mariadb`, `nginx`, `wordpress`).
    *   Each service folder (e.g., `mariadb`, `nginx`) should contain its own `Dockerfile` and a `conf` directory for service-specific configurations.

2.  **Adhere to Docker Guidelines**:
    *   Each Docker image must have the **same name as its corresponding service**.
    *   Each service has to run in a **dedicated container**.
    *   Containers must be built from the penultimate stable version of **Debian Buster** (or Alpine Linux).
    *   **Write your own Dockerfiles** for each service; do not pull ready-made Docker images (except the base OS).
    *   Ensure your containers are configured to **restart in case of a crash** (e.g., `restart: always` in `docker-compose.yml`).
    *   **Do not use hacky patches** like `tail -f`, `bash`, `sleep infinity`, or `while true` to keep containers running.
    *   The use of `network: host` or `--link`/`links:` is **forbidden**. A `network` line must be present in your `docker-compose.yml`.
    *   The `latest` tag for images is **prohibited**.
    *   **No passwords must be present in your Dockerfiles**; use environment variables, preferably stored in a **`.env` file** located in the `srcs` directory.

### Mandatory Service Setup

1.  **Configure NGINX**:
    *   **Role**: Acts as the **reverse proxy** and the **only entry point** into the infrastructure.
    *   **Port & TLS**: Listen on **port 443 only**, using **TLSv1.2 or TLSv1.3** protocols.
    *   **Dockerfile**:
        *   Install `nginx` and `openssl`.
        *   Create `/etc/nginx/ssl` directory.
        *   Copy your custom `default.conf` to `/etc/nginx/conf.d/default.conf`.
        *   Copy and execute a script (e.g., `generate_cert.sh`) to **generate a self-signed SSL certificate** (`nginx.key` and `nginx.crt`) within the container.
        *   Expose port 443.
        *   Ensure NGINX runs in the foreground (e.g., `nginx -g "daemon off;"`).
    *   **`nginx.conf`**: Handles static files and forwards PHP requests to WordPress (e.g., `fastcgi_pass wordpress:9000`).

2.  **Configure WordPress**:
    *   **Role**: PHP-based CMS served by NGINX and connected to MariaDB.
    *   **Execution**: Runs using **PHP-FPM on port 9000**.
    *   **Installation**: Automatically installs WordPress and sets up the database on first launch via a script.
    *   **Users**: Create two users in the WordPress database: an **administrator** and a **regular user**.
        *   The **administrator's username cannot contain "admin" or "administrator"** (e.g., "admin", "administrator", "Administrator", "admin-123" are forbidden). The `init_wp.sh` script should check for this.
    *   **Dockerfile**:
        *   Install necessary packages: `net-tools`, `php-fpm`, `php-mysql`, `wget`, `unzip`, `curl`, `mariadb-client`.
        *   Download and set up WordPress files in `/var/www/html`.
        *   Configure PHP-FPM to listen on port 9000.
        *   Copy and execute an initialization script (e.g., `init_wp.sh`) as the main command.
    *   **`init_wp.sh` script**:
        *   Wait for MariaDB to be ready before proceeding.
        *   Create `wp-config.php` using environment variables (e.g., `WORDPRESS_DB_NAME`, `WORDPRESS_DB_USER`, `WORDPRESS_DB_PASSWORD`, `MYSQL_DB_HOST`).
        *   Install WordPress core.
        *   Create the administrator user (e.g., `WORDPRESS_ADMIN_USER`, `WORDPRESS_ADMIN_PASSWORD`, `WORDPRESS_ADMIN_EMAIL`) and the regular user (e.g., `WORDPRESS_USER`, `WORDPRESS_USER_PASSWORD`, `WORDPRESS_USER_EMAIL`).

3.  **Configure MariaDB**:
    *   **Role**: Relational database system for storing WordPress data.
    *   **Initialization**: Initialized using a script (e.g., `init_db.sh`) to create the database and users specified in the `.env` file.
    *   **Dockerfile**:
        *   Install `mariadb-server`.
        *   Copy your `init_db.sh` script to `/usr/local/bin/init_db.sh` and make it executable.
        *   Expose port 3306.
        *   Set the command to execute `init_db.sh`.
    *   **`init_db.sh` script**:
        *   Initialize the MariaDB data directory if it doesn't exist.
        *   Modify the `bind-address` in MariaDB configuration (`/etc/mysql/mariadb.conf.d/50-server.cnf`) to `0.0.0.0` or comment it out to allow external connections.
        *   Start the MariaDB server (e.g., `mysqld_safe`).
        *   Create the WordPress database and users (`MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`, `MYSQL_ADMIN_USER`, `MYSQL_ADMIN_PASSWORD`) based on `.env` variables, and grant necessary privileges.

4.  **Manage Volumes**:
    *   Ensure **persistent storage** for WordPress files and MariaDB databases.
    *   Define two volumes in your `docker-compose.yml`:
        *   For MariaDB: Map to `/home/login/data/mariadb` on the host machine (e.g., `/home/mfaoussi/data/mariadb`) for database storage.
        *   For WordPress: Map to `/home/login/data/wordpress` on the host machine (e.g., `/home/mfaoussi/data/wordpress`) for website files.
    *   These volumes should use `driver: local` with `type: none` and `o: bind`.
    *   The `WP_DATA` and `DB_DATA` directories on the host machine should be created (e.g., using `mkdir -p` in the Makefile).

5.  **Set Up Docker Network**:
    *   Define a custom bridge network (e.g., `inception`) in your `docker-compose.yml`.
    *   All containers (NGINX, WordPress, MariaDB) must be connected to this single network to establish communication.

### Environment Variables and Domain Configuration

1.  **Create `.env` File**:
    *   Inside your `srcs` directory, create a `.env` file to store all sensitive information and configuration variables.
    *   Populate it with variables such as:
        *   `WORDPRESS_DB_NAME`, `WORDPRESS_DB_USER`, `WORDPRESS_DB_PASSWORD`, `WORDPRESS_DB_HOST`.
        *   `DOMAIN_NAME` (e.g., `mfaoussi.42.fr`).
        *   `WORDPRESS_TITLE`, `WORDPRESS_ADMIN_USER`, `WORDPRESS_ADMIN_PASSWORD`, `WORDPRESS_ADMIN_EMAIL`.
        *   `WORDPRESS_USER`, `WORDPRESS_USER_PASSWORD`, `WORDPRESS_USER_EMAIL`.
        *   `MYSQL_DB_HOST`, `MYSQL_ROOT_PASSWORD`, `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`, `MYSQL_ADMIN_USER`, `MYSQL_ADMIN_PASSWORD`.

2.  **Configure Domain Name**:
    *   Alter your `/etc/hosts` file on the host machine to map your custom domain name (e.g., `mfaoussi.42.fr`) to `127.0.0.1`. This domain name should be `login.42.fr` where `login` is your actual login.

### Makefile and Execution

1.  **Develop the Makefile**:
    *   The `Makefile` must be at the root of your project and **set up your entire application** by building Docker images using `docker-compose.yml`.
    *   Include targets for common Docker Compose operations:
        *   **`all`**: Default target, typically calls `up`.
        *   **`up`**: Builds and starts the services in detached mode (`docker compose up -d`). Should also create the volume data directories (`WP_DATA`, `DB_DATA`).
        *   **`down`**: Stops and removes containers, networks, images, and volumes.
        *   **`stop`**: Stops running services.
        *   **`start`**: Starts stopped services.
        *   **`build`**: Builds the service images.
        *   **`clean`**: Stops and removes all running containers, images, volumes, and networks, and also removes the WordPress and MariaDB data directories on the host.
        *   **`re`**: Rebuilds the infrastructure (e.g., `clean` then `up`).
        *   **`prune`**: Cleans up unused Docker objects including volumes (`docker system prune -a --volumes -f`).

### Verification and Interaction

1.  **Build and Start Services**:
    *   Execute `make up` from your project root directory.

2.  **Verify Setup**:
    *   Access WordPress by navigating to `https://mfaoussi.42.fr` (or your configured `DOMAIN_NAME`) in a web browser.
    *   Log in using the administrator credentials specified in your `.env` file.

3.  **Interact with Services**:
    *   **Access MariaDB**: From within its container, you can access the MariaDB prompt using `docker exec -it mariadb mysql -u root -p`.
    *   **Access WordPress**: Primarily through the web interface via NGINX.

### Bonus Part (Optional)

Once the mandatory part is **perfectly implemented and fully functional**, you can consider the bonus part:
*   Set up **Redis cache** for WordPress.
*   Set up an **FTP server** container pointing to the WordPress volume.
*   Create a simple **static website** (not PHP).
*   Set up **Adminer**.
*   Set up another service of your choice and be ready to justify it.

Remember that the bonus part will only be assessed if the mandatory part is integrally done and works without malfunctioning.