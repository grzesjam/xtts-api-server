# Use an official NVIDIA base image with CUDA support
FROM python:3.11-slim
WORKDIR /app

# Install required packages (avoid cache to reduce image size)
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
    python3-dev portaudio19-dev libportaudio2 libasound2-dev libportaudiocpp0 \
    git python3 python3-pip make g++ ffmpeg && \
    rm -rf /var/lib/apt/lists/*

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Copy the application source code to /app directory and change the workdir to /app
COPY . /app/
RUN uv build

RUN --mount=type=cache,target=/root/.cache/pip pip install /app/dist/*.whl

# Expose the container ports
EXPOSE 8020

# Run xtts_api_server when the container starts
CMD ["bash", "-c", "python3 -m xtts_api_server --listen -p 8020 -t 'http://localhost:8020' -sf '/xtts-server/speakers' -o '/xtts-server/output' -mf '/xtts-server/models'"]
