# Base stage
FROM node:18-alpine AS base
RUN npm i -g pnpm @nestjs/cli

# Development stage
FROM base AS development
WORKDIR /app
COPY backend ./
CMD pnpm install && pnpm run start:dev

# Dependencies stage
FROM base AS dependencies
WORKDIR /app
COPY backend/package.json backend/pnpm-lock.yaml ./
RUN pnpm install

# Build stage
FROM base AS build
WORKDIR /app
COPY backend .
COPY --from=dependencies /app/node_modules ./node_modules
RUN pnpm run build
RUN pnpm prune --prod

# Production stage
FROM base AS production
WORKDIR /app
COPY --from=build /app/dist/ ./dist/
COPY --from=build /app/node_modules ./node_modules
CMD ["node", "dist/main"]
