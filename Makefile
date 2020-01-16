help:
	@echo usage: make init

init:
	carthage bootstrap --platform iOS --no-use-binaries --cache-builds --project-directory ./src
