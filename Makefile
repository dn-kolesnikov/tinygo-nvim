.PHONY:
.SILENT:

format:
	stylua **/*.lua

lint:
	selene **/*.lua

