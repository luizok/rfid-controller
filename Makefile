device-build:
	cd device && \
		pio run --verbose --environment esp32doit-devkit-v1

device-deploy:
	cd device && \
		pio run --target upload --environment esp32doit-devkit-v1

device-debug:
	cd device && \
		pio device monitor
