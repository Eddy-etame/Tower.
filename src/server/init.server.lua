-- Project 001 — one playable experience: Beginning -> four Encounters -> Ending -> (loop). Server-authoritative.
-- GameService runs the flow; each stage is one module (Rule 21: architecture + interface before content).
-- Encounter I (The Watcher) is real; II-IV are honest labeled STUBs (Rule 2), each one file to fill in.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local version = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Version"))
local tuning = require(ReplicatedStorage.Shared.SliceTuning)
local GameService = require(script.GameService)

print(
	("[Project001][Server] booted — v%d.%d.%d (%s)"):format(
		version.major,
		version.minor,
		version.patch,
		version.stage
	)
)

local uiRemote = Instance.new("RemoteEvent")
uiRemote.Name = "MvpUI"
uiRemote.Parent = ReplicatedStorage

-- client -> server flashlight toggle intent (server owns the battery) + server -> client light state
local flashlightRemote = Instance.new("RemoteEvent")
flashlightRemote.Name = "Flashlight"
flashlightRemote.Parent = ReplicatedStorage

local stages = {
	require(script.stages.Beginning),
	require(script.stages.Encounter_TheWatcher),
	require(script.stages.Encounter_ViolentRhythm),
	require(script.stages.Encounter_HiddenPresence),
	require(script.stages.Encounter_MoralCollapse),
	require(script.stages.Ending),
}

GameService.init(stages, tuning, uiRemote, flashlightRemote)
