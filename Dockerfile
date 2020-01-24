FROM ruby:2.5.0

RUN apt-get update && \
    apt-get install -y net-tools

# Install depends.
RUN apt-get install -y x11vnc xvfb fluxbox wget
# # Install Chrome
# RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
#     && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list

# RUN apt-get update && apt-get -y install google-chrome-stable



RUN apt-get update && apt-get install -y firefox-esr wget

ADD . /crawler
WORKDIR /crawler
RUN gem install bundler
RUN bundle install

# Install geckodriver
RUN wget https://github.com/mozilla/geckodriver/releases/download/v0.24.0/geckodriver-v0.24.0-linux64.tar.gz
RUN tar -xvzf geckodriver-v0.24.0-linux64.tar.gz
RUN chmod +x geckodriver
ENV PATH=$PATH:./
RUN echo $PATH

CMD ["ruby", "crawler.rb"]
