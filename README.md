# Docker CUPS Server

Docker image for CUPS server with a CUPS-PDF virtual printer.

**Image available on GitHub Container Registry:** `ghcr.io/shadowbq/docker-ubuntu-cups`

## What's New in v2.0

- **Updated to Ubuntu 24.04 LTS (Noble)**
- **Added AirPrint support** for iOS/macOS device discovery via mDNS/Bonjour
- **Added Docker Compose support** for easy deployment
- **Added Kubernetes deployment manifests** with Longhorn storage and FileBrowser
- **Improved health checks** for better container orchestration
- **Enhanced security** with proper capabilities and permissions
- **Better logging** and error handling in entrypoint script

## Quick Start

Note: Github Workflows are used to build and push the Docker image to GitHub Container Registry. 

You can pull the latest image directly:

```bash
docker pull ghcr.io/shadowbq/docker-ubuntu-cups:latest
```

### Using Docker Run

```bash
docker run -d \
  --name cups-server \
  -p 631:631 \
  -e CUPS_ADMIN_PASSWORD=mysecurepassword \
  -v cups-pdf:/var/spool/cups-pdf/ANONYMOUS \
  ghcr.io/shadowbq/docker-ubuntu-cups:latest
```

### Using Docker Compose

**For local development and simple deployments:**

1. Copy the environment file:

```bash
cp .sample.env .env
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

**For production deployments with advanced features:**

The Kubernetes deployment includes:

- **Longhorn persistent storage** for PDF files
- **FileBrowser sidecar** for web-based PDF file management  
- **LoadBalancer service** with MetalLB integration
- **Secrets and ConfigMaps** for secure configuration management
- **Init containers** for proper directory setup

1. Update the admin credentials in the Secret within `kubernetes_deployment.yaml`:

```yaml
stringData:
  username: admin
  password: YOUR_SECURE_PASSWORD_HERE
```

2. Adjust the LoadBalancer IP for your network in the Service:

```yaml
annotations:
  metallb.universe.tf/loadBalancer-IPs: "192.168.87.23" # Change this IP
```

or remove the annotation to get a dynamic IP.

3. Deploy to your cluster:

```bash
kubectl apply -f kubernetes_deployment.yaml
```

4. Check the deployment status:

```bash
kubectl get pods -n cups
kubectl get pvc -n cups
kubectl get svc -n cups
```

5. Access the services:
   - **CUPS Web Interface**: `http://192.168.87.23:631` (use your LoadBalancer IP)
   - **PDF File Browser**: `http://192.168.87.23:8080` (FileBrowser interface)

## Configuration

### Environment Variables

> **Note:** Kubernetes deployment does **not** use `.env` files. Configuration is managed through Kubernetes Secrets and ConfigMaps.

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

- <http://localhost:631>

Login with the admin credentials you configured.

## AirPrint Support

This CUPS server includes AirPrint support for seamless printing from iOS and macOS devices:

### **Features:**
- **Automatic Discovery**: iOS/macOS devices will automatically discover the PDF printer
- **No Driver Installation**: Works with built-in AirPrint drivers
- **Secure Printing**: Uses CUPS authentication when configured

### **How to Use:**
1. **Ensure the CUPS server is running** on your network
2. **On iOS**: Open any app → Share → Print → Select "PDF" printer
3. **On macOS**: File → Print → Select "PDF" printer from the list

### **Network Requirements:**
- **mDNS/Bonjour**: The server advertises itself via multicast DNS
- **Port 631**: Must be accessible from client devices
- **Same Network**: Devices should be on the same local network for discovery

### **Troubleshooting AirPrint:**
- Verify the printer appears in iOS Settings → Printers & Scanners
- Check CUPS web interface shows "PDF" printer as enabled
- Ensure no firewall is blocking mDNS (port 5353) or CUPS (port 631)

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
