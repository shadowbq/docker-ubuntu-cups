# Modern CUPS Server with PDF printer
# Published to GitHub Container Registry: ghcr.io/shadowbq/docker-ubuntu-cups
FROM ubuntu:24.04

LABEL maintainer="shadowbq@gmail.com"
LABEL description="CUPS server with CUPS-PDF virtual printer"
LABEL version="2.0"

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install CUPS, PDF printer driver, and AirPrint support
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        cups \
        cups-pdf \
        printer-driver-cups-pdf \
        avahi-daemon \
        avahi-utils \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Setup CUPS directories and permissions for version 2.4+
RUN mkdir -p /var/run/cups /var/spool/cups /var/cache/cups && \
    chown -R root:lp /etc/cups /var/run/cups /var/spool/cups /var/cache/cups && \
    chmod -R 755 /etc/cups && \
    chmod -R 710 /var/run/cups /var/spool/cups /var/cache/cups

# Configure the PDF printer with temporary unrestricted config
RUN echo "LogLevel warn" > /etc/cups/cupsd.conf && \
    echo "Listen /run/cups/cups.sock" >> /etc/cups/cupsd.conf && \
    echo "<Location />" >> /etc/cups/cupsd.conf && \
    echo "  Order allow,deny" >> /etc/cups/cupsd.conf && \
    echo "  Allow all" >> /etc/cups/cupsd.conf && \
    echo "</Location>" >> /etc/cups/cupsd.conf && \
    cupsd -f & pid=$! && \
    while test ! -S /run/cups/cups.sock; do sleep 1; done && \
    lpadmin -p PDF -v cups-pdf:/ -m lsb/usr/cups-pdf/CUPS-PDF_opt.ppd -E && \
    while kill "$pid" 2>/dev/null; do sleep 1; done

# Copy CUPS and Avahi configuration files
COPY cupsd.conf cups-files.conf /etc/cups/
COPY avahi-daemon.conf /etc/avahi/

# Copy and setup entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Create PDF output directory with proper permissions
RUN mkdir -p /var/spool/cups-pdf/ANONYMOUS && \
    chmod 1777 /var/spool/cups-pdf/ANONYMOUS

# Expose CUPS web interface port
EXPOSE 631

# Volume for PDF output
VOLUME ["/var/spool/cups-pdf/ANONYMOUS"]

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD lpstat -r || exit 1

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]