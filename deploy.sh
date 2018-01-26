#!/usr/bin/env bash

rm -rf _site

jekyll clean

JEKYLL_ENV=production 

jekyll build

# -----------------------------------------------------------
# rsync_deploy
# -----------------------------------------------------------

# localjekyll="/home/roadsheep/Jekyll-Blog"  # 本地jekyll根目录
# remotewebroot="/var/www/louisun.me/jekyll" # 远程根目录
# instancehost="www.louisun.me"              # 域名/ip
# sshuser="root"                             # 主机用户
# sshport="22"                               # ssh 端口
# sshidentity="~/.ssh/id_rsa"                # 私钥路径

# # Execution

# cd $localjekyll

# rm -rf _site

# jekyll clean

# jekyll build

# echo "rsync to SSH host $instancehost ..."

# rsync -vrh -e "ssh" --exclude ".*" --delete-after $localjekyll/_site/ $sshuser@$instancehost:$remotewebroot

# echo "SSH connection closed. Done. Committed."
