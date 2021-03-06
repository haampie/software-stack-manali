-include Make.user

.PHONY: compilers packages clean

all: packages

bootstrap:
	$(info spack bootstrap...)
	$(BWRAP) $(SPACK) spec zlib > /dev/null

compilers: | bootstrap
	$(BWRAP) $(MAKE) -C compilers

packages: compilers | bootstrap
	$(BWRAP) $(MAKE) -C packages

include Make.inc

store.squashfs: compilers
	$(BWRAP) "$$($(BWRAP) $(SPACK) -e ./compilers/1-gcc find --format='{prefix}' squashfs | head -n1)/bin/mksquashfs" $(STORE) $@ -all-root -no-recovery -noappend -Xcompression-level 3

# Clean (todo: maybe call clean targets of included makefiles?)
clean:
	rm -rf -- $(wildcard */*/update-config) $(wildcard */*/spack.lock) $(wildcard */*/.spack-env) $(wildcard */*/Makefile) $(wildcard */*/generated) $(wildcard cache) $(wildcard compilers/*/config.yaml) $(wildcard compilers/*/packages.yaml) $(wildcard compilers/*/compilers.yaml) $(wildcard packages/*/config.yaml) $(wildcard packages/*/packages.yaml) $(wildcard packages/*/compilers.yaml)
