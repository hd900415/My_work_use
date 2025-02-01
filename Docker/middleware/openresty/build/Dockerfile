ARG RESTY_IMAGE_BASE="rockylinux"
ARG RESTY_IMAGE_TAG="9.3"

FROM ${RESTY_IMAGE_BASE}:${RESTY_IMAGE_TAG}

RUN dnf -y install epel-release \
    && dnf -y update \
    && dnf -y install gcc \
       pcre-devel \
       make \
       zlib-devel \
       openssl-devel \
       libxml2-devel \
       libxslt-devel \
       gd-devel  \
       luajit \
       luajit-devel \
       perl-devel \
       perl \
       perl-ExtUtils-Embed \
       git \
       wget \
    && dnf -y install  https://github.com/maxmind/geoipupdate/releases/download/v4.8.0/geoipupdate_4.8.0_linux_amd64.rpm  \
    && dnf clean all \
    && rm -rf /var/cache/dnf \
    && mkdir -p /data/openresty \
    && cd /data/openresty \
    && git clone https://github.com/TravelEngineers/ngx_http_geoip2_module \
    && wget https://github.com/maxmind/libmaxminddb/releases/download/1.4.2/libmaxminddb-1.4.2.tar.gz \
    && tar xf libmaxminddb-1.4.2.tar.gz \
    && cd libmaxminddb-1.4.2  \
    && ./configure \
    && make \
    && make check \
    && make install \
    && echo /usr/local/lib >> /etc/ld.so.conf.d/local.conf \
    && ldconfig \
    && cd /data/openresty \
    && echo "AccountID 643975"> /etc/GeoIP.conf \
    && echo "LicenseKey aZ5RobhhHTV03d08" >> /etc/GeoIP.conf \
    && echo "EditionIDs GeoLite2-ASN GeoLite2-City GeoLite2-Country" >> /etc/GeoIP.conf \
    && geoipupdate  \
    && cd /data/openresty \
    && wget https://github.com/maxmind/geoip-api-c/releases/download/v1.6.12/GeoIP-1.6.12.tar.gz \
    && tar xf GeoIP-1.6.12.tar.gz \
    && cd GeoIP-1.6.12 \
    && ./configure \
    && make \
    && make install \
    && ldconfig -p \
    && cd /data/openresty \
    && wget https://openresty.org/download/openresty-1.25.3.1.tar.gz \
    && tar xf openresty-1.25.3.1.tar.gz \
    && cd openresty-1.25.3.1 \
    && ./configure \
        --prefix=/usr/local/openresty \
        --with-threads \
        --with-file-aio \
        --with-http_ssl_module \
        --with-http_v2_module \
        --with-http_realip_module \
        --with-http_addition_module \
        --with-http_xslt_module=dynamic \
        --with-http_image_filter_module=dynamic \
        --with-http_geoip_module=dynamic \
        --with-http_sub_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_mp4_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_auth_request_module \
        --with-http_random_index_module \
        --with-http_secure_link_module \
        --with-http_degradation_module \
        --with-http_slice_module \
        --with-http_stub_status_module \
        --with-stream=dynamic \
        --with-stream_ssl_module \
        --with-stream_realip_module \
        --with-stream_geoip_module=dynamic \
        --with-stream_ssl_preread_module \
        --add-module=../ngx_http_geoip2_module \
    && gmake \
    && gmake install \
    && cd  /usr/local/openresty/nginx/conf/ \
    && git clone https://github.com/unixhot/waf.git \
    && mv waf waf1 \
    && mv waf1/waf ./ \
    && rm -rf waf1 \
    && mkdir conf.d ssl vhost \
    && ln -s /usr/local/openresty/bin/openresty   /usr/bin/openresty \
    && ln -s /usr/local/openresty/lualib /usr/local/lib/lua \
    && ln -s /usr/local/openresty/lualib/resty /usr/local/openresty/nginx/conf/waf/resty \
    && rm -rf /data/openresty 
  

ENV PATH=$PATH:/usr/local/openresty/luajit/bin:/usr/local/openresty/nginx/sbin:/usr/local/openresty/bin

COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY Geoip2.conf /usr/local/openresty/nginx/conf/conf.d/Geoip2.conf
COPY default.conf /usr/local/openresty/nginx/conf/vhost/default.conf
COPY proxy.conf /usr/local/openresty/nginx/conf/conf.d/proxy.conf 
COPY limitip.conf /usr/local/openresty/nginx/conf/conf.d/limitip.conf 
COPY proxyCache.conf  /usr/local/openresty/nginx/conf/conf.d/proxyCache.conf 



CMD ["/usr/local/openresty/bin/openresty", "-g", "daemon off;"]

# Use SIGQUIT instead of default SIGTERM to cleanly drain requests
# See https://github.com/openresty/docker-openresty/blob/master/README.md#tips--pitfalls
STOPSIGNAL SIGQUIT

