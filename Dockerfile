# https://medium.com/@albertazzir/blazing-fast-python-docker-builds-with-poetry-a78a66f5aed0
FROM python:3.12.11-bullseye as builder

RUN pip install poetry==2.1.3

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    POETRY_CACHE_DIR=/tmp/poetry_cache

WORKDIR /app

COPY pyproject.toml poetry.lock ./

RUN poetry install --no-root && rm -rf $POETRY_CACHE_DIR

# The runtime image, used to just run the code provided its virtual environment
FROM python:3.12-slim-bullseye as runtime

RUN apt-get update && \
    apt-get install git -y

COPY --from=builder /app /app
COPY setup_repo.sh /app/setup_repo.sh
RUN chmod +x /app/setup_repo.sh

ENV PATH="/app/.venv/bin:$PATH"

WORKDIR /app

CMD [ "/bin/bash" ]