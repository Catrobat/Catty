help:
	@echo usage: make init

init:
	carthage bootstrap --platform iOS --use-xcframeworks --cache-builds --project-directory ./src
