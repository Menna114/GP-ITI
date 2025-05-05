FROM node:18

# Install MariaDB client (optional, if you need it)
RUN apt update && \
    apt install -y mariadb-client

# Create app directory
WORKDIR /nodeapp

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy the rest of the application
COPY . .

# Start the app using server.js
CMD ["node", "server.js"]
