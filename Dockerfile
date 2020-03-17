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

# Define Environment Variables
ENV IMAGE_VERSION green

# Define a variable that can be passed at build-time to the builder with the docker build --build-arg API_VER=value
ARG API_VER
# or with a hard-coded default value
ARG API_VER=v1

# Consume build-time variable
ENV API_VERSION $API_VER
#RUN echo "This is my API version: $API_VER"

# Inform Docker that the container is listening on the specified port at runtime.
EXPOSE 8080

# Run the specified command within the container.
CMD node app.js