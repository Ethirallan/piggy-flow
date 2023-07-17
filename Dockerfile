# Development stage
FROM node:14-alpine AS development

WORKDIR /app

COPY backend/package*.json ./

RUN npm i

COPY backend .

CMD ["npm", "run", "start:dev"]

# Build stage
FROM development AS build

RUN npm run build

# Production stage
FROM node:14-alpine AS production

WORKDIR /app

COPY backend/package*.json ./

RUN npm i --only=production

COPY --from=build /app/dist ./dist

CMD ["node", "dist/main"]