FROM i386/debian:stable-slim

# misc prerequisites
RUN apt-get update && apt-get install -y bsdtar curl make wine procps

# create waiton
RUN printf '#!/bin/sh\n\
echo -n "Waiting on $@ ..."\n\
while pgrep -u wix "$@" > /dev/null; do\n\
		sleep 1;\n\
done\n\
echo " completed"\n' > /usr/local/bin/waiton && chmod +x /usr/local/bin/waiton

# winetricks
RUN curl -SL https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
   > /usr/local/bin/winetricks && chmod +x /usr/local/bin/winetricks

# wix
RUN printf '#!/bin/bash\n\
if [ -d "$1" ] ; then\n\
    find "$1" -name "*.exe" -type f -exec sh $0 "{}" \;\n\
elif [ -f "$1" ] ; then\n\
     bn=/usr/local/bin/`basename $1 .exe`\n\
     ( echo "#!/bin/sh"; echo "exec wine $1 \\"\\$@\\"" ) > "$bn"\n\
     chmod +x $bn || true\n\
fi\n' > /tmp/exelink.sh && mkdir -p /opt/wix/bin && \
    apt-get install -y && mkdir -p /opt/wix/bin && \
    curl -SL https://github.com/wixtoolset/wix3/releases/download/wix311rtm/wix311-binaries.zip | \
    bsdtar -C /opt/wix/bin -xf - && sh /tmp/exelink.sh /opt/wix/bin && rm -f /tmp/exelink.sh && \
    apt-get purge -y --auto-remove --purge bsdtar tzdata && apt-get clean

# create pwrap
RUN printf '#!/bin/bash\n\
if [ $# -ge 1 ] ; then\n\
    CMD=$1\n\
    shift\n\
    cd /work$WD && $CMD "$@"\n\
fi\n' > /usr/local/bin/pwrap && chmod +x /usr/local/bin/pwrap

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
