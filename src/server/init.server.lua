-- Infrastructure smoke test: proves Rojo sync and shared-module replication end to end.
-- No gameplay service exists yet by design — systems land only after their experience doc (T1-T4) is approved.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local version = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Version"))

print(
	("[Project001][Server] booted — v%d.%d.%d (%s)"):format(
		version.major,
		version.minor,
		version.patch,
		version.stage
	)
)
