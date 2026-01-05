# ============================
# Prepare lint Environment
FROM node:22-alpine AS lint-env
WORKDIR /app
COPY . .
RUN npm config set registry https://registry.npmmirror.com/
RUN npm install --loglevel verbose
RUN npm run build
RUN npm run lint

# ============================
# Prepare Build Environment
FROM python:3.11-alpine AS python-env
WORKDIR /app
COPY --from=lint-env /app .
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories
RUN apk add --no-cache gcc g++ musl-dev libffi-dev cairo-dev pango-dev gdk-pixbuf-dev jpeg-dev font-noto-cjk wget unzip
RUN pip install --no-cache-dir -i https://pypi.tuna.tsinghua.edu.cn/simple/ --prefer-binary weasyprint
RUN pip install --no-cache-dir -i https://pypi.tuna.tsinghua.edu.cn/simple/ --prefer-binary mkdocs-material mkdocs-same-dir mkdocs-minify-plugin
RUN pip install --no-cache-dir -i https://pypi.tuna.tsinghua.edu.cn/simple/ --prefer-binary mkdocs-with-pdf
RUN rm node_modules -rf
RUN mkdocs build

# ============================
# Prepare Runtime Environment
FROM nginx:1-alpine
COPY --from=python-env /app/site /usr/share/nginx/html

LABEL org.opencontainers.image.source="https://github.com/Anduin2017/HowToCook"