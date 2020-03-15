# Use the official image as a parent image
FROM node:7

# Create username with sudo rights for demo purposes
RUN useradd --shell /bin/bash --system -m -G sudo nodejsapp

# Set the user name (or UID) and optionally the user group (or GID) to use when running the image and subsequent commands
USER nodejsapp

# Set the working directory
WORKDIR /usr/src/app

# Copy the file from your host to your current location
COPY app.js .

# Define Environment Variable
ENV APP_VER v01.11

# Inform Docker that the container is listening on the specified port at runtime.
EXPOSE 8080

# Run the specified command within the container.
CMD node app.js