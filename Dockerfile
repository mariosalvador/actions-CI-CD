FROM node:22-alpine AS build

WORKDIR /usr/src/app

RUN corepack enable

COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

COPY . .
RUN pnpm run build

FROM node:22-alpine AS production

ENV NODE_ENV=production
ENV PORT=3000

WORKDIR /usr/src/app

RUN corepack enable
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --prod --frozen-lockfile

COPY --from=build --chown=node:node /usr/src/app/dist ./dist

USER node

EXPOSE 3000

CMD ["node", "dist/main.js"]
