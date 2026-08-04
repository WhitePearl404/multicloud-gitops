# Minimal placeholder backend image.
# Uses the official `redis` npm client -- see package-lock.json for the
# exact pinned, tested version.
FROM node:22-alpine

WORKDIR /app

COPY package.json package-lock.json ./
# --omit=dev: there are no dev dependencies here, but this keeps the
# image lean if any get added later. --ci uses the lockfile exactly,
# no surprise version drift between local dev and the built image.
RUN npm ci --omit=dev

COPY server.js ./

# node:22-alpine ships a built-in, unprivileged "node" user at uid 1000,
# matching securityContext.runAsUser: 1000 in
# k8s-manifests/backend/deployment.yaml.
USER node

EXPOSE 8080
ENV PORT=8080

CMD ["node", "server.js"]
