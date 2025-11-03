# Use official Python runtime as a parent image
FROM python:3.13-slim

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Export the port the app runs on
EXPOSE 8000

# Run the app using uvicorn (host 0.0.0.0 is required to be accessible by Cloud Run)
CMD uvicorn main:app --host 0.0.0.0 --port $PORT