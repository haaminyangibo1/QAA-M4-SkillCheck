# Dockerfile to host the files as a web server
# Start from an image that already has nginx installed
FROM nginx:alpine

# Replace nginx's default settings with ours: serve the files AND
# forward /colour requests to the backend (reverse proxy)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Move the html and js files to the default nginx location
COPY index.html index.js /usr/share/nginx/html/

# nginx listens on port 80. No CMD needed: the nginx image already starts nginx.
EXPOSE 80
