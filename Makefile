.PHONY: generate build test clean archive bump-build

SIMULATOR_DEST ?= generic/platform=iOS Simulator
ARCHIVE_PATH ?= build/Tribe.xcarchive
EXPORT_PATH ?= build/export
SCHEME = Tribe
PROJECT = Tribe.xcodeproj

generate:
	xcodegen generate

build: generate
	xcodebuild -scheme $(SCHEME) \
		-project $(PROJECT) \
		-destination '$(SIMULATOR_DEST)' \
		build

test: generate
	xcodebuild -scheme $(SCHEME) \
		-project $(PROJECT) \
		-destination '$(SIMULATOR_DEST)' \
		test

clean:
	rm -rf build DerivedData $(ARCHIVE_PATH) $(EXPORT_PATH)

# Release archive for TestFlight / App Store Connect upload.
# Set DEVELOPMENT_TEAM in Project.yml or pass DEVELOPMENT_TEAM=XXXXXXXXXX.
archive: generate
	xcodebuild -scheme $(SCHEME) \
		-project $(PROJECT) \
		-configuration Release \
		-destination 'generic/platform=iOS' \
		-archivePath $(ARCHIVE_PATH) \
		DEVELOPMENT_TEAM="$(DEVELOPMENT_TEAM)" \
		archive
	xcodebuild -exportArchive \
		-archivePath $(ARCHIVE_PATH) \
		-exportPath $(EXPORT_PATH) \
		-exportOptionsPlist ExportOptions.plist \
		DEVELOPMENT_TEAM="$(DEVELOPMENT_TEAM)"

# Bump CFBundleVersion (build number) in Project.yml + Info.plist.
bump-build:
	@./scripts/bump-build.sh
