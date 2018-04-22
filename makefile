DC      ?= dmd
MKDIR_P ?= mkdir -p

BUILD_DIR ?= build
SRC_DIR   ?= chd

C_LIB_OBJS ?= /usr/lib/libsodium.so

CLIENT_EXEC ?= chdc
CLIENT_SRC_DIR   ?= $(SRC_DIR)/client
# $(info $(CLIENT_SRC_DIR))
CLIENT_SRCS := $(shell find $(CLIENT_SRC_DIR) -name "*.d")
$(info $(CLIENT_SRCS))
CLIENT_OBJS := $(CLIENT_SRCS:%=$(BUILD_DIR)/%.o)
$(info $(CLIENT_OBJS))


cli: $(BUILD_DIR)/$(CLIENT_EXEC)
	./$(BUILD_DIR)/$(CLIENT_EXEC)

client: $(BUILD_DIR)/$(CLIENT_EXEC)

$(BUILD_DIR)/$(CLIENT_EXEC): $(CLIENT_OBJS)
	$(DC) $(CLIENT_OBJS) $(C_LIB_OBJS) -of=$@

$(BUILD_DIR)/%.d.o: %.d
	@$(MKDIR_P) $(dir $@)
	$(DC) -c $< -of=$@

clean:
	rm -rf build/*

.PRECIOUS: $(BUILD_DIR)/%.d.o

.PHONY: clean client run_cli
