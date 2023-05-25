FROM node:18-bullseye As development

WORKDIR /usr/src/app
#
# COPY --chown=node:node backend/package*.json ./
# COPY --chown=node:node backend/src ./
# COPY --chown=node:node backend/.env ./
# COPY --chown=node:node backend/firebase.json ./
# COPY --chown=node:node backend/nest-cli.json ./
# COPY --chown=node:node backend/tsconfig*.json ./
# COPY --chown=node:node backend/dist ./
# COPY --chown=node:node . .
#
# # RUN npm ci
# RUN npm ci --include=dev
# # workaround for sharp
# # RUN npm install --arch=arm64 --platform=linux --libc=musl sharp
#
COPY --chown=node:node . .

USER node


FROM node:18-bullseye As build

WORKDIR /usr/src/app

COPY --chown=node:node package*.json ./

COPY --chown=node:node --from=development /usr/src/app/node_modules ./node_modules

COPY --chown=node:node . .

RUN npm run build

ENV NODE_ENV production

RUN npm ci --only=production && npm cache clean --force

USER node


FROM node:18-bullseye As production

COPY --chown=node:node --from=build /usr/src/app/node_modules ./node_modules
COPY --chown=node:node --from=build /usr/src/app/dist ./dist

CMD [ "node", "dist/main.js" ]
