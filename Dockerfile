# Use the latest LTS Node.js Alpine image
FROM node:20-alpine as base

# Set working directory
WORKDIR /usr/src/app

# Copy package files and install dependencies
# Copy both package.json and package-lock.json (if present) for better caching
COPY package.json package-lock.json* ./
RUN npm ci --omit=dev

# Copy the file from your host to your current location
COPY app.js ./
COPY app.test.js ./

# Create user and group, set permissions for data directory
RUN addgroup -S nodejsapp \
    && adduser -S -G nodejsapp nodejsapp \
    && mkdir -p /app/data \
    && chown -R nodejsapp:nodejsapp /app/data

# Set the user name (or UID) and optionally the user group (or GID)
USER nodejsapp

# Define Environment Variable. Can be changed at run-time
ENV IMAGE_VERSION=blue

# Define a variable. Can be changed at build-time and can have a hard-coded default value
ARG API_VER=v1

# Consume build-time variable
ENV API_VERSION=$API_VER

# Inform Docker that the container is listening on the specified port at run-time
EXPOSE 8080

## 1st method
# ENTRYPOINT should be defined when using the container as an executable.
# ENTRYPOINT [ "node"]
 
# CMD should be used as a way of defining default arguments for an ENTRYPOINT command
# CMD ["app.js"]
 
## 2nd method
# Run command to start application at run-time
# CMD node app.js

ENTRYPOINT ["npm"]
CMD ["start"]
