.PHONY: generate build clean

generate:
	xcodegen generate

build: generate
	xcodebuild -scheme Tribe \
		-project Tribe.xcodeproj \
		-destination 'generic/platform=iOS Simulator' \
		build

clean:
	rm -rf build DerivedData
