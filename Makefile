IMAGE_NAME := rezaq/libpostal
REST_IMAGE_NAME := rezaq/libpostal-rest
VERSION := latest
MODEL ?= default

.PHONY: help build-alpine-base build-alpine-rest build-debian-base build-debian-rest run-alpine run-debian run-alpine-base run-debian-base

help:
	@echo "Available commands:"
	@echo "  make build-alpine-base   - Build Alpine Base image (libpostal only)"
	@echo "  make build-alpine-rest   - Build Alpine REST image (libpostal + API)"
	@echo "  make build-debian-base   - Build Debian Base image (libpostal only)"
	@echo "  make build-debian-rest   - Build Debian REST image (libpostal + API)"
	@echo "  make run-alpine          - Run Alpine REST image (use MODEL=senzing to download senzing model instead of default)"
	@echo "  make run-debian          - Run Debian REST image (use MODEL=senzing to download senzing model instead of default)"
	@echo "  make run-alpine-base     - Run Alpine Base image (shell)"
	@echo "  make run-debian-base     - Run Debian Base image (shell)"

build-alpine-base:
	docker build --target base -t $(IMAGE_NAME):alpine -f Dockerfile.alpine .

build-alpine-rest:
	docker build --target rest -t $(REST_IMAGE_NAME):alpine -f Dockerfile.alpine .

build-debian-base:
	docker build --target base -t $(IMAGE_NAME):latest -f Dockerfile.debian .

build-debian-rest:
	docker build --target rest -t $(REST_IMAGE_NAME):latest -f Dockerfile.debian .

run-alpine:
	mkdir -p data
	docker run -it --rm -p 8080:8080 -e MODEL=$(MODEL) -v $(shell pwd)/data:/data $(REST_IMAGE_NAME):alpine

run-debian:
	mkdir -p data
	docker run -it --rm -p 8080:8080 -e MODEL=$(MODEL) -v $(shell pwd)/data:/data $(REST_IMAGE_NAME):latest

run-alpine-base:
	mkdir -p data
	docker run -it --rm -v $(shell pwd)/data:/data $(IMAGE_NAME):alpine /bin/sh

run-debian-base:
	mkdir -p data
	docker run -it --rm -v $(shell pwd)/data:/data $(IMAGE_NAME):latest /bin/bash

