.PHONY: help setup clean get upgrade build-runner watch format lint analyze test coverage \
        build-apk-dev build-apk-stg build-apk-prod \
        build-appbundle-dev build-appbundle-stg build-appbundle-prod \
        build-ios-dev build-ios-stg build-ios-prod

# Colors for terminal output
CYAN   := \033[36m
GREEN  := \033[32m
YELLOW := \033[33m
RED    := \033[31m
RESET  := \033[0m

# ==============================================================================
# 🎯 FVM (Flutter Version Management) Auto-Detection
# If .fvmrc or .fvm/ exists in the project and `fvm` is installed, use `fvm flutter`
# Otherwise fallback seamlessly to system `flutter` and `dart`.
# ==============================================================================
FVM_EXISTS := $(shell if [ -f .fvmrc ] || [ -f .fvm/fvm_config.json ] || [ -d .fvm ]; then command -v fvm >/dev/null 2>&1 && echo "yes"; fi)

ifeq ($(FVM_EXISTS),yes)
  FLUTTER := fvm flutter
  DART    := fvm dart
  ENGINE  := $(CYAN)fvm flutter$(RESET) $(YELLOW)(detected FVM)$(RESET)
else
  FLUTTER := flutter
  DART    := dart
  ENGINE  := $(CYAN)flutter$(RESET) $(GREEN)(system SDK)$(RESET)
endif

## 📋 Help
help: ## Show this help message
	@echo "$(CYAN)Available Makefile commands for Flutter:$(RESET)"
	@echo "  $(YELLOW)Engine:$(RESET) $(ENGINE)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-24s$(RESET) %s\n", $$1, $$2}'

## 🚀 Environment & Setup
setup: clean get build-runner ## Fresh setup: clean, get packages, run build_runner
	@echo "$(GREEN)✓ Setup completed successfully.$(RESET)"

get: ## Install Flutter dependencies (flutter pub get)
	@echo "$(CYAN)→ Getting packages with $(FLUTTER)...$(RESET)"
	@$(FLUTTER) pub get

upgrade: ## Upgrade dependencies (flutter pub upgrade)
	@echo "$(CYAN)→ Upgrading packages with $(FLUTTER)...$(RESET)"
	@$(FLUTTER) pub upgrade

clean: ## Clean Flutter build cache and artifacts
	@echo "$(YELLOW)→ Cleaning project with $(FLUTTER)...$(RESET)"
	@$(FLUTTER) clean
	@rm -rf coverage/
	@rm -rf build/

## ⚙️ Code Generation
build-runner: ## Run build_runner once to generate files
	@echo "$(CYAN)→ Running build_runner with $(DART)...$(RESET)"
	@$(DART) run build_runner build --delete-conflicting-outputs

watch: ## Watch and rebuild generated files on change
	@echo "$(CYAN)→ Watching build_runner with $(DART)...$(RESET)"
	@$(DART) run build_runner watch --delete-conflicting-outputs

## 🔍 Code Quality & Testing
format: ## Format Dart code (line-length 120)
	@echo "$(CYAN)→ Formatting code with $(DART)...$(RESET)"
	@$(DART) format --line-length=120 lib test

lint: analyze ## Run linter and static analysis
analyze: ## Run flutter analyze
	@echo "$(CYAN)→ Running static analysis with $(FLUTTER)...$(RESET)"
	@$(FLUTTER) analyze

test: ## Run unit and widget tests
	@echo "$(CYAN)→ Running tests with $(FLUTTER)...$(RESET)"
	@$(FLUTTER) test

coverage: ## Run tests with code coverage report
	@echo "$(CYAN)→ Running tests with coverage...$(RESET)"
	@$(FLUTTER) test --coverage
	@if command -v genhtml > /dev/null; then \
		echo "$(GREEN)→ Generating HTML coverage report...$(RESET)"; \
		genhtml coverage/lcov.info -o coverage/html; \
		echo "$(GREEN)✓ Coverage report available at coverage/html/index.html$(RESET)"; \
	else \
		echo "$(YELLOW)⚠ genhtml not found. Install lcov to generate HTML coverage report.$(RESET)"; \
	fi

check: format lint test ## Run format, lint, and test sequentially

## 📱 Android Builds (Flavors)
build-apk-dev: ## Build Android APK (Flavor: dev)
	@echo "$(CYAN)→ Building APK (dev)...$(RESET)"
	@$(FLUTTER) build apk --flavor dev -t lib/main_dev.dart

build-apk-stg: ## Build Android APK (Flavor: staging)
	@echo "$(CYAN)→ Building APK (staging)...$(RESET)"
	@$(FLUTTER) build apk --flavor staging -t lib/main_stg.dart

build-apk-prod: ## Build Android APK with split per ABI (Flavor: prod)
	@echo "$(CYAN)→ Building APK split-per-abi (prod)...$(RESET)"
	@$(FLUTTER) build apk --flavor prod -t lib/main.dart --split-per-abi --obfuscate --split-debug-info=build/app/outputs/symbols

build-appbundle-dev: ## Build Android AppBundle (Flavor: dev)
	@echo "$(CYAN)→ Building AppBundle (dev)...$(RESET)"
	@$(FLUTTER) build appbundle --flavor dev -t lib/main_dev.dart

build-appbundle-stg: ## Build Android AppBundle (Flavor: staging)
	@echo "$(CYAN)→ Building AppBundle (staging)...$(RESET)"
	@$(FLUTTER) build appbundle --flavor staging -t lib/main_stg.dart

build-appbundle-prod: ## Build Production AppBundle with obfuscation (Flavor: prod)
	@echo "$(CYAN)→ Building Production AppBundle (prod)...$(RESET)"
	@$(FLUTTER) build appbundle --flavor prod -t lib/main.dart --obfuscate --split-debug-info=build/app/outputs/symbols

## 🍎 iOS Builds (Flavors)
build-ios-dev: ## Build iOS (Flavor: dev, no codesign)
	@echo "$(CYAN)→ Building iOS (dev)...$(RESET)"
	@$(FLUTTER) build ios --flavor dev -t lib/main_dev.dart --no-codesign

build-ios-stg: ## Build iOS (Flavor: staging, no codesign)
	@echo "$(CYAN)→ Building iOS (staging)...$(RESET)"
	@$(FLUTTER) build ios --flavor staging -t lib/main_stg.dart --no-codesign

build-ios-prod: ## Build iOS Release with obfuscation (Flavor: prod)
	@echo "$(CYAN)→ Building iOS (prod)...$(RESET)"
	@$(FLUTTER) build ipa --flavor prod -t lib/main.dart --obfuscate --split-debug-info=build/ios/symbols
