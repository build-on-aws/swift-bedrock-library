# Makefile for library

format:
	swift format format --parallel --recursive --in-place ./Package.swift Examples/ Sources/ Tests/

preview-docs:
# 	xcrun docc preview Sources/BedrockService/Docs.docc --output-path docc-output
	swift package --disable-sandbox preview-documentation --target BedrockService

# https://build-on-aws.github.io/swift-bedrock-library/documentation/bedrockservice/
generate-docs:
	touch .nojekyll
	swift package                         \
		--allow-writing-to-directory ./docs \
		generate-documentation              \
		--target BedrockService             \
		--disable-indexing                  \
		--transform-for-static-hosting      \
		--hosting-base-path swift-bedrock-library \
		--output-path ./docs