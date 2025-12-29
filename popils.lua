--This is an example Lua (https://www.lua.org) script to give a general idea of how to build scripts
--Press F5 or click the Run button to execute it
--Type "emu." to show a list of all available API function

function printMusic(address, value)
	if value ~= 0 then
		emu.displayMessage("music", emu.read(0x600, emu.memType.nesDebug, false))
	end
end

function printSfx(address, value)
	if value ~= 0 then
		emu.displayMessage("sfx", emu.read(0x601, emu.memType.nesDebug, false))
	end
end

--Register some code (printInfo function) that will be run at the end of each frame
emu.addMemoryCallback(printMusic, emu.callbackType.write, 0x600, 0x600, emu.cpuType.nes)
emu.addMemoryCallback(printSfx, emu.callbackType.write, 0x601, 0x601, emu.cpuType.nes)

--Display a startup message
emu.displayMessage("Script", "Example Lua script loaded.")