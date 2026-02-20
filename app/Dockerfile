# Use a lightweight Python base image
FROM python:3.10-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file and install dependencies
# (We do this first to leverage Docker layer caching)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy your actual Flask application code
COPY main.py .

# Expose the port Flask runs on
EXPOSE 8080

# Command to run the application
CMD ["python", "main.py"]