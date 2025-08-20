#!/bin/sh -e
# NTFY_TOPIC の設定は必須
if [ -z "$NTFY_TOPIC" ]; then
  echo "🚨Error: NTFY_TOPIC is not set."
  exit 1
fi

cp ./.gitconfig /root/
cp ./.gitignore /root/

cp -r ./.claude /root/
chmod a+x -R ~/.claude/scripts/
echo "export NTFY_TOPIC=$NTFY_TOPIC" >> /root/.bashrc

# install tools
mkdir -p ~/tools
cp -r ./tools ~/
chmod +x ~/tools/*
echo "export PATH=$PATH:/root/tools" >> /root/.bashrc

