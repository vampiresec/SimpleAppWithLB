
# SimpleAppWithLB

A simple Python Flask application with NGINX load balancer implementation using Docker Compose. This project demonstrates how to set up load balancing across multiple application instances for improved performance and high availability.

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Load Balancing](#load-balancing)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## 🎯 Overview

This project showcases a containerized Python application with NGINX as a reverse proxy and load balancer. The setup allows you to:

- Run multiple instances of a Flask application
- Distribute incoming traffic across application replicas
- Handle high traffic loads efficiently
- Ensure high availability and fault tolerance

## 🏗️ Architecture

```
                    ┌─────────────────┐
                    │   NGINX (LB)    │
                    │   Port: 80      │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
        ┌─────▼─────┐  ┌────▼──────┐  ┌────▼──────┐
        │  App 1    │  │  App 2    │  │  App 3    │
        │ Port:5000 │  │ Port:5000 │  │ Port:5000 │
        └───────────┘  └───────────┘  └───────────┘
```

NGINX receives all incoming HTTP requests and distributes them across multiple Flask application instances using a round-robin algorithm (or other configured method).

## ✅ Prerequisites

Before running this project, ensure you have the following installed:

- [Docker](https://docs.docker.com/get-docker/) (version 20.10 or higher)
- [Docker Compose](https://docs.docker.com/compose/install/) (version 1.29 or higher)
- Git (for cloning the repository)

## 📁 Project Structure

```
SimpleAppWithLB/
├── app.py                    # Flask application
├── Dockerfile                # Docker image configuration for Flask app
├── docker-compose.yaml       # Main Docker Compose configuration
├── docker-copose.yaml        # Alternative/backup compose file
├── conf.d/                   # NGINX configuration directory
│   └── default.conf          # NGINX load balancer configuration
└── README.md                 # This file
```

## 🚀 Installation

1. **Clone the repository:**

```bash
git clone https://github.com/vampiresec/SimpleAppWithLB.git
cd SimpleAppWithLB
```

2. **Verify Docker installation:**

```bash
docker --version
docker-compose --version
```

## 💻 Usage

### Starting the Application

1. **Build and start all services:**

```bash
docker-compose up --build
```

Or run in detached mode:

```bash
docker-compose up -d --build
```

2. **Scale the application (optional):**

To run multiple instances of the Flask application:

```bash
docker-compose up --scale app=3
```

This creates 3 replicas of your application that NGINX will load balance.

### Accessing the Application

Once running, access the application through NGINX:

```
http://localhost:80
```

or simply:

```
http://localhost
```

### Stopping the Application

```bash
docker-compose down
```

To remove volumes as well:

```bash
docker-compose down -v
```

## ⚙️ Configuration

### Flask Application (app.py)

The Flask application is a simple web server. Modify `app.py` to customize your application logic:

```python
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    return "Hello from Flask!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
```

### NGINX Configuration (conf.d/default.conf)

The NGINX configuration defines the load balancing behavior. Example configuration:

```nginx
upstream flask_app {
    least_conn;  # or ip_hash, round_robin
    server app1:5000;
    server app2:5000;
    server app3:5000;
}

server {
    listen 80;
    
    location / {
        proxy_pass http://flask_app;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

### Docker Compose Configuration

Adjust `docker-compose.yaml` to modify:
- Number of application replicas
- Port mappings
- Environment variables
- Network configuration
- Volume mounts

## ⚖️ Load Balancing

NGINX supports several load balancing methods:

### Available Methods:

1. **Round Robin (default)**: Requests are distributed evenly across servers
2. **Least Connections (`least_conn`)**: Requests go to the server with fewest active connections
3. **IP Hash (`ip_hash`)**: Client IP determines which server receives the request
4. **Weighted**: Assign weights to servers for uneven distribution

### Changing Load Balancing Method

Edit `conf.d/default.conf` and modify the upstream block:

```nginx
upstream flask_app {
    least_conn;  # Change this line
    server app1:5000;
    server app2:5000;
    server app3:5000;
}
```

## 🧪 Testing

### Test Load Distribution

1. **Install curl or use browser:**

```bash
curl http://localhost
```

2. **Send multiple requests:**

```bash
for i in {1..10}; do curl http://localhost; done
```

3. **Check which instance handled the request:**

Modify your Flask app to return the container hostname:

```python
import socket

@app.route('/')
def hello():
    hostname = socket.gethostname()
    return f"Hello from {hostname}!"
```

### View Logs

```bash
# View all logs
docker-compose logs

# View specific service logs
docker-compose logs nginx
docker-compose logs app

# Follow logs in real-time
docker-compose logs -f
```

### Health Check

```bash
# Check running containers
docker-compose ps

# Check NGINX status
docker-compose exec nginx nginx -t
```

## 🔧 Troubleshooting

### Common Issues

**1. Port already in use:**
```bash
Error: Bind for 0.0.0.0:80 failed: port is already allocated
```
**Solution:** Change the port in `docker-compose.yaml` or stop the service using port 80.

**2. Container fails to start:**
```bash
docker-compose logs app
```
Check logs for specific error messages.

**3. Cannot connect to application:**
- Verify containers are running: `docker-compose ps`
- Check network connectivity: `docker network ls`
- Verify NGINX configuration: `docker-compose exec nginx nginx -t`

**4. Build fails:**
```bash
# Clean up and rebuild
docker-compose down
docker-compose build --no-cache
docker-compose up
```

### Debug Mode

Enable verbose logging in docker-compose:

```bash
docker-compose --verbose up
```


## 📝 License

This project is available for educational and demonstration purposes. Please check the repository for specific license information.

## 📧 Contact

For questions or issues, please open an issue on the [GitHub repository](https://github.com/vampiresec/SimpleAppWithLB/issues).

---

**Note:** This is a demonstration project. For production use, consider:
- Adding SSL/TLS certificates
- Implementing proper security headers
- Setting up monitoring and logging
- Configuring health checks
- Adding authentication and authorization
- Implementing rate limiting
- Using production-grade WSGI servers (Gunicorn, uWSGI)
