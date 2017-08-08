.PHONY: all

help:
	@echo "Compile relocater"
	@echo ""
	@echo "Targets:"
	@echo "	all				- build everything"
	@echo "	clean			- clean workspace"
	@echo ""
	@echo "Options:"
	@echo "	CROSS_COMPILE	- cross compiler prefix"

all:
	$(CROSS_COMPILE)gcc relocater.c -o relocater

clean:
	@rm -Rf relocater
