# Docker CUPS toPDF IPP & AirPrint Server

Docker image for CUPS server with a CUPS-PDF virtual printer.

**Image available on GitHub Container Registry:** `ghcr.io/shadowbq/docker-ubuntu-cups`

## What's New in v2.5

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

## FileBrowser Integration

The Kubernetes deployment includes FileBrowser for easy access to generated PDF files. When deploying via Kubernetes, access FileBrowser at port 8080 to browse and download all printed documents. On first startup, check the FileBrowser container logs to find the initial admin password: `kubectl logs -n cups -l app=cups -c filebrowser`. This web interface provides the primary access point to retrieve PDF files created by the virtual printer.

## IPP & AirPrint Support

This CUPS server provides comprehensive Internet Printing Protocol (IPP) support with AirPrint compatibility for seamless printing from modern devices:

### **IPP (Internet Printing Protocol) Features:**

- **IPP/2.1 Compliant**: Supports the latest IPP standards
- **IPP Everywhere**: Universal printing without proprietary drivers
- **Secure Communication**: TLS encryption support for sensitive documents
- **Network Discovery**: Automatic printer discovery via DNS-SD/mDNS
- **Job Management**: Complete print job status and control
- **PDF Virtual Printer**: Converts any print job to PDF format

### **AirPrint Capabilities:**

- **iOS/iPadOS Support**: Native printing from iPhone and iPad
- **macOS Integration**: Seamless printing from Mac applications
- **Automatic Discovery**: Zero-configuration printer setup
- **No Driver Installation**: Works with built-in system drivers
- **Wi-Fi Printing**: Print over wireless networks
- **Document Preview**: Print preview and page range selection

### **Supported Client Platforms:**

| Platform | Method | Requirements |
|----------|--------|--------------|
| **iOS/iPadOS** | AirPrint | iOS 4.2+ |
| **macOS** | AirPrint/IPP | macOS 10.7+ |
| **Windows** | IPP Driver | Windows 10+ |
| **Linux** | CUPS/IPP | Any distribution |
| **Chrome OS** | IPP | Built-in support |
| **Android** | Mopria/IPP | Android 8.0+ |

### **How to Use:**

#### **iOS/iPadOS:**

1. Open any app (Safari, Mail, Photos, etc.)
2. Tap **Share** → **Print**
3. Select **"PDF"** printer from the list
4. Configure options and tap **Print**

#### **macOS:**

1. Open any application
2. **File** → **Print** (⌘+P)
3. Select **"PDF"** from printer dropdown
4. Click **Print**

#### **Windows 10/11:**

1. **Settings** → **Printers & scanners**
2. **Add printer or scanner**
3. Select **"PDF"** when discovered
4. Use normally through any application

#### **Linux (CUPS):**

```bash
# Add printer manually if not auto-discovered
lpadmin -p PDF -v ipp://CUPS_SERVER_IP:631/printers/PDF -m everywhere
```

### **Network Requirements:**

- **Port 631/tcp**: IPP communication (HTTP/HTTPS)
- **Port 5353/udp**: mDNS/Bonjour discovery
- **Same Network Segment**: For automatic discovery
- **Multicast Support**: Network must allow mDNS packets

### **Access Methods:**

| Method | URL Format | Use Case |
|--------|------------|----------|
| **Web Interface** | `http://SERVER_IP:631` | Administration |
| **IPP Direct** | `ipp://SERVER_IP:631/printers/PDF` | Manual setup |
| **AirPrint** | Auto-discovered | iOS/macOS |
| **FileBrowser** | `http://SERVER_IP:8080` | PDF access |

### **Troubleshooting:**

#### **Discovery Issues:**

- Verify mDNS is working: `avahi-browse -at` (Linux/macOS)
- Check firewall allows ports 631 and 5353
- Ensure devices are on same network segment

#### **Printing Problems:**

- Check CUPS error logs: `kubectl logs -n cups -l app=cups -c cups`
- Verify printer status in web interface
- Test with simple text document first

#### **Network Debugging:**

```bash
# Test IPP connectivity
ipptool ipp://SERVER_IP:631/printers/PDF get-printer-attributes.test

# Check mDNS registration
avahi-browse -r _ipp._tcp

# Verify CUPS is listening
nmap -p 631 SERVER_IP
```

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
