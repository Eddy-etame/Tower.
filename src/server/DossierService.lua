-- The climax, staged in the room. When the subject enters the annex, the file wall fills — one true
-- observation about them at a time — then the central board types the live line while they stand reading it.
-- Multiplayer note: the file wall shows the FIRST player to trigger the reveal; a shared 3D surface can only
-- tell one story at once. For the single-player prototype this is correct; co-op gets per-player instancing
-- when we get there (tracked, not hidden). When the live line finishes, the exit door unseals.

local Blockout = require(script.Parent.Blockout)
local BehaviorProfile = require(script.Parent.BehaviorProfile)

local DossierService = {}

local world, tuning, SessionLog, onComplete
local revealing = false

function DossierService.init(worldHandles, sliceTuning, sessionLog, completeCallback)
	world = worldHandles
	tuning = sliceTuning
	SessionLog = sessionLog
	onComplete = completeCallback
end

function DossierService.isRevealing()
	return revealing
end

-- Triggered when a player enters the annex for the first time this run.
function DossierService.reveal(player)
	if revealing then
		return
	end
	revealing = true
	Blockout.clearFile(world)

	task.spawn(function()
		local lines = BehaviorProfile.composeFile(player, SessionLog)
		-- fill the wall one sheet at a time — the room writing you up, live
		for index = 1, #world.filePanels do
			local text = lines[index]
			if text then
				Blockout.fillPanel(world, index, text)
				world.scratchSound.PlaybackSpeed = tuning.SCRATCH_SPEED
				world.scratchSound:Play()
			end
			task.wait(tuning.PANEL_REVEAL_SECONDS)
		end

		task.wait(tuning.LIVE_LINE_DELAY_SECONDS)

		-- the violation: it writes about you reading it, right now, as you watch
		local live = BehaviorProfile.liveLine()
		for charIndex = 1, #live do
			Blockout.setLiveLine(world, string.sub(live, 1, charIndex))
			task.wait(tuning.LIVE_LINE_CHAR_SECONDS)
		end

		task.wait(tuning.POST_REVEAL_SECONDS)
		revealing = false
		if onComplete then
			onComplete(player)
		end
	end)
end

function DossierService.resetReveal()
	revealing = false
	if world then
		Blockout.clearFile(world)
	end
end

return DossierService
