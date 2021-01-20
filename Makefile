help:
	@echo usage: make init

init:
	sh src/RunScripts/carthage.sh bootstrap --platform iOS --cache-builds --project-directory ./src
