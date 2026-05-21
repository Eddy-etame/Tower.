-- init.server.lua
local ServerScriptService = game:GetService("ServerScriptService")
local Services = ServerScriptService.Server.services

print("[Horror Castle Server] Initializing services...")

-- Dynamically require and initialize all services under services/
for _, module in ipairs(Services:GetChildren()) do
    if module:IsA("ModuleScript") then
        local success, service = pcall(require, module)
        if success and type(service) == "table" and type(service.Init) == "function" then
            print("[Horror Castle Server] Initializing service:", module.Name)
            task.spawn(function()
                service:Init()
            end)
        else
            warn("[Horror Castle Server] Failed to load service:", module.Name, "Error:", service)
        end
    end
end

print("[Horror Castle Server] Services successfully initialized!")
