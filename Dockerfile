# Stage 1: The Builder
FROM node:20-alpine AS builder
WORKDIR /app
COPY src/package*.json ./
RUN npm install
COPY src/ .

# Stage 2: The Final, Minimal Image
FROM node:20-alpine
WORKDIR /app

# Alpine specific user creation
RUN addgroup -S appuser && adduser -S appuser -G appuser
USER appuser

# Copy from builder
COPY --from=builder /app /app

EXPOSE 8080
CMD ["node", "index.js"]
