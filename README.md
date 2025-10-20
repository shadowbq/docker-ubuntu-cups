# Docker CUPS Server

Docker image for CUPS server with a CUPS-PDF virtual printer.

## What's New in v2.0

- **Updated to Ubuntu 24.04 LTS (Noble)**
- **Added Docker Compose support** for easy deployment
- **Added Kubernetes deployment manifests**
- **Improved health checks** for better container orchestration
- **Enhanced security** with proper capabilities and permissions
- **Better logging** and error handling in entrypoint script

## Quick Start

### Using Docker Run

```bash
docker run -d \
  --name cups-server \
  -p 631:631 \
  -e CUPS_ADMIN_PASSWORD=mysecurepassword \
  -v cups-pdf:/var/spool/cups-pdf/ANONYMOUS \
  shadowbq/docker-ubuntu-cups:latest
```

### Using Docker Compose

1. Copy the environment file:
```bash
cp .env.example .env
```

2. Edit `.env` and set your admin password

3. Start the service:
```bash
docker-compose up -d
```

4. View logs:
```bash
docker-compose logs -f
```

5. Stop the service:
```bash
docker-compose down
```

### Using Kubernetes

1. Update the admin credentials in `kubernetes-deployment.yaml`

2. Deploy to your cluster:
```bash
kubectl apply -f kubernetes-deployment.yaml
```

3. Check the deployment status:
```bash
kubectl get pods -n cups
kubectl logs -n cups -l app=cups
```

4. Port forward to access the web interface:
```bash
kubectl port-forward -n cups svc/cups-service 631:631
```

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `CUPS_ADMIN_USERNAME` | `admin` | Username for CUPS admin user |
| `CUPS_ADMIN_PASSWORD` | **(required)** | Password for CUPS admin user |
| `CUPS_LOG_LEVEL` | `warn` | CUPS log level (none, emerg, alert, crit, error, warn, notice, info, debug, debug2) |

### Volumes

- `/var/spool/cups-pdf/ANONYMOUS` - PDF output directory

### Ports

- `631/tcp` - CUPS web interface and printing service

### Custom Configuration

You can mount custom CUPS configuration files:

```bash
docker run -d \
  -v ./cupsd.conf:/etc/cups/cupsd.conf:ro \
  -v ./cups-files.conf:/etc/cups/cups-files.conf:ro \
  ...
```

### Initialization Scripts

Place executable scripts in `/docker-entrypoint.d/` to run custom initialization:

```bash
docker run -d \
  -v ./init-scripts:/docker-entrypoint.d:ro \
  ...
```

## Accessing the Web Interface

Once running, access the CUPS web interface at:
- http://localhost:631

Login with the admin credentials you configured.

## Building the Image

```bash
docker build -t docker-ubuntu-cups:latest .
```

## Health Checks

The container includes a health check that verifies CUPS is running:

```bash
docker inspect --format='{{.State.Health.Status}}' cups-server
```

## Security Considerations

- Always use a strong `CUPS_ADMIN_PASSWORD`
- Consider using Docker secrets or Kubernetes secrets for production
- The container requires some privileges to manage printing services
- Limit network exposure using firewalls or network policies
- Regularly update the base image for security patches

## Troubleshooting

### View CUPS logs
```bash
docker exec cups-server tail -f /var/log/cups/error_log
```

### Check CUPS status
```bash
docker exec cups-server lpstat -r
```

### List available printers
```bash
docker exec cups-server lpstat -p -d
```

## License

See LICENSE file for details.

## Contributing

Pull requests are welcome! Please test your changes before submitting.