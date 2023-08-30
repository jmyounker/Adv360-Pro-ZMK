DOCKER := $(shell { command -v podman || command -v docker; })
TIMESTAMP := $(shell date -u +"%Y%m%d%H%M%S")
detected_OS := $(shell uname)  # Classify UNIX OS
ifeq ($(strip $(detected_OS)),Darwin) #We only care if it's OS X
SELINUX1 :=
SELINUX2 :=
else
SELINUX1 := :z
SELINUX2 := ,z
endif

.PHONY: all clean berlin




berlin:
	cp config/boards/arm/adv360/locations/Kconfig-berlin.defconfig config/boards/arm/adv360/Kconfig.defconfig 
	make all
	cp config/boards/arm/adv360/locations/Kconfig.defconfig config/boards/arm/adv360/Kconfig.defconfig 

us:
	cp config/boards/arm/adv360/locations/Kconfig-us.defconfig config/boards/arm/adv360/Kconfig.defconfig 
	make all
	cp config/boards/arm/adv360/locations/Kconfig.defconfig config/boards/arm/adv360/Kconfig.defconfig 
	        


all:
	$(DOCKER) build --tag zmk --file Dockerfile .
	$(DOCKER) run --rm -it --name zmk \
		-v $(PWD)/firmware:/app/firmware$(SELINUX1) \
		-v $(PWD)/config:/app/config:ro$(SELINUX2) \
		-e TIMESTAMP=$(TIMESTAMP) \
		zmk

clean:
	rm -f firmware/*.uf2
	$(DOCKER) image rm zmk docker.io/zmkfirmware/zmk-build-arm:stable || true
