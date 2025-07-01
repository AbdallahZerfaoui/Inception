# 42 Inception Project - Requirement Checklist

This list is ordered to help you check your project systematically. Start with the foundational project structure and move down to the specific service configurations.

- [ ] --

### Tier 1: Core Project Structure & Submission Rules (Must-Haves for Evaluation)

- [ ] **Virtual Machine**: The entire project is set up and running on a Virtual Machine.
- [ ] **Git Repository**: All required files are present in your Git repository for submission.
### **`Makefile`**:
    - [ ] A `Makefile` is present at the **root** of your project.
    - [ ] The `Makefile` builds and launches the entire application using a single command (e.g., `make`).
    - [ ] The `Makefile` specifically uses `docker-compose.yml` to build the images and run the services (e.g., `docker-compose up --build`).
    - [ ] A rule to take down the services is also present (e.g., `make down` or `make fclean`).
### **File Structure**: The project follows the specified directory structure:
    - [ ] A `srcs` folder is at the root.
    - [ ] `srcs/` contains `docker-compose.yml` and the `.env` file.
    - [ ] `srcs/` contains a `requirements` directory.
    - [ ] `srcs/requirements/` contains a separate directory for each service (`nginx`, `mariadb`, `wordpress`).
    - [ ] Each service directory (e.g., `srcs/requirements/nginx/`) contains its own `Dockerfile`.

- [ ] --

### Tier 2: Docker & Docker Compose Architecture (The Main Goal)

- [ ] **Docker Compose**: The project is orchestrated using a single `docker-compose.yml` file.
- [ ] **Custom Images**: You are building your **own** Docker images from a `Dockerfile` for each service. You are **NOT** pulling pre-configured images like `wordpress:latest`, `mariadb:latest`, or `nginx:latest`.
- [ ] **Base Images**:
    - [ ] All services are built from either **Debian Buster** or a penultimate stable version of **Alpine Linux**.
    - [ ] The `latest` tag is **prohibited** for base images.
- [ ] **Containerization**:
    - [ ] There are at least three separate containers: Nginx, WordPress, and MariaDB.
    - [ ] Each service runs in its own dedicated container.
- [ ] **Networking**:
    - [ ] A custom Docker bridge network is defined in `docker-compose.yml` and used by all containers to communicate.
    - [ ] The use of `network: host` or the `links:` directive is **forbidden**.
- [ ] **Volumes**:
    - [ ] A dedicated volume is used for the MariaDB database files to ensure data persistence.
    - [ ] A dedicated volume is used for the WordPress website files (`/var/www/html`) to ensure data persistence.
    - [ ] The volumes are correctly mapped to `/home/login/data/` on the host VM (where `login` is your 42 login).

- [ ] --

### Tier 3: Security & Best Practices (Crucial Details)

- [ ] **Environment Variables**:
    - [ ] **No passwords** or sensitive data are hardcoded in any `Dockerfile`.
    - [ ] All secrets (database passwords, usernames, etc.) are passed to the containers using environment variables.
    - [ ] A `.env` file at the root of the `srcs` directory is used to store these variables.
- [ ] **Container Persistence**:
    - [ ] Containers are configured to restart automatically on crash (e.g., `restart: unless-stopped` in `docker-compose.yml`).
    - [ ] **Forbidden Hacks**: Containers are kept running by their main process (daemon), **NOT** by hacky commands like `tail -f /dev/null`, `sleep infinity`, or `while true`. This is a critical point.
- [ ] **Entrypoint**:
    - [ ] The NGINX container is the **only** container with a mapped port. It is the sole entrypoint to the infrastructure.
    - [ ] The exposed port is **only port 443**. Port 80 should not be accessible from the outside.
- [ ] **TLS/SSL**:
    - [ ] NGINX is configured to use TLSv1.2 or TLSv1.3 **only**. Older versions are disabled.
    - [ ] You have created your own self-signed SSL certificate for your domain.

- [ ] --

### Tier 4: Service-Specific Configuration (The Nitty-Gritty)

- [ ] **Domain Name**:
    - [ ] The domain name is configured to be `login.42.fr` (e.g., `wil.42.fr`).
    - [ ] Your VM's `/etc/hosts` file is modified so that this domain name points to its local IP address (`127.0.0.1`).
- [ ] **NGINX Container**:
    - [ ] Serves the WordPress site correctly.
    - [ ] Forwards PHP requests to the WordPress container on port 9000.
    - [ ] Does **not** contain WordPress or `php-fpm` itself.
- [ ] **WordPress Container**:
    - [ ] Contains WordPress files and `php-fpm`.
    - [ ] Is configured to listen for requests from NGINX on port 9000.
    - [ ] Is configured to connect to the MariaDB container using the service name (e.g., `mariadb:3306`).
    - [ ] Does **not** contain Nginx.
- [ ] **MariaDB Container**:
    - [ ] A database is properly set up for WordPress.
    - [ ] At least **two** users are created in the database: one administrator and one other user.
    - [ ] The administrator's username does **not** contain `admin` or `administrator` (case-insensitive).
    - [ ] Does **not** contain Nginx or WordPress.
