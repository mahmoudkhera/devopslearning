FROM python:3.11-alpine
WORKDIR /app
COPY front/src/billing.html /app/index.html
EXPOSE 8080
CMD ["python3", "-m", "http.server", "8080"]