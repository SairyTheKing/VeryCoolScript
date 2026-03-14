local Modal = loadstring(game:HttpGet("https://github.com/lxte/Modal/releases/latest/download/main.lua"))()

local Window = Modal:CreateWindow({
    Title    = "VoidSeen Hub",
    SubTitle = "by Ram_",
    Size     = UDim2.fromOffset(420, 380),
    MinimumSize = Vector2.new(280, 220),
})

local MainTab = Window:AddTab("Main")

MainTab:New("Title")({
    Title = "Universal",
    Description = "Tools that work in most games"
})

MainTab:New("Button")({
    Title = "Script Searcher",
    Description = "Find and load any script",
    Callback = function()
        Window:Notify({
            Title = "Executing script...",
            Description = "Script Searcher",
            Duration = 2,
            Type = "Info"
        })
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-script-searcher-open-source-138660"))()
    end,
})

MainTab:New("Button")({
    Title = "BackFlip + FrontFlip",
    Description = "Universal flip animation",
    Callback = function()
        Window:Notify({
            Title = "Executing script...",
            Description = "BackFlip + FrontFlip",
            Duration = 2,
            Type = "Info"
        })
        loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-backflip-script-67332"))()
    end,
})

MainTab:New("Title")({
    Title = "Jujutsu Shenanigans",
    Description = "Game-specific scripts"
})

MainTab:New("Button")({
    Title = "Auto Blackflash",
    Description = "Auto Blackflash for JJS",
    Callback = function()
        Window:Notify({
            Title = "Executing script...",
            Description = "Auto Blackflash",
            Duration = 2,
            Type = "Info"
        })
        loadstring(game:HttpGet("https://rawscripts.net/raw/SALARYMAN-Jujutsu-Shenanigans-Auto-Blackflash-Open-Source-122708"))()
    end,
})

MainTab:New("Button")({
    Title = "Blackflash Chain",
    Description = "Chain blackflashes automatically (Press E to use)",
    Callback = function()
        Window:Notify({
            Title = "Executing script...",
            Description = "Blackflash Chain (E to use)",
            Duration = 2,
            Type = "Info"
        })
        loadstring(game:HttpGet("https://raw.githubusercontent.com/rimleaf/jjstze/refs/heads/main/black%20flash%20chain%20v1"))()
    end,
})

MainTab:New("Button")({
    Title = "Train Button",
    Description = "Train Button for JJS (not auto)",
    Callback = function()
        Window:Notify({
            Title = "Executing script...",
            Description = "Train Button",
            Duration = 2,
            Type = "Info"
        })
        loadstring(game:HttpGet("https://rawscripts.net/raw/PUPPET-MASTER-Jujutsu-Shenanigans-Open-Source-Train-Button-121173"))()
    end,
})

MainTab:New("Title")({
    Title = "Misc",
    Description = "tuff tuffity tuff"
})

local espEnabled = false
local espConnections = {}

local function toggleESP(state)
    if state then
        local function addHighlight(player)
            if player == game.Players.LocalPlayer then return end
            local highlight = Instance.new("Highlight")
            highlight.Name = "VoidSeen_ESP"
            highlight.FillColor = Color3.new(1, 0, 0)
            highlight.OutlineColor = Color3.new(1, 1, 1)
            highlight.FillTransparency = 0.5
            highlight.Adornee = player.Character
            highlight.Parent = player.Character
            local conn
            conn = player.CharacterAdded:Connect(function(char)
                wait(0.5)
                if espEnabled then
                    local newHighlight = highlight:Clone()
                    newHighlight.Adornee = char
                    newHighlight.Parent = char
                end
            end)
            table.insert(espConnections, conn)
        end

        for _, player in ipairs(game.Players:GetPlayers()) do
            if player.Character then
                addHighlight(player)
            end
        end

        local playerAddedConn = game.Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(char)
                wait(0.5)
                if espEnabled then
                    addHighlight(player)
                end
            end)
        end)
        table.insert(espConnections, playerAddedConn)

        Window:Notify({
            Title = "ESP",
            Description = "ESP enabled",
            Duration = 2,
            Type = "Success"
        })
    else
        for _, conn in ipairs(espConnections) do
            conn:Disconnect()
        end
        espConnections = {}
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player.Character then
                local highlight = player.Character:FindFirstChild("VoidSeen_ESP")
                if highlight then
                    highlight:Destroy()
                end
            end
        end
        Window:Notify({
            Title = "ESP",
            Description = "ESP disabled",
            Duration = 2,
            Type = "Warning"
        })
    end
    espEnabled = state
end

MainTab:New("Toggle")({
    Title = "ESP (Highlight)",
    Description = "Toggle player ESP on/off",
    DefaultValue = false,
    Callback = function(value)
        toggleESP(value)
    end,
})

