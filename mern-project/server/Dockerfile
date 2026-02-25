# =============================================================================
# MERN Backend Dockerfile - Node.js/Express API Server
# Optimize edilmiş, güvenli production image
# =============================================================================

FROM node:18-alpine

# Güvenlik: dumb-init ile process yönetimi
# Node.js PID 1 olarak çalıştığında sinyal yönetimi sorunlu olabilir
# dumb-init bu sorunu çözer (SIGTERM, SIGINT düzgün handle edilir)
RUN apk add --no-cache dumb-init

# Çalışma dizinini oluştur ve ayarla
WORKDIR /app

# Dependency dosyalarını kopyala (Docker cache optimizasyonu)
COPY package.json package-lock.json ./

# Sadece production dependency'leri yükle
# --omit=dev: devDependencies hariç tutulur (imaj boyutu küçülür)
RUN npm ci --omit=dev

# Uygulama kaynak kodunu kopyala
COPY . .

# Güvenlik: Non-root user ile çalıştır
# Alpine Node.js imajında 'node' kullanıcısı zaten mevcut
USER node

# Container'ın dinleyeceği port
EXPOSE 5050

# Ortam değişkeni: production modu
ENV NODE_ENV=production

# Healthcheck: Container sağlık kontrolü
# Her 30 saniyede bir /healthcheck endpoint'ini kontrol eder
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:5050/healthcheck || exit 1

# dumb-init ile Node.js uygulamasını başlat
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "server.mjs"]
