# Use the official image as a parent image
FROM node:7

# Create username with sudo rights for demo purposes
RUN useradd --shell /bin/bash --system -m -G sudo nodejsapp

# Set the user name (or UID) and optionally the user group (or GID)
USER nodejsapp

# Set the working directory
WORKDIR /usr/src/app

# Copy the file from your host to your current location
COPY app.js .

# Define Environment Variable. Can be changed at run-time
ENV IMAGE_VERSION green

# Define a variable. Can be changed at build-time and can have a hard-coded default value
ARG API_VER=v1

# Consume build-time variable
ENV API_VERSION $API_VER

# Inform Docker that the container is listening on the specified port at run-time
EXPOSE 8080

# Run command to start application at run-time
CMD node app.js