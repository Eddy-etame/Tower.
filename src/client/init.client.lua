-- Infrastructure smoke test: proves client sync and shared-module replication.
-- The client renders and requests; the server decides — server-authoritative from day one.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local version = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Version"))

print(
	("[Project001][Client] booted — v%d.%d.%d (%s)"):format(
		version.major,
		version.minor,
		version.patch,
		version.stage
	)
)
