# Minimal placeholder frontend image.
# Zero runtime dependencies -- server.js only uses Node's built-ins.
FROM node:22-alpine

# Matches securityContext.runAsUser: 101 in k8s-manifests/frontend/deployment.yaml.
RUN addgroup -g 101 -S appgroup \
  && adduser -S -D -u 101 -G appgroup appuser

WORKDIR /app

COPY package.json ./
COPY server.js ./

USER appuser

EXPOSE 8080
ENV PORT=8080

CMD ["node", "server.js"]
