# Modern CUPS Server with PDF printer
FROM ubuntu:24.04

LABEL maintainer="shadowbq@gmail.com"
LABEL description="CUPS server with CUPS-PDF virtual printer"
LABEL version="2.0"

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install CUPS and PDF printer driver
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        cups \
        cups-pdf \
        printer-driver-cups-pdf \
        ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy CUPS configuration files
COPY cupsd.conf cups-files.conf /etc/cups/

# Configure the PDF printer
RUN cupsd -f & pid=$! && \
    while test ! -S /run/cups/cups.sock; do sleep 1; done && \
    lpadmin -p PDF -v cups-pdf:/ -m lsb/usr/cups-pdf/CUPS-PDF_opt.ppd -E && \
    while kill "$pid" 2>/dev/null; do sleep 1; done

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