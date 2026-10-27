# Backend Dockerfile for Express App
# Start from an image that already has Node.js installed (alpine = small Linux)
FROM node:18-alpine

# Everything inside the image happens in /app
WORKDIR /app

# Copy only the package files first, so Docker can cache the npm install step
COPY package*.json ./

# Install express, cors and randomcolor inside the image (runs at BUILD time)
RUN npm install

# Copy in the rest of the backend code
COPY . .

# Documents the port the app listens on (does not publish it)
EXPOSE 5000

# Entrypoint of the express app (runs every time a container STARTS)
CMD ["node", "index.js"]
