# =============================================================================
# MERN Frontend Dockerfile - Multi-Stage Build
# React uygulamasını build edip Nginx ile serve eder
# =============================================================================

# ---------------------------------------------------------------------------
# Stage 1: Build - React uygulamasını derle
# ---------------------------------------------------------------------------
FROM node:18-alpine AS builder

# Çalışma dizinini ayarla
WORKDIR /app

# Önce sadece dependency dosyalarını kopyala (Docker cache optimizasyonu)
# Bu sayede sadece dependency değiştiğinde npm install tekrar çalışır
COPY package.json package-lock.json ./

# Sadece production + dev dependencies yükle (build için dev deps gerekli)
RUN npm ci

# Kaynak kodu kopyala
COPY . .

# React uygulamasını production için build et
RUN npm run build

# ---------------------------------------------------------------------------
# Stage 2: Production - Nginx ile static dosyaları serve et
# ---------------------------------------------------------------------------
FROM nginx:1.25-alpine AS production

# Güvenlik: Nginx versiyonunu gizle
# Nginx varsayılan config dosyasını kaldır
RUN rm /etc/nginx/conf.d/default.conf

# Özel Nginx konfigürasyon dosyasını kopyala
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Build çıktısını Nginx'in serve edeceği dizine kopyala
COPY --from=builder /app/build /usr/share/nginx/html

# Container'ın dinleyeceği port
EXPOSE 80

# Nginx'i foreground modda çalıştır (container'ın kapanmaması için)
CMD ["nginx", "-g", "daemon off;"]
