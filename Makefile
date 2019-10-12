.DEFAULT_GOAL := all

SHELL := /bin/bash

makefile := $(abspath $(lastword $(MAKEFILE_LIST)))
makefile_dir := $(dir $(makefile))

extensions := .GBL .GBS .GBO .GML .GTL .GTS .GTO -NPTH.TXT .TXT

acrylic_files := $(addprefix dist/kana60-acrylic-plates/kana60-acrylic-plates,-main.pdf -dimensions.pdf)
acrylic_zip := dist/kana60-acrylic-plates/kana60-acrylic-plates.zip

pcb_files := $(addprefix dist/kana60/kana60,$(extensions))
pcb_zip := dist/kana60/kana60.zip

plate_files := $(addprefix dist/kana60-top-plate/kana60-top-plate,$(extensions))
plate_zip := dist/kana60-top-plate/kana60-top-plate.zip

checksum_file := dist/kana60-sha256sum.txt

%.GBL: %-B_Cu.gbr
	cp $< $@

%.GBS: %-B_Mask.gbr
	cp $< $@

%.GBO: %-B_SilkS.gbr
	cp $< $@

%.GML: %-Edge_Cuts.gbr
	cp $< $@

%.GTL: %-F_Cu.gbr
	cp $< $@

%.GTS: %-F_Mask.gbr
	cp $< $@

%.GTO: %-F_SilkS.gbr
	cp $< $@

%-NPTH.TXT: %-NPTH.drl
	cp $< $@

%.TXT: %-PTH.drl
	cp $< $@

%-main.pdf: %-Edge_Cuts.pdf
	cp $< $@

%-dimensions.pdf: %-Dwgs_User.pdf
	cp $< $@

.PHONY: all
all: ## output targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(makefile) | awk 'BEGIN { FS = ":.*?## " }; { printf "\033[36m%-30s\033[0m %s\n", $$1, $$2 }'

.PHONY: build
build: build_acrylic build_pcb build_plate ## packaging acrylic, PCB and plate

.PHONY: build_acrylic
build_acrylic: $(acrylic_files)
build_acrylic: ## packaging acrylic files to zip for Elecrow
	zip -j $(acrylic_zip) $^
	@printf -- 'generate %s\n' "$(acrylic_zip)"

.PHONY: build_pcb
build_pcb: $(pcb_files)
build_pcb: ## packaging PCB files to zip for Elecrow
	zip -j $(pcb_zip) $^
	@printf -- 'generate %s\n' "$(pcb_zip)"

.PHONY: build_plate
build_plate: $(plate_files)
build_plate: ## packaging top plate files to zip for Elecrow
	zip -j $(plate_zip) $^
	@printf -- 'generate %s\n' "$(plate_zip)"

.PHONY: clean
clean: ## remove some generated files
	$(RM) $(acrylic_files) $(acrylic_zip) $(pcb_files) $(pcb_zip) $(plate_files) $(plate_zip)

.PHONY: create_checksum
create_checksum: ## create checksum file
	shasum --algorithm 256 $(acrylic_zip) $(pcb_zip) $(plate_zip) | awk '{ last = split($$2, file, "/"); print $$1 "  " file[last] }' > $(checksum_file)

.PHONY: info
info: info_acrylic info_pcb info_plate ## show archive infomations

.PHONY: info_acrylic
info_acrylic: ## show archive info for acrylic
	zipinfo $(acrylic_zip)

.PHONY: info_pcb
info_pcb: ## show archive info for PCB
	zipinfo $(pcb_zip)

.PHONY: info_plate
info_plate: ## show archive info for plate
	zipinfo $(plate_zip)
