# =============================================================================
# Flutter Project Makefile Base Configuration
# Author: btLong402
# Description: Professional Makefile for building, running, and managing
#              the Flutter project across multiple environments (Dev, Staging, Prod).
# =============================================================================

# Configuration Variables
FLUTTER_BIN := flutter
DART_BIN    := dart

# Target Entry Points (Matching lib/_main/ directory structure)
ENTRY_DEV     := lib/_main/main.dart
ENTRY_STAGING := lib/_main/main_staging.dart
ENTRY_PROD    := lib/_main/main_prod.dart

# Build Flavors (Uncomment and configure if native Android/iOS flavors are configured)
# FLAVOR_DEV     := development
# FLAVOR_STAGING := staging
# FLAVOR_PROD    := production

# Custom build arguments (can be passed via CLI, e.g., make build-apk-prod BUILD_ARGS="--obfuscate --split-debug-info=build/app/outputs/symbols")
BUILD_ARGS ?=

# ANSI Color Codes for beautiful terminal output
GREEN  := $(shell printf "\033[32m")
YELLOW := $(shell printf "\033[33m")
WHITE  := $(shell printf "\033[37m")
RESET  := $(shell printf "\033[0m")

.PHONY: help clean get clean-get clean-ios pod-install upgrade \
        build-runner build-runner-watch build-runner-clean \
        lint format test test-coverage \
        run-dev run-staging run-prod \
        build-apk-dev build-apk-staging build-apk-prod \
        build-bundle-dev build-bundle-staging build-bundle-prod \
        build-ipa-dev build-ipa-staging build-ipa-prod \
        build-ios-dev build-ios-staging build-ios-prod

# Default target is to display the help menu
.DEFAULT_GOAL := help

help:
	@echo "============================================================================="
	@echo "                    $(GREEN)FLUTTER BASE PROJECT MAKEFILE$(RESET)"
	@echo "============================================================================="
	@echo "Please choose one of the following commands:"
	@echo ""
	@echo "$(YELLOW)Cleaning & Dependencies:$(RESET)"
	@echo "  make clean                - Clean build files using Flutter Clean"
	@echo "  make get                  - Fetch package dependencies (pub get)"
	@echo "  make clean-get            - Clean build files and fetch dependencies"
	@echo "  make clean-ios            - Deep clean iOS Pods, locks, build cache, and re-init dependencies"
	@echo "  make pod-install          - Run pod install in iOS directory"
	@echo "  make upgrade              - Upgrade package dependencies"
	@echo ""
	@echo "$(YELLOW)Code Generation & Tools:$(RESET)"
	@echo "  make build-runner         - Run build runner to generate files (one-time build)"
	@echo "  make build-runner-watch   - Run build runner in watch mode"
	@echo "  make build-runner-clean   - Clean build runner caches"
	@echo "  make lint                 - Analyze Dart code for errors or warnings"
	@echo "  make format               - Format all Dart source files"
	@echo "  make test                 - Run all unit tests"
	@echo "  make test-coverage        - Run unit tests and generate HTML coverage report"
	@echo ""
	@echo "$(YELLOW)Run App (Development mode):$(RESET)"
	@echo "  make run-dev              - Run Development environment ($(ENTRY_DEV))"
	@echo "  make run-staging          - Run Staging environment ($(ENTRY_STAGING))"
	@echo "  make run-prod             - Run Production environment ($(ENTRY_PROD))"
	@echo ""
	@echo "$(YELLOW)Build Android:$(RESET)"
	@echo "  make build-apk-dev        - Build Development APK"
	@echo "  make build-apk-staging    - Build Staging APK"
	@echo "  make build-apk-prod       - Build Production APK"
	@echo "  make build-bundle-dev     - Build Development App Bundle (AAB)"
	@echo "  make build-bundle-staging - Build Staging App Bundle (AAB)"
	@echo "  make build-bundle-prod    - Build Production App Bundle (AAB)"
	@echo ""
	@echo "$(YELLOW)Build iOS:$(RESET)"
	@echo "  make build-ipa-dev        - Build Development IPA (App Store/Ad-Hoc)"
	@echo "  make build-ipa-staging    - Build Staging IPA"
	@echo "  make build-ipa-prod       - Build Production IPA"
	@echo "  make build-ios-dev        - Build Development iOS App bundle"
	@echo "  make build-ios-staging    - Build Staging iOS App bundle"
	@echo "  make build-ios-prod       - Build Production iOS App bundle"
	@echo "============================================================================="
	@echo "Note: You can pass custom options using BUILD_ARGS, e.g.:"
	@echo "      make build-apk-prod BUILD_ARGS=\"--obfuscate --split-debug-info=build/symbols\""
	@echo "============================================================================="

# -----------------------------------------------------------------------------
# Cleaning & Dependencies
# -----------------------------------------------------------------------------

clean:
	@echo "$(YELLOW)Cleaning Flutter project...$(RESET)"
	@$(FLUTTER_BIN) clean

get:
	@echo "$(YELLOW)Fetching packages...$(RESET)"
	@$(FLUTTER_BIN) pub get

clean-get: clean get

clean-ios:
	@echo "$(YELLOW)Deep cleaning iOS workspace...$(RESET)"
	@rm -rf ios/Pods ios/Podfile.lock ios/.symlinks ios/Flutter/Flutter.podspec ios/Flutter/Flutter.framework
	@$(FLUTTER_BIN) clean
	@$(FLUTTER_BIN) pub get
	@echo "$(YELLOW)Installing pods...$(RESET)"
	@cd ios && pod install

