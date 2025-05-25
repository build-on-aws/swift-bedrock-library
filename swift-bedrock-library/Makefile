# Makefile for library

format:
	swift format format --recursive --in-place Sources Tests 

format-commit:
	make format
	git add .
	git commit -m "applying swift format"