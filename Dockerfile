ARG OS_VERSION
FROM alpine:${OS_VERSION} as builder

ARG OS_VERSION
ARG DS_VERSION
ARG TARGETPLATFORM

LABEL description="389 Directory Server. The enterprise-class Open Source LDAP server for Linux."
LABEL maintainer="Thorsten Ludewig <t.ludewig@gmail.com>"
LABEL org.opencontainers.image.authors="Thorsten Ludewig <t.ludewig@gmail.com>"
LABEL org.opencontainers.image.source="https://github.com/thorsten-l/389ds-alpine"
LABEL org.opencontainers.image.description="389 Directory Server. The enterprise-class Open Source LDAP server for Linux."
LABEL version=${DS_VERSION}


RUN echo "${DS_VERSION}-alpine${OS_VERSION} @ $TARGETPLATFORM"

RUN apk add build-base wget libtool autoconf automake openssl-dev cracklib-dev \
            libevent-dev nspr-dev nss-dev openldap-dev db-dev icu-dev \
            net-snmp-dev krb5-dev pcre-dev make rsync nss-tools openssl \
            linux-pam-dev python3 py3-pip python3-dev git rust cargo

RUN pip install setuptools argcomplete python-ldap python-dateutil

RUN mkdir /build
WORKDIR /build
RUN wget "https://github.com/389ds/389-ds-base/archive/refs/tags/389-ds-base-$DS_VERSION.tar.gz"
RUN tar xvfz "389-ds-base-$DS_VERSION.tar.gz"
WORKDIR "/build/389-ds-base-389-ds-base-$DS_VERSION"

RUN ./autogen.sh && ./configure --with-openldap --enable-rust

RUN sed -e 's/.*build_manpages.*/\tcd \$\(srcdir\)\/src\/lib389\; \$\(PYTHON\) setup.py build/g' Makefile > M
RUN mv M Makefile

COPY setup.py src/lib389/setup.py

RUN rm -fr /.cargo/.package-cache /root/.cargo/.package-cache
RUN make && make lib389 && make install && make lib389-install

FROM alpine:${OS_VERSION}

LABEL description="389 Directory Server. The enterprise-class Open Source LDAP server for Linux."
LABEL maintainer="Thorsten Ludewig <t.ludewig@gmail.com>"
LABEL org.opencontainers.image.authors="Thorsten Ludewig <t.ludewig@gmail.com>"
LABEL org.opencontainers.image.source="https://github.com/thorsten-l/389ds-alpine"
LABEL org.opencontainers.image.description="389 Directory Server. The enterprise-class Open Source LDAP server for Linux."
LABEL version=${DS_VERSION}

RUN apk add openssl cracklib libevent nspr nss openldap db icu \
            net-snmp krb5 pcre nss-tools openssl linux-pam python3

COPY --from=builder /opt /opt
COPY --from=builder /usr/sbin/ds* /usr/sbin/
COPY --from=builder /usr/lib/python3.9 /usr/lib/python3.9
COPY --from=builder /usr/libexec/dirsrv /usr/libexec/dirsrv

RUN mkdir -p /data /data/config /data/run /opt/dirsrv/var/run/dirsrv; \
    ln -s /data/run /opt/dirsrv/var/run/dirsrv; \
    ln -s /data/ssca /opt/dirsrv/etc/dirsrv/ssca; \
    ln -s /data/config /opt/dirsrv/etc/dirsrv/slapd-localhost

HEALTHCHECK --start-period=5m --timeout=5s --interval=5s --retries=2 \
    CMD /usr/libexec/dirsrv/dscontainer -H

WORKDIR /data
VOLUME /data

EXPOSE 3389 3636

CMD [ "/usr/libexec/dirsrv/dscontainer", "-r" ]