pod-install:
	@echo "$(YELLOW)Running pod install...$(RESET)"
	@cd ios && pod install

upgrade:
	@echo "$(YELLOW)Upgrading packages...$(RESET)"
	@$(FLUTTER_BIN) pub upgrade

# -----------------------------------------------------------------------------
# Code Generation & Quality
# -----------------------------------------------------------------------------

build-runner:
	@echo "$(YELLOW)Generating files using build_runner...$(RESET)"
	@$(DART_BIN) run build_runner build --delete-conflicting-outputs

build-runner-watch:
	@echo "$(YELLOW)Starting build_runner watch...$(RESET)"
	@$(DART_BIN) run build_runner watch --delete-conflicting-outputs

build-runner-clean:
	@echo "$(YELLOW)Cleaning build_runner cache...$(RESET)"
	@$(DART_BIN) run build_runner clean

lint:
	@echo "$(YELLOW)Analyzing code...$(RESET)"
	@$(FLUTTER_BIN) analyze

format:
	@echo "$(YELLOW)Formatting code...$(RESET)"
	@$(DART_BIN) format .

test:
	@echo "$(YELLOW)Running tests...$(RESET)"
	@$(FLUTTER_BIN) test

test-coverage:
	@echo "$(YELLOW)Running tests with coverage...$(RESET)"
	@$(FLUTTER_BIN) test --coverage
	@echo "$(YELLOW)Generating HTML report...$(RESET)"
	@genhtml coverage/lcov.info -o coverage/html
	@echo "$(GREEN)Coverage report generated at coverage/html/index.html$(RESET)"

# -----------------------------------------------------------------------------
# Run App
# -----------------------------------------------------------------------------

run-dev:
	@echo "$(YELLOW)Running application in DEVELOPMENT mode...$(RESET)"
	@$(FLUTTER_BIN) run -t $(ENTRY_DEV)

run-staging:
	@echo "$(YELLOW)Running application in STAGING mode...$(RESET)"
	@$(FLUTTER_BIN) run -t $(ENTRY_STAGING)

run-prod:
	@echo "$(YELLOW)Running application in PRODUCTION mode...$(RESET)"
	@$(FLUTTER_BIN) run -t $(ENTRY_PROD)

# -----------------------------------------------------------------------------
# Build Android
# -----------------------------------------------------------------------------

build-apk-dev:
	@echo "$(YELLOW)Building DEVELOPMENT APK...$(RESET)"
	@$(FLUTTER_BIN) build apk -t $(ENTRY_DEV) --release $(BUILD_ARGS)

build-apk-staging:
	@echo "$(YELLOW)Building STAGING APK...$(RESET)"
	@$(FLUTTER_BIN) build apk -t $(ENTRY_STAGING) --release $(BUILD_ARGS)

build-apk-prod:
	@echo "$(YELLOW)Building PRODUCTION APK...$(RESET)"
	@$(FLUTTER_BIN) build apk -t $(ENTRY_PROD) --release $(BUILD_ARGS)

build-bundle-dev:
	@echo "$(YELLOW)Building DEVELOPMENT App Bundle (AAB)...$(RESET)"
	@$(FLUTTER_BIN) build appbundle -t $(ENTRY_DEV) --release $(BUILD_ARGS)

build-bundle-staging:
	@echo "$(YELLOW)Building STAGING App Bundle (AAB)...$(RESET)"
	@$(FLUTTER_BIN) build appbundle -t $(ENTRY_STAGING) --release $(BUILD_ARGS)

build-bundle-prod:
	@echo "$(YELLOW)Building PRODUCTION App Bundle (AAB)...$(RESET)"
	@$(FLUTTER_BIN) build appbundle -t $(ENTRY_PROD) --release $(BUILD_ARGS)

# -----------------------------------------------------------------------------
# Build iOS
# -----------------------------------------------------------------------------

build-ipa-dev:
	@echo "$(YELLOW)Building DEVELOPMENT IPA...$(RESET)"
	@$(FLUTTER_BIN) build ipa -t $(ENTRY_DEV) --release $(BUILD_ARGS)

build-ipa-staging:
	@echo "$(YELLOW)Building STAGING IPA...$(RESET)"
	@$(FLUTTER_BIN) build ipa -t $(ENTRY_STAGING) --release $(BUILD_ARGS)

build-ipa-prod:
	@echo "$(YELLOW)Building PRODUCTION IPA...$(RESET)"
	@$(FLUTTER_BIN) build ipa -t $(ENTRY_PROD) --release $(BUILD_ARGS)

build-ios-dev:
	@echo "$(YELLOW)Building DEVELOPMENT iOS App Bundle...$(RESET)"
	@$(FLUTTER_BIN) build ios -t $(ENTRY_DEV) --release $(BUILD_ARGS)

build-ios-staging:
	@echo "$(YELLOW)Building STAGING iOS App Bundle...$(RESET)"
	@$(FLUTTER_BIN) build ios -t $(ENTRY_STAGING) --release $(BUILD_ARGS)

build-ios-prod:
	@echo "$(YELLOW)Building PRODUCTION iOS App Bundle...$(RESET)"
	@$(FLUTTER_BIN) build ios -t $(ENTRY_PROD) --release $(BUILD_ARGS)
