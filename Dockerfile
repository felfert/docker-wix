FROM i386/debian:stable-slim

# misc prerequisites
RUN apt-get update && apt-get install -y bsdtar curl make wine procps

# Copy resources
ADD exelink.sh /tmp/
ADD pwrap waiton mkhostwrappers /usr/local/bin/

# winetricks
RUN curl -SL https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
   > /usr/local/bin/winetricks

# wix
RUN mkdir -p /opt/wix/bin && \
    apt-get install -y && mkdir -p /opt/wix/bin && \
    curl -SL https://github.com/wixtoolset/wix3/releases/download/wix311rtm/wix311-binaries.zip | \
    bsdtar -C /opt/wix/bin -xf - && sh /tmp/exelink.sh /opt/wix/bin && rm -f /tmp/exelink.sh && \
    apt-get purge -y --auto-remove --purge bsdtar tzdata && apt-get clean && \
    chmod +x /usr/local/bin/*

# create mount point
RUN useradd -m -s /bin/bash wix
RUN mkdir /work && chown wix:wix -R /work
VOLUME /work

# prep wine and install .NET Framework 4.0
USER wix
ENV WINEDEBUG=-all WD=/
RUN wine wineboot --init \
       && waiton wineserver \
       && winetricks --unattended dotnet40 \
       && waiton wineserver

# reduce image size
USER root
RUN rm -rf /usr/share/doc /usr/share/X11/locale 

USER wix
ENTRYPOINT ["pwrap"]
