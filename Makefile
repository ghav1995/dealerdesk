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

.PHONY: all build run test test-unit test-integration golden version clean

all: build
build: $(APP)

$(APP): $(SRCS) $(HDRS)
	$(CC) $(CFLAGS) -o $@ $(SRCS) $(LDLIBS)

# The app reads ./data relative to where it runs, so it must start from app/.
run: $(APP)
	cd app && ./dealerdesk

test: test-unit test-integration

test-unit: $(UNIT_BINS)
	@for t in $(UNIT_BINS); do echo "== $$t"; $$t || exit 1; done

$(BUILD_DIR)/test_%: app/tests/unit/test_%.c $(SRC_DIR)/calc.c $(HDRS)
	@mkdir -p $(BUILD_DIR)
	$(CC) $(CFLAGS) -I$(SRC_DIR) -o $@ $< $(SRC_DIR)/calc.c $(LDLIBS)

test-integration: $(APP)
	bash app/tests/integration/run.sh $(APP)

# Rewrites the expected screens and data files. Only for an intended, specified
# behaviour change, and review the resulting diff before committing it.
golden: $(APP)
	bash app/tests/integration/run.sh $(APP) --update

# Prints the version from the screen header, for example v2.4.
version:
	@grep -o -E 'DEALERDESK v[0-9]+\.[0-9]+' $(SRC_DIR)/screen.c | cut -d' ' -f2

clean:
	rm -rf $(BUILD_DIR) $(APP)
