# Libpostal Docker Images

This repository provides multi-architecture (AMD64/ARM64) Docker images for [libpostal](https://github.com/openvenues/libpostal).

We provide two types of images:

1. **Base Image (`libpostal`)**: Contains the C library and headers. Ideal for building your own bindings (Python, Node.js, etc.).
2. **REST Service (`libpostal-rest`)**: Contains the library wrapped with a [Go REST API](https://github.com/rezaghazeli/libpostal-rest).

## Image Variants

### 1. Operating System

* **Debian (Slim)** - `latest`, `debian`
  * **Base:** `debian:trixie-slim`
  * **Best for:** General use, compatibility (glibc).
* **Alpine Linux** - `alpine`
  * **Base:** `alpine:latest`
  * **Best for:** Minimal image size (~70% smaller, 67MB for REST version).

### 2. Image Types

| Image Name | Description |
| :--- | :--- |
| `rezaghazeli/libpostal` | Base C library only. Includes `libpostal_data` downloader tools. |
| `rezaghazeli/libpostal-rest` | Includes the Go REST API server running on port 8080. |

## Data Models

Libpostal requires ~2GB of training data. To keep images small, **data is NOT included**.
The container will automatically download the data to `/data` on startup if it's missing.

**Supported Models:**

* `default`: The standard OpenStreetMap-based model.
* `senzing`: A model optimized for Senzing entity resolution.

**⚠️ Important:** You MUST mount a volume to `/data` to persist the models. Otherwise, they will be re-downloaded every time you restart the container.

## Usage

### 1. Running the REST Service

**Default Model:**

```bash
docker run -d \
  -p 8080:8080 \
  -v $(pwd)/libpostal_data:/data \
  rezaghazeli/libpostal-rest:latest
```

**Senzing Model:**

```bash
docker run -d \
  -p 8080:8080 \
  -e MODEL=senzing \
  -v $(pwd)/libpostal_data:/data \
  rezaghazeli/libpostal-rest:latest
```

### 2. Using the Base Image

Useful if you want to build your own application on top of libpostal.

```bash
docker run -it \
  -v $(pwd)/libpostal_data:/data \
  rezaghazeli/libpostal:latest /bin/bash
```

### 3. Docker Compose

```yaml
version: '3.8'

services:
  libpostal:
    image: rezaghazeli/libpostal-rest:latest
    ports:
      - "8080:8080"
    environment:
      - MODEL=default  # or 'senzing'
    volumes:
      - ./libpostal_data:/data
    restart: unless-stopped
```

## API Endpoints

**Parse Address:**

```bash
curl -X POST -d '{"query": "781 Franklin Ave Crown Heights Brooklyn NYC NY 11216 USA"}' http://localhost:8080/parser
```

**Expand Address:**

```bash
curl -X POST -d '{"query": "781 Franklin Ave Crown Heights Brooklyn NYC NY 11216 USA"}' http://localhost:8080/expand
```

## Build Locally

```bash
# Build REST images
make build-debian-rest
make build-alpine-rest

# Build Base images
make build-debian-base
make build-alpine-base
```

## CI/CD

This repository uses GitHub Actions to automatically build and push images to Docker Hub when changes are pushed to the `master` branch or when a new release tag (e.g., `v1.0.0`) is created.
