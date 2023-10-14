VERSION = "0.1.0"

wd = nil
buf = console:createBuffer("Vs. Recorder")

function start()
	console:log("\n\n\n\n\n\n\n\n\n\n\n\nLoading Vs. Recorder...")
	wd = debug.getinfo(start).source:match("@?(.*[/\\])") or ""
	dofile(wd .. "src/constants.lua")
	dofile(wd .. "src/util.lua")
	dofile(wd .. "src/recorder.lua")
	dofile(wd .. "src/network.lua")
	callbacks:add("frame", update)
	callbacks:add("reset", updateGame)
	callbacks:add("start", updateGame)
	updateGame()
	setupServer()
	console:log("Vs. Recorder started!")
end

start()
