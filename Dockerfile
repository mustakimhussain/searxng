FROM searxng/searxng:latest

COPY settings.yml /etc/searxng/settings.yml
COPY limiter.toml /etc/searxng/limiter.toml

EXPOSE 8080
