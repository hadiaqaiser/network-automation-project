# Lightweight Node.js runtime image
FROM node:20-alpine

# Set working directory inside container
WORKDIR /app

# Copy package info first and install dependencies
COPY package.json package-lock.json* ./
RUN npm install --omit=dev || npm install

# Copy the rest of the source code
COPY . .

# App will listen on port 3000
EXPOSE 3000

# Start the Node app
CMD ["npm", "start"]