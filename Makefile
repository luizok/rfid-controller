ifneq (,$(wildcard ./.env))
    include .env
    export
endif

device-build:
	cd device && \
		pio run --verbose --environment esp32doit-devkit-v1

device-deploy:
	cd device && \
		pio run --target upload --environment esp32doit-devkit-v1

device-debug:
	cd device && \
		pio device monitor

infra-init:
	cd infra && \
		terraform init -backend-config config.aws.tfbackend

infra-plan:
	cd infra && \
	terraform plan \
		-var-file values.tfvars \
		-var 'topic_name=$(TOPIC_NAME)' \
		-var 'client_id=$(CLIENT_ID)'

infra-apply:
	cd infra && \
	terraform apply \
		-var-file values.tfvars \
		-var 'topic_name=$(TOPIC_NAME)' \
		-var 'client_id=$(CLIENT_ID)'

infra-get-outputs:
	cd infra && \
	dotenv -f ../.env set AMAZON_CERT "$$(terraform output -json | jq -r '.AmazonRootCA1.value')"
