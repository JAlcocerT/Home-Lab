---
source_code: https://github.com/huginn/huginn?ref=fossengineer.com
---


https://github.com/huginn/huginn/blob/master/doc/docker/install.md

Log in to your Huginn instance using the username admin and password password

The recommended way to install Huginn with Docker is by using `docker-compose`.

This simplifies the setup by defining all the necessary services, such as the Huginn application and its database, in a single file.

1.  **Prerequisites**: Ensure you have **Docker** and **Docker Compose** installed on your machine.
2.  **Create a Docker Compose file**: Create a `docker-compose.yml` file. This file will define two services: one for the Huginn application and another for a database (such as MariaDB or MySQL). It's important to configure environment variables in this file for things like database passwords and user names.
3.  **Launch the containers**: Run the command `docker-compose up -d` in the same directory as your `docker-compose.yml` file. This command will download the necessary Docker images and start the containers in the background.
4.  **Access Huginn**: Once the containers are running, you can access the Huginn web interface by navigating to `http://localhost:3000` in your web browser. You may need to replace `localhost` with the IP address of your server if you're not running it locally.
5.  **Initial Setup**: The default login credentials are often `admin` for the username and `password` for the password. For security, it's crucial to change these immediately after your first login.

While a single-process container is available for testing, the multi-container `docker-compose` approach is recommended for production because it allows you to easily persist your data, ensuring it is not lost when you update the Huginn container.
