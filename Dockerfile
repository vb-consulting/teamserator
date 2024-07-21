FROM node:20-alpine AS builder

WORKDIR /app
COPY . ./
RUN npm install --omit=dev
RUN npm run build

FROM vbilopav/npgsqlrest:v1.4.0 AS teamserator

WORKDIR /app
COPY --from=builder /app/wwwroot ./wwwroot

COPY ./backend/cfg/appsettings.json ./
COPY ./backend/cfg/appsettings-server.json ./

EXPOSE 5000

ENTRYPOINT [ "npgsqlrest", "./appsettings.json", "./appsettings-server.json" ]
