# FROM python:3.11-slim-buster
# RUN apt-get update && apt-get install -y \
#     build-essential \
#     libpq-dev \
#     nginx \
#     && rm -rf /var/lib/apt/lists/*
# RUN pip install django gunicorn psycopg2
# ADD . /app
# WORKDIR /app
# EXPOSE 8000
# CMD ["gunicorn", "--bind", ":8000", "--workers", "3", "djangok8spg.wsgi"]


# FROM ubuntu:22.04
# RUN apt-get update && apt-get install -y tzdata \ 
#     && apt install -y python3-pip
# RUN apt install python3-dev libpq-dev nginx -y 
#     # && rm -rf /var/lib/apt/lists/*
FROM python:3.10.9-buster
RUN pip install django gunicorn psycopg2 psycopg2-binary
ADD . /app
WORKDIR /app
EXPOSE 8000
CMD ["gunicorn", "--bind", ":8000", "--workers", "3", "djangok8spg.wsgi"]
