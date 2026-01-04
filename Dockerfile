# ============================
# Prepare lint Environment
FROM --platform=$TARGETPLATFORM node:22-alpine AS lint-env
WORKDIR /app
COPY . .
RUN npm install --loglevel verbose
RUN npm run build
RUN npm run lint

# ============================
# Prepare Build Environment
FROM --platform=$TARGETPLATFORM python:3.11 AS python-env
WORKDIR /app
COPY --from=lint-env /app .
RUN apk add --no-cache weasyprint fonts-noto-cjk wget unzip
RUN rm node_modules -rf && pip install -r requirements.txt
RUN mkdocs build

# ============================
# Prepare Runtime Environment
FROM --platform=$TARGETPLATFORM nginx:1-alpine
COPY --from=python-env /app/site /usr/share/nginx/html

LABEL org.opencontainers.image.source="https://github.com/Anduin2017/HowToCook"