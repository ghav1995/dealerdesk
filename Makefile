# Build, run and test DealerDesk. Use from the repository root on Linux, macOS or WSL.

ifeq ($(origin CC),default)
CC := gcc
endif
CFLAGS ?= -Wall -Wextra
LDLIBS := -lm

SRC_DIR   := app/src
BUILD_DIR := app/build
APP       := app/dealerdesk
SRCS      := $(wildcard $(SRC_DIR)/*.c)
HDRS      := $(wildcard $(SRC_DIR)/*.h)

UNIT_SRCS := $(wildcard app/tests/unit/test_*.c)
UNIT_BINS := $(patsubst app/tests/unit/%.c,$(BUILD_DIR)/%,$(UNIT_SRCS))

.PHONY: all build run test test-unit clean

all: build
build: $(APP)

$(APP): $(SRCS) $(HDRS)
	$(CC) $(CFLAGS) -o $@ $(SRCS) $(LDLIBS)

# The app reads ./data relative to where it runs, so it must start from app/.
run: $(APP)
	cd app && ./dealerdesk

test: test-unit

test-unit: $(UNIT_BINS)
	@for t in $(UNIT_BINS); do echo "== $$t"; $$t || exit 1; done

$(BUILD_DIR)/test_%: app/tests/unit/test_%.c $(SRC_DIR)/calc.c $(HDRS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) -I$(SRC_DIR) -o $@ $< $(SRC_DIR)/calc.c $(LDLIBS)

clean:
	rm -rf $(BUILD_DIR) $(APP)
