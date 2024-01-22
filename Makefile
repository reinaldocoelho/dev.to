# Detalhes da atualização de pacotes
# Project: https://github.com/raineorshine/npm-check-updates
check-updates:
	ifeq (, $(shell which ncu))
	 $(error "No NCU in PATH, consider doing `npm install -g npm-check-updates`")
	endif
	ncu

update-dependencies:
	ifeq (, $(shell which ncu))
	 $(error "No NCU in PATH, consider doing `npm install -g npm-check-updates`")
	endif
	ncu -u
