FROM node:lts
WORKDIR /app

ENV DEBIAN_FRONTEND=noninteractive

# ADJUST TIMEZONE
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# SET ENV TO NOT DOWNLOAD CHROMIUM
# ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
# RUN npm config set PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

# DOWNLOAD CURL, FFMPEG AND EXTRA FONTS FOR CANVAS THEN CLEAN EVERYTHING
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y \
    curl \
    ffmpeg \
    git \
    cabextract \
    apt-transport-https \
    ca-certificates \
    gnupg \
    libmspack0 \
    xfonts-utils \
    --no-install-recommends

RUN curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update && apt-get install -y \
    google-chrome-stable \
    --no-install-recommends

RUN wget http://ftp.de.debian.org/debian/pool/contrib/m/msttcorefonts/ttf-mscorefonts-installer_3.7_all.deb \
    && dpkg -i ttf-mscorefonts-installer_3.7_all.deb \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# SETUP ENVIRONMENT TO USE CHROME - IT WON'T RUN FROM THE ROOT USER.
RUN groupadd chrome && useradd -g chrome -s /bin/bash -G audio,video chrome \
    && mkdir -p /home/chrome && chown -R chrome:chrome /home/chrome

# COPY FILES, THEN SET PERMISSIONS TO NEW CHROME USER
COPY . .
RUN chown -R chrome:chrome /app

# SET CHROME USER
USER chrome

CMD ["/bin/bash"]