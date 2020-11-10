# Use the official image as a parent image
FROM node:12.17-alpine3.11

# Create user and group
RUN addgroup nodejsapp \
&& adduser -D --shell /bin/ash -G nodejsapp nodejsapp \
&& mkdir -p /app/data \
&& chown nodejsapp:nodejsapp /app/data

# Set the user name (or UID) and optionally the user group (or GID)
USER nodejsapp

# Set the working directory
WORKDIR /usr/src/app

# Copy the file from your host to your current location
# COPY app.js .
ADD --chown=nodejsapp:nodejsapp app.js .
ADD --chown=nodejsapp:nodejsapp app.test.js .
ADD --chown=nodejsapp:nodejsapp package.json .

# Define Environment Variable. Can be changed at run-time
ENV IMAGE_VERSION blue

# Define a variable. Can be changed at build-time and can have a hard-coded default value
ARG API_VER=v1

# Consume build-time variable
ENV API_VERSION $API_VER

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

ENTRYPOINT [ "npm"]
CMD ["start"]
