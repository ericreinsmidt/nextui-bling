# Bling — Root Makefile

.PHONY: build build-tg5040 build-tg5050 package clean

build: build-tg5040 build-tg5050

build-tg5040:
	@bash scripts/build_tg5040_docker.sh

build-tg5050:
	@bash scripts/build_tg5050_docker.sh

package: build
	@bash scripts/package_pak.sh

clean:
	docker run --rm -v $(PWD):/workspace ghcr.io/loveretro/tg5040-toolchain make -C /workspace/ports/tg5040 clean
	docker run --rm -v $(PWD):/workspace ghcr.io/loveretro/tg5050-toolchain make -C /workspace/ports/tg5050 clean
	rm -rf dist/
