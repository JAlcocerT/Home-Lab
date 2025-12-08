# Use the official Node.js image as the base
FROM node:latest 
#20.15.0 # https://hub.docker.com/_/node/tags

# Install Git and nano
RUN apt-get update && \
    apt-get install -y git nano

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash

# Install additional packages using npm
RUN npm install -g npm@latest
RUN npm install -g pnpm
#RUN npm install -g yarn

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json (if available) to the working directory
#COPY package*.json ./

# Install project dependencies using npm
#RUN npm install

# Copy the rest of the project files to the working directory
#COPY . .

# Expose the desired port (replace 3000 with your app's port if different)
EXPOSE 3000

# Specify the command to run your application
#CMD ["npm", "start"]
# Keep the container running and wait for a command
CMD ["tail", "-f", "/dev/null"]


#docker build -t node_ssg .
#podman build -t node_ssg .

#docker run -d --name=node_ssg -p 3000:3000 node_ssg 
#podman run -d --name=node_ssg -p 3005:3000 node_ssg 

#docker exec -it node_ssg /bin/bash
#podman exec -it node_ssg /bin/bash


#echo "Node: $(node --version) | npm: $(npm --version) | Yarn: $(yarn --version) | Bun: $(bun --version)"
#podman exec -it loving_babbage /bin/bash -c "echo NPM: \$(npm --version)"