# pull official base image
FROM python:3.8.3-alpine

# set work directory
WORKDIR /usr/src/app

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV CRYPTOGRAPHY_DONT_BUILD_RUST 1

RUN mkdir -p /usr/src/static/ && chown -R daemon:daemon /usr/src/static/
RUN mkdir -p /usr/src/media/ && chown -R daemon:daemon /usr/src/media/
RUN mkdir -p /usr/src/uploads/ && chown -R daemon:daemon /usr/src/uploads/
RUN mkdir -p /var/log/django/ && chown -R daemon:daemon /var/log/django/

# install dependencies
RUN apk update \
    && apk add curl postgresql-dev build-base python3-dev jpeg-dev zlib-dev libffi-dev ffmpeg

# install dependencies
RUN pip install --upgrade pip
COPY ./requirements.txt .
RUN pip install -r requirements.txt --upgrade

# copy entrypoint.sh
COPY ./entrypoint.sh .
RUN chmod a+x ./entrypoint.sh

# copy project
COPY . .

# run entrypoint.sh
ENTRYPOINT ["/usr/src/app/entrypoint.sh"]