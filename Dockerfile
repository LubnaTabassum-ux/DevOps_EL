# Stage 1: The Builder (Uses a full environment for building the artifact)
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build # Example: If you have a build step

# Stage 2: The Final, Minimal Image (Only required runtime and artifact)
FROM node:20-slim
WORKDIR /app
# Best Practice: Run as a non-root user (Unit I)
RUN groupadd -r appuser && useradd -r -g appuser appuser
USER appuser
# Copy only the compiled artifact from the builder stage
COPY --from=builder /app/dist /app/dist # Adjust path based on your app's build output
EXPOSE 8080
CMD ["node", "/app/dist/server.js"]
