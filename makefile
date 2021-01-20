all: compile

compile:
	ponyc server -o build
	ponyc client -o build
