# =============================================================================
# Python ETL Dockerfile
# Hafif Python image ile ETL script'ini çalıştırır
# =============================================================================

FROM python:3.12-slim

# Güvenlik: Non-root kullanıcı oluştur
RUN groupadd -r etl && useradd -r -g etl -d /app -s /sbin/nologin etl

# Çalışma dizini
WORKDIR /app

# Bağımlılıkları yükle
# requirements.txt olmadığı için doğrudan pip install kullanılır
RUN pip install --no-cache-dir requests

# ETL script'ini kopyala
COPY ETL.py .

# Dosya sahipliğini non-root kullanıcıya ata
RUN chown -R etl:etl /app

# Güvenlik: Non-root user ile çalıştır
USER etl

# ETL script'ini çalıştır
CMD ["python", "ETL.py"]
