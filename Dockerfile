# Use the official image as a parent image
FROM node:7

# Set the user name (or UID) and optionally the user group (or GID) to use when running the image and subsequent commands
# USER nodeapp

# Set the working directory
WORKDIR /usr/src/app

# Copy the file from your host to your current location
COPY app.js .

# Define Environment Variable
ENV APP_VER v01.11

# Run the command inside your image filesystem
# RUN npm install

# Inform Docker that the container is listening on the specified port at runtime.
EXPOSE 8080

# Run the specified command within the container.
CMD node app.js