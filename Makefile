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

infra-export-vars:
	cd infra && \
	terraform output -json | jq -r '.AmazonRootCA1.value' > ../out/ca.crt && \
	terraform output -json | jq -r '.esp32_cert.value' > ../out/esp32.crt && \
	terraform output -json | jq -r '.esp32_cert_private_key.value' > ../out/esp32.key && \
	dotenv -f ../.env set MQTT_ENDPOINT $$(terraform output -json | jq -r '.mqtt_endpoint.value') | exit 0 && \
	dotenv -f ../.env set APIGTW_INVOKE_URL $$(terraform output -json | jq -r '.apigtw_invoke_url.value') | exit 0 && \
	cp ../device/src/secrets.h.example ../device/src/secrets.h && \
	sed -i -e "/<AWS_CERT_CA>/{r../out/ca.crt" -e "d}" ../device/src/secrets.h && \
	sed -i -e "/<AWS_CERT_CRT>/{r../out/esp32.crt" -e "d}" ../device/src/secrets.h && \
	sed -i -e "/<AWS_CERT_PRIVATE>/{r../out/esp32.key" -e "d}" ../device/src/secrets.h
