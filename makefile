
DC      ?= dmd
MKDIR_P ?= mkdir -p

BUILD_DIR ?= build
SRC_DIR   ?= src

C_LIB_OBJS ?= /usr/local/lib/libsodium.a

CLIENT_EXEC ?= chdc
CLIENT_BUILD_DIR ?= $(BUILD_DIR)/client
CLIENT_SRC_DIR   ?= $(SRC_DIR)/client
# $(info $(CLIENT_SRC_DIR))
CLIENT_SRCS := $(shell find $(CLIENT_SRC_DIR) -name "*.d")
# $(info $(CLIENT_SRCS))
CLIENT_OBJS := $(CLIENT_SRCS:%=$(CLIENT_BUILD_DIR)/%.o)
# $(info $(CLIENT_OBJS))


cli: $(BUILD_DIR)/$(CLIENT_EXEC)
	./$(BUILD_DIR)/$(CLIENT_EXEC)

client: $(BUILD_DIR)/$(CLIENT_EXEC)

$(BUILD_DIR)/$(CLIENT_EXEC): $(CLIENT_OBJS)
	$(DC) $(CLIENT_OBJS) $(C_LIB_OBJS) -of=$@

$(CLIENT_BUILD_DIR)/%.o: $(CLIENT_SRCS)
	@$(MKDIR_P) $(dir $@)
	$(DC) -c $< -of=$@

clean:
	rm -rf build/*

.PHONY: clean client run_cli
