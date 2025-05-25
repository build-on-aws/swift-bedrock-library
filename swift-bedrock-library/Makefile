# Makefile for library

format:
	swift format format -i ./Sources/*/*.swift
	swift format format -i ./Sources/*/*/*.swift
	swift format format -i ./Sources/*/*/*/*.swift
	swift format format -i ./Sources/*/*/*/*/*.swift
	swift format format -i ./Tests/*.swift
	swift format format -i ./Tests/*/*.swift
	swift format format -i ./Tests/*/*/*.swift

format-commit:
	make format
	git add .
	git commit -m'formatting'