FROM ruby:2.5.0

RUN sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list
RUN sed -i 's/security.debian.org/mirrors.tuna.tsinghua.edu.cn\/debian-security/g' /etc/apt/sources.list
RUN apt-get update
RUN apt-get update -qq && apt-get install -y build-essential python3 python3-pip phantomjs && apt-get install -y xvfb nodejs mysql-server mysql-client sudo

COPY a.sh /a.sh
COPY run.sh /run.sh
RUN chmod 777 /a.sh  && /a.sh && rm -rf a.sh
RUN mkdir /rails && mkdir /home/rails
ENV RAILS_ROOT /rails
ADD project.tar.gz /rails
COPY bot.py /bot.py
WORKDIR $RAILS_ROOT
RUN useradd rails
RUN echo "rails:rails" | chpasswd
RUN chown rails /rails && chown rails:rails /home/rails && chown rails /bot.py
USER rails
RUN pip3 install selenium==2.53.6 && pip3 install requests==2.18.4
RUN gem install bundler
RUN bundle install --path vendor
USER root
RUN usermod -a -G sudo rails
RUN echo "hctf{8f4c57063ddb7b106e03e25f7d1bb813}" > /flag && chmod 444 /flag 

#CMD ["/bin/bash"]
ENTRYPOINT ["/run.sh"]
