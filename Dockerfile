FROM alpine:3.10
RUN apk update && apk add --no-cache jq curl

# Download OPA Binary
RUN curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64 && \
    chmod 755 ./opa && \
    cp ./opa /usr/local/bin

# Install Terraform
RUN wget https://releases.hashicorp.com/terraform/1.1.2/terraform_1.1.2_linux_amd64.zip && \
    unzip terraform_1.1.2_linux_amd64.zip && rm terraform_1.1.2_linux_amd64.zip && \
    mv terraform /usr/bin/terraform

# Copy Policies
COPY policies/* /
COPY Makefile /Makefile
COPY entrypoint.sh /entrypoint.sh


ENTRYPOINT ["/entrypoint.sh"]