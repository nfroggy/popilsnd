#include <cstdio>
#include <cstdint>

#include <array>
#include <format>
#include <map>
#include <string>
#include <vector>

static constexpr size_t ROM_SIZE = 0x20000;
static constexpr size_t BANK_OFFSET = 0x1c000;
static constexpr uint16_t BANK_MEM_ADDR = 0x8000;

static constexpr uint16_t SOUND_TBL_ADDR = 0x8833;

static constexpr int NUM_CHANNELS = 4;
static constexpr size_t MAX_CMD_PARAM_SIZE = 4;

static std::array<uint8_t, ROM_SIZE> romData;

static uint8_t getByte(uint16_t addr) {
	return romData.at(BANK_OFFSET + addr - BANK_MEM_ADDR);
}

static uint16_t getWord(uint16_t addr) {
	return getByte(addr) | (getByte(addr + 1) << 8);
}

typedef struct {
	uint8_t value;
	std::string name;
	int paramSize;
	bool skipped;
} CommandInfo;

static constexpr uint8_t CMD_GOTO = 0x86;
static constexpr uint8_t CMD_END = 0x87;
static constexpr uint8_t CMD_INIT = 0x8a;

const CommandInfo commandSet[] = {
	{0x80, "CMD_SET_ENV_OFFSET", 1, false},
	{0x81, "CMD_SET_ENV_TYPE", 1, false},
	{0x82, "CMD_SET_TEMPO", 1, false},
	{0x83, "CMD_IDK1", 1, true},
	{0x84, "CMD_SET_SWEEP_TYPE", 1, false},
	{0x85, "CMD_SET_FREQ_OFFSET", 1, true},
	{0x86, "CMD_GOTO", 2, false},
	{0x87, "CMD_END", 0, false},
	{0x88, "CMD_SET_TRANSPOSE", 1, false},
	{0x89, "CMD_REST", 1, false},
	{0x8a, "CMD_INIT", 4, false}
};

struct Command;
typedef struct Command {
	const CommandInfo *cmd;
	union {
		uint16_t addr;
		std::array<uint8_t, MAX_CMD_PARAM_SIZE> params;
	} data;
	bool isGotoDest;
	struct Command *gotoDest;
} Command;

typedef struct {
	uint8_t id;
	std::array<std::map<uint16_t, Command>, NUM_CHANNELS> channels;
} Sound;

static void getChannelData(std::map<uint16_t, Command> *cmdMap, uint16_t addr) {
	while (1) {
		Command &command = (*cmdMap)[addr];
		command = {};
		uint8_t cmdByte = getByte(addr++);
		// engine command
		if (cmdByte & 0x80) {
			command.cmd = &commandSet[cmdByte & 0xf];
			if (cmdByte == CMD_GOTO) {
				command.data.addr = getWord(addr); addr += 2;
				Command &dest = cmdMap->at(command.data.addr);
				dest.isGotoDest = true;
				command.gotoDest = &dest;
			}
			else {
				for (int i = 0; i < command.cmd->paramSize; i++) {
					command.data.params[i] = getByte(addr++);
				}
			}
			if ((cmdByte == CMD_GOTO) || (cmdByte == CMD_END)) {
				break;
			}
		}
		// note
		else {
			command.cmd = nullptr;
			command.data.params[0] = cmdByte; // note
			uint8_t lenByte = getByte(addr++);
			command.data.params[1] = lenByte;
		}
	}
}

static void writeChannelData(FILE *fp, std::map<uint16_t, Command> *cmdMap, std::string prefix) {
	for (std::map<uint16_t, Command>::iterator i = cmdMap->begin(); i != cmdMap->end(); i++) {
		uint16_t addr = i->first;
		Command &command = i->second;
		if (command.isGotoDest) {
			fprintf(fp, "%sLoop:\n", prefix.c_str());
		}
		if (command.cmd) {
			if (!command.cmd->skipped) {
				if (command.cmd->value == CMD_GOTO) {
					fprintf(fp, "\t.byte %s\n\t.word %s\n", command.cmd->name.c_str(), std::string(prefix + "Loop").c_str());
				}
				else if (command.cmd->value == CMD_INIT) {
					fprintf(fp, "\t.byte CMD_SET_ENV_TYPE, $%02x\n", command.data.params[1]);
					fprintf(fp, "\t.byte CMD_SET_SWEEP_TYPE, $%02x\n", command.data.params[2]);
					fprintf(fp, "\t.byte CMD_SET_ENV_OFFSET, $%02x\n", command.data.params[3]);
				}
				else {
					fprintf(fp, "\t.byte %s", command.cmd->name.c_str());
					int numParams = command.cmd->paramSize;
					for (int i = 0; i < numParams; i++) {
						fprintf(fp, ", $%02x", command.data.params[i]);
					}
					fprintf(fp, "\n");
				}
			}
		}
		else { // note data
			fprintf(fp, "\t.byte $%02x, $%02x\n", command.data.params[0], command.data.params[1]);
		}
	}
}

static void getSoundData(int id, std::string name, int8_t transpose) {
	Sound sound;
	sound.id = id;
	uint16_t soundAddr = SOUND_TBL_ADDR + (id * NUM_CHANNELS * sizeof(uint16_t));
	for (int i = 0; i < NUM_CHANNELS; i++) {
		uint16_t chanAddr = getWord(soundAddr + i * sizeof(uint16_t));
		if (chanAddr) {
			getChannelData(&sound.channels[i], chanAddr);
		}
	}

	std::string filename = std::format("{}.asm", name);
	FILE *out = fopen(filename.c_str(), "w");
	for (int i = 0; i < NUM_CHANNELS; i++) {
		std::string prefix = std::format("{}Ch{}", name, i);
		if (!sound.channels[i].empty()) {
			fprintf(out, ".export\t%s\n%s:\n", prefix.c_str(), prefix.c_str());
			if (transpose) {
				fprintf(out, "\t.byte CMD_TRANSPOSE, $%02x\n", transpose);
			}
			writeChannelData(out, &sound.channels[i], prefix);
		}
	}
	fclose(out);
}

int main(int argc, char **argv) {
	FILE *fp = fopen("popils.gg", "rb");
	fread(romData.data(), 1, ROM_SIZE, fp);
	fclose(fp);

	getSoundData(1, "tengenLogo", 12);
	getSoundData(17, "attract", 7);
	getSoundData(19, "title", 12);
	getSoundData(22, "menu", 12);
	getSoundData(23, "level", 12);

	return 0;
}