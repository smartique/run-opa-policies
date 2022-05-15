FROM alpine:3.10
RUN apk update && apk add --no-cache jq curl

# Download OPA Binary
RUN curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64 && \
    chmod 755 ./opa && \
    cp ./opa /usr/local/bin
    
# Copy Policies
COPY policies/* /
COPY Makefile /Makefile
COPY entrypoint.sh /entrypoint.sh


ENTRYPOINT ["/entrypoint.sh"]