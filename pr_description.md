# Pull Request: Modernize Docker CUPS Server

## Overview

This PR modernizes the docker-ubuntu-cups repository with updated dependencies, improved orchestration support, and better DevOps practices.

## Changes Summary

### 🔄 Core Updates

- **Ubuntu Base Image**: Updated from `ubuntu:bionic` (18.04) to `ubuntu:24.04` (Noble LTS)
- **Package Updates**: All CUPS packages updated to latest versions from Ubuntu 24.04 repos
- **Security**: Added `ca-certificates` package for secure communications

### 🐳 Docker Improvements

- **Dockerfile**:
  - Improved layer caching and build efficiency
  - Added health check using `lpstat -r`
  - Better directory structure and permissions
  - Enhanced labels for metadata
  - Moved entrypoint script to `/usr/local/bin/` following best practices

- **Entrypoint Script**:
  - Improved error handling with `set -euo pipefail`
  - Better logging and user feedback
  - Enhanced validation of required environment variables
  - More robust initialization script handling

### 📦 New Files

#### Docker Compose Support (`docker-compose.yml`)

- Easy single-command deployment
- Environment variable management
- Named volumes for persistence
- Health checks configured
- Resource limits (optional)
- Network isolation
- Security hardening with `no-new-privileges`

#### Kubernetes Deployment (`kubernetes-deployment.yaml`)

- Complete K8s manifest with:
  - Namespace isolation
  - Secret management for credentials
  - ConfigMap for configuration
  - PersistentVolumeClaim for PDF storage
  - Deployment with proper resource limits
  - Liveness and readiness probes
  - Service definition
  - Optional Ingress configuration (commented)

#### Environment Template (`.sample.env`)

- Template for Docker Compose configuration
- Clear documentation of all available variables
- Safe defaults where applicable

#### GitHub Actions (`.github/workflows/docker-build.yml`)

- Automated Docker image building
- Multi-architecture support (amd64, arm64)
- Automatic tagging (latest, semver, branch)
- Docker Hub integration
- Build caching for faster CI/CD
- Automatic README sync to Docker Hub

#### Updated Documentation (`README.md`)

- Comprehensive quick start guides
- Docker, Docker Compose, and Kubernetes examples
- Configuration reference table
- Troubleshooting section
- Security considerations
- Health check documentation

### 🔒 Security Enhancements

- Non-privileged operation where possible
- Capability restrictions in Kubernetes
- Security context configurations
- Secret management examples
- No new privileges flag in Docker Compose

### 📊 Monitoring & Reliability

- Health checks at container and orchestration levels
- Proper probe configurations for Kubernetes
- Logging improvements
- Resource limits to prevent resource exhaustion

## Testing Checklist

Before merging, please verify:

- [ ] Docker build completes successfully
- [ ] Container starts with valid `CUPS_ADMIN_PASSWORD`
- [ ] Container fails gracefully without password
- [ ] CUPS web interface accessible on port 631
- [ ] PDF printer is configured and functional
- [ ] Health check returns healthy status
- [ ] Docker Compose deployment works
- [ ] Kubernetes manifests are valid (`kubectl apply --dry-run=client`)
- [ ] Volume mounts preserve PDF output
- [ ] Logs are visible via `docker logs` or `kubectl logs`

## Testing Commands

### Docker

```bash
# Build image
docker build -t docker-ubuntu-cups:test .

# Run container
docker run -d --name cups-test -p 631:631 \
  -e CUPS_ADMIN_PASSWORD=testpass123 \
  docker-ubuntu-cups:test

# Check health
docker inspect --format='{{.State.Health.Status}}' cups-test

# Test web interface
curl -u admin:testpass123 http://localhost:631/admin

# Cleanup
docker stop cups-test && docker rm cups-test
```

### Docker Compose

```bash
# Create .env file
echo "CUPS_ADMIN_PASSWORD=testpass123" > .env

# Start service
docker-compose up -d

# Check status
docker-compose ps
docker-compose logs

# Cleanup
docker-compose down -v
```

### Kubernetes

```bash
# Validate manifests
kubectl apply -f kubernetes-deployment.yaml --dry-run=client

# Deploy
kubectl apply -f kubernetes-deployment.yaml

# Check deployment
kubectl get all -n cups
kubectl logs -n cups -l app=cups

# Cleanup
kubectl delete -f kubernetes-deployment.yaml
```

## Breaking Changes

⚠️ **Base Image Change**: Ubuntu 18.04 → 24.04

- Users with pinned package versions may need updates
- Some package names may have changed
- Configuration file formats should be compatible but test thoroughly

## Migration Guide

For existing users:

1. **Update environment variables**: No changes required, fully backward compatible
2. **Volume data**: PDF output volume is compatible, no migration needed
3. **Configuration files**: Test custom `cupsd.conf` with new CUPS version
4. **Networking**: Port 631 remains the same

## Backward Compatibility

✅ All existing environment variables are supported
✅ Volume paths unchanged
✅ Port mappings unchanged
✅ Configuration file locations unchanged

## Future Enhancements (Not in this PR)

- [ ] Add support for additional printer drivers
- [ ] Implement SSL/TLS for CUPS web interface
- [ ] Add Prometheus metrics exporter
- [ ] Support for printer auto-discovery
- [ ] Multi-printer configuration examples

## Documentation Updates

- [x] README.md updated with new features
- [x] Added .env.example
- [x] Added inline comments in yaml files
- [x] Added troubleshooting section

## Related Issues

Closes #[issue-number] (if applicable)

## License

This work maintains the existing license of the repository.

---

**Ready for Review** 🚀

Please review and test the changes. Feedback welcome!
