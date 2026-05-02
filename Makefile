ifeq ($(OS),Windows_NT)
	# 1. SDK Detection (as we set up before)
	SDK_ROOT = C:/Program Files (x86)/Windows Kits/10/bin
	LATEST_SDK_VER := $(shell ls "$(SDK_ROOT)" | grep '^10\.' | sort -V | tail -n 1)
	WIN_SDK_BIN = $(SDK_ROOT)/$(LATEST_SDK_VER)/x64

	# 2. Path to the LibUI static library
	LIBUI_PATH = $(CURDIR)/lib/uing/libui/release

	# 3. Environment Injections
	export Path := $(WIN_SDK_BIN);$(Path)
	export LIBRARY_PATH := $(LIBUI_PATH);$(Path)

	# 4. Linker Flags (Explicitly include ui.lib)
	# We include standard Windows GUI libs to prevent unresolved symbol errors
	LINK_FLAGS = --link-flags="ui.lib user32.lib gdi32.lib comctl32.lib kernel32.lib shell32.lib"

	CRYSTAL_COMPILER = vfox exec crystal@1.19.1 -- crystal.exe
else
	CRYSTAL_COMPILER = crystal
endif

# CRYSTAL_COMPILER := crystal
NAME := tilex
SOURCE_DIR := src
BUILD_DIR := build
BIN_DIR := bin
LIB_DIR := lib
RM_CMD := rm -rf

ifeq ($(OS),Windows_NT)
	MKDIR_CMD := mkdir
else
	MKDIR_CMD := mkdir -p
endif

# File targets
DEBUG_BIN := $(BUILD_DIR)/$(NAME)_debug
RELEASE_BIN := $(BUILD_DIR)/$(NAME)
SOURCES := $(shell find $(SOURCE_DIR) -name "*.cr")

# Phony targets don't represent files
.PHONY: default red clean build-debug run-debug debug run build-release run-release release

# The default target, executed when you just run `make`
default: run-debug

re:
	@make -B run

clean:
	@echo "Removing build direcory...A"
	$(RM_CMD) $(BUILD_DIR)

$(BUILD_DIR):
	@echo "Creating build directory..."
	$(MKDIR_CMD) $(BUILD_DIR)

$(DEBUG_BIN): $(BUILD_DIR) src/$(NAME).cr $(SOURCES)
	@echo "Building $(NAME) (debug)..."
	$(CRYSTAL_COMPILER) build src/$(NAME).cr -o $(DEBUG_BIN) -Dstandalone -p

build-debug: $(DEBUG_BIN)

run-debug: $(DEBUG_BIN)
	@echo "Running $(NAME) (debug)..."
	./$(DEBUG_BIN)

debug: run-debug

run: run-debug

$(RELEASE_BIN): $(BUILD_DIR) src/$(NAME).cr $(SOURCES)
	@echo "Building $(NAME) (release)..."
	$(CRYSTAL_COMPILER) build src/$(NAME).cr -o $(RELEASE_BIN) --no-debug --release -p

build-release: $(RELEASE_BIN)

run-release: $(RELEASE_BIN)
	@echo "Running $(NAME) (release)..."
	./$(RELEASE_BIN)

release: run-release
