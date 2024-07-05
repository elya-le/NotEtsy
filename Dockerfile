FROM python:3.9.18-alpine3.18

RUN apk add --no-cache build-base postgresql-dev gcc python3-dev musl-dev bash iputils

ARG FLASK_APP
ARG FLASK_ENV
ARG DATABASE_URL
ARG SCHEMA
ARG SECRET_KEY

# set environment variables
ENV FLASK_APP=$FLASK_APP
ENV FLASK_ENV=$FLASK_ENV
ENV DATABASE_URL=$DATABASE_URL
ENV SCHEMA=$SCHEMA
ENV SECRET_KEY=$SECRET_KEY

WORKDIR /var/www

COPY requirements.txt .

RUN pip install -r requirements.txt
RUN pip install psycopg2

COPY . .

# verify environment variables and network connectivity
RUN echo "DATABASE_URL: $DATABASE_URL"
RUN echo "SECRET_KEY: $SECRET_KEY"
RUN ping -c 4 dpg-cq3tsncs1f4s73fmegk0-a || { echo "Ping failed. Hostname may not be resolvable."; exit 1; }

RUN flask db upgrade
RUN flask seed all

CMD ["gunicorn", "app:app"]
