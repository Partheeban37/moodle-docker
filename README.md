Great! Here's a **clean, shareable `README.md` style guide** you can include in your GitHub repo. It explains the setup clearly without repeating the code, perfect for teammates or anyone cloning your Moodle Docker setup.

---

#  Moodle Docker Setup Guide (Host-Based MySQL + Nginx Reverse Proxy)

This guide helps you deploy a **Moodle instance using Docker Compose**, where:

* Moodle runs in a **container**
* MySQL runs on the **host**
* Nginx acts as a **reverse proxy** (also on the host)

---

##  Folder Structure

```
moodle-docker/
│
├── Dockerfile                # Custom PHP 8.3 + Apache + Moodle setup
├── docker-compose.yml        # Defines the moodle service
├── .env                      # Environment variables for database config
├── /etc/nginx/sites-available/moodle.conf  # Nginx config on host (not inside repo)
```

---

##  Prerequisites

* Docker & Docker Compose installed
* MySQL Server running on host (`localhost:3306`)
* Nginx installed on host
* Port `8080` must be free (used to access Moodle via Nginx)

---

##  Step-by-Step Instructions

### 1.  Clone the Repo

```bash
https://github.com/Partheeban37/moodle-docker.git
cd moodle-docker
```

### 2.  Set Environment Variables

Make sure your `.env` file looks like this:

```
MOODLE_DB_NAME=moodle
MOODLE_DB_USER=moodleuser
MOODLE_DB_PASSWORD=yourpassword
MOODLE_DB_HOST=host.docker.internal
MOODLE_DB_PORT=3306
MOODLE_BRANCH=MOODLE_405_STABLE
```

>  `host.docker.internal` allows the container to access MySQL running on your host.

---

### 3.  Start Docker Container

```bash
docker-compose up -d --build
```

>  Check logs:

```bash
docker logs -f moodle-app
```

---

### 4.  Configure Nginx on Host

1. Save the provided Nginx config to:

   ```
   /etc/nginx/sites-available/moodle.conf
   ```

2. Create a symlink:

   ```bash
   sudo ln -s /etc/nginx/sites-available/moodle.conf /etc/nginx/sites-enabled/
   ```

3. Test and reload:

   ```bash
   sudo nginx -t
   sudo systemctl reload nginx
   ```

---

### 5.  Access Moodle

Open your browser and go to:

```
http://localhost
```

---

##  Troubleshooting

### 1.  Moodle container doesn't start

* Check if your `.env` file is correctly configured.
* Run `docker-compose down -v && docker-compose up -d --build` to restart fresh.

### 2.  MySQL connection refused

* Ensure MySQL is listening on port `3306`.
* Ensure `moodleuser` has access from `%` or `host.docker.internal`.
* Test manually from container:

  ```bash
  docker exec -it moodle-app bash
  php -r 'var_dump(mysqli_connect("host.docker.internal", "moodleuser", "yourpassword", "moodle"));'
  ```

### 3.  502 Bad Gateway (Nginx)

* Ensure correct IP in `proxy_pass` in `moodle.conf` matches the container's IP (e.g., `172.18.0.2`).
* Use `docker inspect moodle-app | grep IPAddress` to confirm.

---

##  Cleaning Up

To stop and remove everything:

```bash
docker-compose down -v
```

---

##  Done!

Your Moodle should now be up and running behind Nginx with host-based MySQL.

---