MainTab:New("Button")({
    Title = "Rejoin Server",
    Description = "Leave and rejoin the same server",
    Callback = function()
        Window:Notify({
            Title = "Rejoining...",
            Description = "Please wait",
            Duration = 3,
            Type = "Info"
        })
        local ts = game:GetService("TeleportService")
        local placeId = game.PlaceId
        local jobId = game.JobId
        ts:TeleportToPlaceInstance(placeId, jobId, game.Players.LocalPlayer)
    end,
})

MainTab:New("Button")({
    Title = "Remote Spy (RSpy)",
    Description = "Spy on remote events/functions",
    Callback = function()
        Window:Notify({
            Title = "Loading Remote Spy...",
            Description = "RSpy activated",
            Duration = 2,
            Type = "Info"
        })
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua"))()
    end,
})

MainTab:New("Title")({
    Title = "Spectate",
    Description = "Watch other players"
})

local function GetPlayerNames()
    local players = {}
    local localPlayer = game.Players.LocalPlayer
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player ~= localPlayer then
            table.insert(players, player.Name)
        end
    end
    return players
end

local SpectateDropdown = MainTab:New("Dropdown")({
    Title = "Select Player",
    Description = "Choose a player to spectate",
    Options = GetPlayerNames(),
    Callback = function(selectedPlayerName)
        local target = game.Players:FindFirstChild(selectedPlayerName)
        if target and target.Character and target.Character:FindFirstChild("Humanoid") then
            local camera = workspace.CurrentCamera
            camera.CameraSubject = target.Character.Humanoid
            camera.CameraType = Enum.CameraType.Follow
            Window:Notify({
                Title = "Spectating",
                Description = "Now spectating " .. target.Name,
                Duration = 3,
                Type = "Success"
            })
        else
            Window:Notify({
                Title = "Error",
                Description = "Player not found or has no character",
                Duration = 3,
                Type = "Warning"
            })
        end
    end,
})

MainTab:New("Button")({
    Title = "Refresh Player List",
    Description = "Update the list of online players",
    Callback = function()
        local newOptions = GetPlayerNames()
        local success, err = pcall(function()
            SpectateDropdown:SetOptions(newOptions)
        end)
        if not success then
            Window:Notify({
                Title = "Refresh Failed",
                Description = "Please re-open the UI to update player list",
                Duration = 3,
                Type = "Warning"
            })
        else
            Window:Notify({
                Title = "List Refreshed",
                Description = #newOptions .. " players found",
                Duration = 2,
                Type = "Success"
            })
        end
    end,
})

MainTab:New("Button")({
    Title = "Unspectate",
    Description = "Stop spectating and return to your character",
    Callback = function()
        local localPlayer = game.Players.LocalPlayer
        if localPlayer.Character and localPlayer.Character:FindFirstChild("Humanoid") then
            local camera = workspace.CurrentCamera
            camera.CameraSubject = localPlayer.Character.Humanoid
            camera.CameraType = Enum.CameraType.Follow
            Window:Notify({
                Title = "Unspectated",
                Description = "Camera returned to you",
                Duration = 2,
                Type = "Success"
            })
        else
            Window:Notify({
                Title = "Error",
                Description = "Your character is not loaded",
                Duration = 2,
                Type = "Warning"
            })
        end
    end,
})

local SettingsTab = Window:AddTab("Settings")

SettingsTab:New("Title")({
    Title = "Themes"
})

SettingsTab:New("Dropdown")({
    Title = "Theme",
    Description = "Default theme options",
    Options = { "Light", "Dark", "Midnight", "Rose", "Emerald" },
    Callback = function(Theme)
        Window:Notify({
            Title = "Theme Changed",
            Description = "New theme: " .. Theme,
            Duration = 2,
            Type = "Success"
        })
        Window:SetTheme(Theme)
    end,
})

SettingsTab:New("Button")({
    Title = "Destroy GUI",
    Description = "Click to completely remove the UI",
    Callback = function()
        Window:Notify({
            Title = "Goodbye!",
            Description = "Destroying interface...",
            Duration = 2,
            Type = "Warning"
        })
        task.wait(0.5)
        Window:Destroy()
    end,
})

Window:SetTheme("Midnight")
Window:SetTab("Main")

local UserInputService = game:GetService("UserInputService")
local NotificationKey = Enum.KeyCode.F1

UserInputService.InputBegan:Connect(function(Input, gameProcessed)
    if gameProcessed then return end
    if Input.KeyCode == NotificationKey then
        Window:Notify({
            Title = "VoidSeen Hub",
            Description = "Keybind F1 triggered!",
            Duration = 4,
            Type = "Success"
        })
    end
end)
