# Build stage
FROM node:18-alpine as builder

WORKDIR /app

# Install build dependencies for canvas
RUN apk add --no-cache \
    build-base \
    g++ \
    cairo-dev \
    jpeg-dev \
    pango-dev \
    giflib-dev \
    python3 \
    pixman-dev \
    pkgconfig \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev

# Copy package files
COPY ./package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY ./ ./

# Build TypeScript code
RUN npm run build

# Production stage
FROM node:18-alpine

WORKDIR /app

# Install runtime dependencies for canvas
RUN apk add --no-cache \
    build-base \
    g++ \
    cairo-dev \
    jpeg-dev \
    pango-dev \
    giflib-dev \
    python3 \
    pixman-dev \
    pkgconfig \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev

# Copy package files
COPY ./package*.json ./

# Install production dependencies only
RUN npm install --production

# Copy built files from builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/static ./static
COPY --from=builder /app/images ./images

# Copy server.js
COPY ./server.js .

# Create upload directory if specified in env
RUN mkdir -p uploads

# Expose port (should match your env PORT)
EXPOSE 3000

# Start the server
CMD ["npm", "start"]