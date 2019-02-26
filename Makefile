help:
	@echo usage: make init

init:
	carthage bootstrap --platform iOS --cache-builds --project-directory ./src
