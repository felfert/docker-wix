FROM i386/debian:stable-slim

LABEL maintainer="docker-wix@fritz-elfert.de"

# misc prerequisites
RUN apt-get update && apt-get install -y --no-install-recommends wine && \
    apt-get purge -y --auto-remove --purge tzdata && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy resources
ADD exelink.sh /tmp/
ADD pwrap waiton mkhostwrappers /usr/local/bin/

# winetricks
RUN apt-get update && apt-get install -y --no-install-recommends curl && \
    curl -kSL https://raw.githubusercontent.com/felfert/winetricks/older-but-working/src/winetricks \
    > /usr/local/bin/winetricks && apt-get purge -y --auto-remove --purge curl && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc/* /usr/share/X11/locale && \
    chmod +x /usr/local/bin/*

# wix
RUN apt-get update && apt-get install -y --no-install-recommends curl bsdtar && \
    mkdir -p /opt/wix/bin && \
    curl -kSL https://github.com/wixtoolset/wix3/releases/download/wix3112rtm/wix311-binaries.zip | \
    bsdtar -C /opt/wix/bin -xf - && sh /tmp/exelink.sh /opt/wix/bin && rm -f /tmp/exelink.sh && \
    apt-get purge -y --auto-remove --purge curl bsdtar && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /usr/share/doc/* /usr/share/X11/locale

# create user and mount point
RUN useradd -m -s /bin/bash wix && mkdir /work && chown wix:wix -R /work
VOLUME /work

# prep wine and install .NET Framework 4.0
ENV WINEDEBUG=-all WD=/
RUN apt-get update && apt-get install -y --no-install-recommends curl procps && \
    echo insecure > /home/wix/.curlrc && \
    su -c "wine wineboot --init && waiton wineserver && winetricks --unattended dotnet40 && waiton wineserver" wix && \
    apt-get purge -y --auto-remove --purge curl procps && apt-get clean && \
    rm -rf /home/wix/.curlrc /var/lib/apt/lists/* /usr/share/doc/* /usr/share/X11/locale \
    /home/wix/.wine/drive_c/users/wix/Temp/* /usr/local/bin/waiton /usr/local/bin/winetricks

ARG finaluser=wix
USER $finaluser
ENTRYPOINT ["pwrap"]
