FROM wordpress:php8.1-fpm
MAINTAINER Prime-Host <info@nordloh-webdesign.de>

ARG DEBIAN_FRONTEND=noninteractive

# install nginx 
RUN mkdir /var/run/sshd \
 && apt-get update \
 && apt-get install -y cron python-setuptools wget curl git nano vim sudo unzip \ 
    openssh-server openssl zsh supervisor mariadb-client

RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh || true \
 && cp /root/.oh-my-zsh/themes/bira.zsh-theme /root/.oh-my-zsh/themes/prime-host.zsh-theme \
 && sed -i 's/%m/%M/g' /root/.oh-my-zsh/themes/prime-host.zsh-theme \
 && sed -i s:/root/.oh-my-zsh:\$HOME/.oh-my-zsh:g /root/.zshrc \
 && sed -i 's/robbyrussell/prime-host/g' /root/.zshrc \
 && echo "DISABLE_UPDATE_PROMPT=true" >> /root/.zshrc \
 && echo "set encoding=utf-8" >> /root/.vimrc \
 && echo "set fileencoding=utf-8" >> /root/.vimrc \
 && cp -r /root/.oh-my-zsh /etc/skel/. \
 && cp /root/.zshrc /etc/skel/. \
 && cp /root/.vimrc /etc/skel/. \
 && mkdir /root/container-scripts /root/container-scripts/prime-host /root/container-scripts/custom \
 && apt-get --purge autoremove -y \
 && echo "cd /var/www/html" >> /root/.zshrc

# nginx site conf, Supervisor Config, Create www folder and index.php, Startup Script
ADD ./php-values.ini /usr/local/etc/php/conf.d/php-values.ini
ADD ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD ./wordpress-start.sh /bin/prime-host/wordpress-start.sh

CMD ["/bin/bash", "/bin/prime-host/wordpress-start.sh"]
