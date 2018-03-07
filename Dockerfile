FROM alpine:3.6

#Base settings

#Install ZeroNet
RUN apk --update upgrade \
  && apk --no-cache --no-progress add musl-dev gcc python python-dev py2-pip tor \
  && pip install gevent msgpack \
  && apk del musl-dev gcc python-dev py2-pip \
  && rm -rf /var/cache/apk/* /tmp/* /var/tmp/* \
  && echo "ControlPort 9051" >> /etc/tor/torrc \
  && echo "CookieAuthentication 1" >> /etc/tor/torrc

RUN mkdir -p /zeronet \
  && adduser -D -h /zeronet -u 1000 -G users zeronet \
  && chown zeronet:users /zeronet

VOLUME /var/log/zeronet 
RUN chown zeronet:users /var/log/zeronet

#Add Zeronet source
COPY . /zeronet


#Control if Tor proxy is started
ENV ENABLE_TOR false

WORKDIR /zeronet
USER zeronet
#Set upstart command
CMD (! ${ENABLE_TOR} || tor&) && python zeronet.py --ui_ip 0.0.0.0

#Expose ports
EXPOSE 43110 15441
