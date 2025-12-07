FROM python:3.9 

# Run to execute commands in the image
RUN mkdir -p /home/app
RUN pip install flask

# Copy application files to the container: COPY <host> <container>
COPY ./app.py /home/app

# Set working directory
WORKDIR /home/app

# Entry point to start the server
CMD [ "python3", "app.py"]