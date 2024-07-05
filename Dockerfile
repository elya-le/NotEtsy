FROM python:3.9.18-alpine3.18

RUN apk add --no-cache build-base postgresql-dev gcc python3-dev musl-dev bash wget

ARG FLASK_APP
ARG FLASK_ENV
ARG DATABASE_URL
ARG SCHEMA
ARG SECRET_KEY

# Set environment variables
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

# Verify environment variables and network connectivity
RUN echo "DATABASE_URL: $DATABASE_URL"
RUN echo "SECRET_KEY: $SECRET_KEY"
RUN wget -q --spider $DATABASE_URL || { echo "wget failed. Hostname may not be resolvable."; exit 1; }

RUN flask db upgrade
RUN flask seed all

CMD ["gunicorn", "app:app"]
