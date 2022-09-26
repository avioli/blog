GH_REPO := avioli/blog.git

uname_s := $(shell uname -s)
# $(info uname_s=$(uname_s))

help:
	@echo run: make deploy

install: installed.$(uname_s)

installed.Darwin:
	command -v multimarkdown &>/dev/null || brew install multimarkdown
	command -v gawk &>/dev/null || brew install gawk
	command -v gsed &>/dev/null || brew install gnu-sed
	command -v gdate &>/dev/null || brew install coreutils
	command -v jenny &>/dev/null || ( \
		mkdir -p ~/repos/ ~/bin && \
		git clone https://github.com/avioli/jenny.git ~/repos/jenny && \
		cd ~/bin && ln -s ../repos/jenny/jenny . \
	)
	touch installed.Darwin

installed.Linux:
	command -v multimarkdown &>/dev/null || brew install multimarkdown
	command -v jenny &>/dev/null || ( \
		mkdir -p ~/repos/ ~/bin && \
		git clone https://github.com/avioli/jenny.git ~/repos/jenny && \
		cd ~/bin && ln -s ../repos/jenny/jenny . \
	)
	touch installed.Linux

.dist:
	mkdir .dist

.dist/index.html: .dist
	jenny

.dist/.git/deployed: .dist/index.html
	cd .dist && \
		git init && git add . && git commit -m "Deploy to github.com/$(GH_REPO):gh-pages" && \
		git remote add origin git@github.com:$(GH_REPO) && \
		git push --force origin master:gh-pages && \
		touch .git/deployed

cleanup:
	rm -rf .dist

deploy: .dist/.git/deployed
