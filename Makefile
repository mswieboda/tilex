CRYSTAL_COMPILER := crystal
NAME := tilex
SOURCE_DIR := src
BUILD_DIR := build
BIN_DIR := bin
LIB_DIR := lib
RM_CMD := rm -rf
MKDIR_CMD := mkdir -p

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
	@echo "Removing build direcory..."
	$(RM_CMD) $(BUILD_DIR)

$(BUILD_DIR):
	@echo "Creating build directory..."
	$(MKDIR_CMD) $(BUILD_DIR)

$(DEBUG_BIN): $(BUILD_DIR) src/$(NAME).cr $(SOURCES)
	@echo "Building $(NAME) (debug)..."
	$(MKDIR_CMD) $(BUILD_DIR)
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
