# Stage 1: Build the Angular application
FROM node:18 as build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .

# Build with specified environment
# Build with the specified environment or default to production
ARG ENVIRONMENT=production
RUN if [ "$ENVIRONMENT" = "test" ]; then \
      npm run build; \
    else \
      npm run build -- --configuration=${ENVIRONMENT}; \
    fi

# Stage 2: Serve the app with Nginx
FROM nginx:alpine
# Copy the Angular app to the correct location - using the Angular 17 browser directory
COPY --from=build /app/dist/ditest/browser/ /usr/share/nginx/html/
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]