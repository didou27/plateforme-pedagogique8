FROM node:22-alpine

WORKDIR /app
COPY app ./app
COPY server.js ./
RUN mkdir -p /app/storage/uploads

ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=3000
EXPOSE 3000

CMD ["node", "server.js"]