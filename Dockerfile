# ---------- Build ----------
FROM node:20-alpine AS build
WORKDIR /app

# Copia manifests (inclui lock se existir)
COPY package*.json* ./
COPY pnpm-lock.yaml* ./

# Instala dependências conforme lock disponível
RUN if [ -f pnpm-lock.yaml ]; then \
      corepack enable && corepack prepare pnpm@latest --activate && pnpm install --frozen-lockfile; \
    elif [ -f package-lock.json ]; then \
      npm ci; \
    else \
      npm install; \
    fi

# Copia o restante e builda
COPY . .
RUN if [ -f pnpm-lock.yaml ]; then pnpm run build; else npm run build; fi

# ---------- Runtime ----------
FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist/ /usr/share/nginx/html/
EXPOSE 80
