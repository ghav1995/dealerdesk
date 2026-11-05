# Build and run DealerDesk. Use from the repository root on Linux, macOS or WSL.

ifeq ($(origin CC),default)
CC := gcc
endif
CFLAGS ?= -Wall -Wextra
LDLIBS := -lm

SRC_DIR := app/src
APP     := app/dealerdesk
SRCS    := $(wildcard $(SRC_DIR)/*.c)
HDRS    := $(wildcard $(SRC_DIR)/*.h)

.PHONY: all build run clean

all: build
build: $(APP)

$(APP): $(SRCS) $(HDRS)
	$(CC) $(CFLAGS) -o $@ $(SRCS) $(LDLIBS)

# The app reads ./data relative to where it runs, so it must start from app/.
run: $(APP)
	cd app && ./dealerdesk

clean:
	rm -f $(APP)
