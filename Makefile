# Copyright 2020 Hayo van Loon
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Naming
MODULE_NAME := frontend
VERSION := v1
SERVICE_NAME := $(MODULE_NAME)-$(VERSION)
SERVICE_ACCOUNT := $(SERVICE_NAME)@$(PROJECT).iam.gserviceaccount.com

# GCP Region
REGION=europe-west1

# GCP Labels added to Cloud Run deployment (for tracking costs)
LABELS := app=frontend

# Docker-related
IMAGE_NAME := $(MODULE_NAME)_$(VERSION)
TAG := latest

# Settings for local deployments
PORT := 8081


.PHONY: clean

check:
ifndef PROJECT
	$(error PROJECT not set)
endif

all: build push-gcr service-account deploy

release: build push-gcr deploy

clean:
	go clean

run:
	export PORT=$(PORT) && \
	go run server.go

build:
	docker build -t $(IMAGE_NAME) .

docker-run:
	docker run \
		--network="host" \
		-e PORT=$(PORT) \
		$(IMAGE_NAME)

push-gcr: check
	docker tag $(IMAGE_NAME) gcr.io/$(PROJECT)/$(IMAGE_NAME):$(TAG)
	docker push gcr.io/$(PROJECT)/$(IMAGE_NAME)

service-account: check
	gcloud iam service-accounts create $(SERVICE_NAME) \
		--project=$(PROJECT)

deploy: check
	gcloud run deploy $(SERVICE_NAME) \
		--project=$(PROJECT) \
		--region=$(REGION) \
		--platform=managed \
		--memory=128Mi \
		--image=gcr.io/$(PROJECT)/$(IMAGE_NAME) \
		--no-allow-unauthenticated \
		--service-account=$(SERVICE_ACCOUNT) \
		--labels=$(LABELS)

destroy: check
	gcloud iam service-accounts delete $(SERVICE_ACCOUNT) \
		--project=$(PROJECT)
	gcloud run services delete $(SERVICE_NAME) \
		--project=$(PROJECT) \
		--region=$(REGION) \
		--platform=managed
