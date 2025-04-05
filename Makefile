DOCKER := $(shell { command -v podman || command -v docker; })
TIMESTAMP := $(shell date -u +"%Y%m%d%H%M")
COMMIT := $(shell git rev-parse --short HEAD 2>/dev/null)
ifeq ($(shell uname),Darwin)
SELINUX1 :=
SELINUX2 :=
else
SELINUX1 := :z
SELINUX2 := ,z
endif

.PHONY: all left clean_firmware clean_image clean berlin us upstream home work

home:
	cp config/boards/arm/adv360/locations/Kconfig-home.defconfig config/boards/arm/adv360/Kconfig.defconfig
	make all
	cp config/boards/arm/adv360/locations/Kconfig.defconfig config/boards/arm/adv360/Kconfig.defconfig

work:
	cp config/boards/arm/adv360/locations/Kconfig-work.defconfig config/boards/arm/adv360/Kconfig.defconfig
	make all
	cp config/boards/arm/adv360/locations/Kconfig.defconfig config/boards/arm/adv360/Kconfig.defconfig

restore_config:
	cp config/boards/arm/adv360/locations/Kconfig.defconfig config/boards/arm/adv360/Kconfig.defconfig

# Sets upstream for a newly cloned repo
upstream:
	git remote add upstream git@github.com:KinesisCorporation/Adv360-Pro-ZMK.git

all:
	$(shell bin/get_version.sh >> /dev/null)
	$(DOCKER) build --tag zmk --file Dockerfile .
	$(DOCKER) run --rm -it --name zmk \
		-v $(PWD)/firmware:/app/firmware$(SELINUX1) \
		-v $(PWD)/config:/app/config:ro$(SELINUX2) \
		-e TIMESTAMP=$(TIMESTAMP) \
		-e COMMIT=$(COMMIT) \
		-e BUILD_RIGHT=true \
		zmk
	git checkout config/version.dtsi

left:
	$(shell bin/get_version.sh >> /dev/null)
	$(DOCKER) build --tag zmk --file Dockerfile .
	$(DOCKER) run --rm -it --name zmk \
		-v $(PWD)/firmware:/app/firmware$(SELINUX1) \
		-v $(PWD)/config:/app/config:ro$(SELINUX2) \
		-e TIMESTAMP=$(TIMESTAMP) \
		-e COMMIT=$(COMMIT) \
		-e BUILD_RIGHT=false \
		zmk
	git checkout config/version.dtsi

clean_firmware:
	rm -f firmware/*.uf2

clean_image:
	$(DOCKER) image rm zmk docker.io/zmkfirmware/zmk-build-arm:stable

clean: restore_config clean_firmware clean_image
