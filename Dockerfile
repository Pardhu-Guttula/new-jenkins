FROM nginx:latest

# Set the working directory to the default Nginx document root
WORKDIR /usr/share/nginx/html

# Copy the HTML file into the working directory
COPY index.html .

# Expose port 80 for web traffic
EXPOSE 80