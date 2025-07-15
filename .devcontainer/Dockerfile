#### For installing tools
FROM ubuntu:latest as builder

RUN apt update && apt upgrade -y
RUN apt install -y wget gpg curl gnupg software-properties-common unzip \
    lsb-release

## Install terraform
# ref: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli
RUN wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
RUN gpg --no-default-keyring \
    --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    --fingerprint
RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    tee /etc/apt/sources.list.d/hashicorp.list
RUN apt update
RUN apt install -y terraform

## Install tools for Terraform
# tflint
# ref: https://github.com/terraform-linters/tflint
RUN curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
# terraform-docs
# ref: https://terraform-docs.io/user-guide/installation/#pre-compiled-binary
RUN curl -sSLo ./terraform-docs.tar.gz https://terraform-docs.io/dl/v0.19.0/terraform-docs-v0.19.0-$(uname)-amd64.tar.gz \
    && tar -xzf terraform-docs.tar.gz \
    && chmod +x terraform-docs \
    && mv terraform-docs /usr/local/bin/terraform-docs

## Install n(package manager for Node.js and npm)
RUN apt install -y nodejs npm
RUN npm install -g n

## Install Docker
RUN apt install -y apt-transport-https ca-certificates gnupg-agent software-properties-common
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - \
    && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" -y \
    && apt update && apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin


#### main
FROM ubuntu:latest

RUN apt update && apt upgrade -y
RUN apt install -y git vim curl zip unzip

## Install uv
# ref: https://docs.astral.sh/uv/getting-started/installation/
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    echo "source $HOME/.local/bin/env" << ~/.bashrc && \
    echo 'eval "$(uv generate-shell-completion bash)"' >> ~/.bashrc

## Install Terraform
COPY --from=builder /usr/bin/terraform /usr/bin/
COPY --from=builder /usr/local/bin/tflint /usr/local/bin/
COPY --from=builder /usr/local/bin/terraform-docs /usr/local/bin/

## Install n(package manager for Node.js and npm)
COPY --from=builder /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s /usr/local/lib/node_modules/n/bin/n /usr/local/bin/n && n stable

## Change locale to Japan
RUN apt install -y language-pack-ja && \
    locale-gen ja_JP.UTF-8 && \
    echo "export LANG=ja_JP.UTF-8" >> ~/.bashrc

## Install AWSCLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -f awscli.zip && rm -r ./aws/

## Install Docker
COPY --from=builder /usr/bin/docker /usr/bin/
COPY --from=builder /usr/libexec/docker/cli-plugins/docker-compose /usr/libexec/docker/cli-plugins/docker-compose

## Install git-secrets
RUN apt install -y build-essential
RUN git clone https://github.com/awslabs/git-secrets.git \
    && cd git-secrets \
    && make install \
    && git secrets --register-aws --global \
    && cd .. && rm -rf git-secrets

## Install Claude Code
RUN npm install -g @anthropic-ai/claude-code
