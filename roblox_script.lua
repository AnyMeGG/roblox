local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TextChatService = game:GetService("TextChatService")

local url = "http://localhost:5000/api/chat?text="

local function notify(title, text)
    StarterGui:SetCore("SendNotification", { Title = title; Text = text; Duration = 5; })
end

-- Load UI Library
local libUrl = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua'
local gui = loadstring(game:HttpGet(libUrl))()
local Window = gui:CreateWindow({ Title = 'Groq AI Chatbot', Center = true, AutoShow = true })
local MainTab = Window:AddTab('Main')
local Group = MainTab:AddLeftGroupBox('Settings')

local Enabled = true
local Distance = 20

Group:AddToggle('Enabled', { Text = 'Enable Chatbot', Default = true }):OnChanged(function(v) Enabled = v end)
Group:AddSlider('Distance', { Text = 'Response Distance', Default = 20, Min = 0, Max = 100, Rounding = 1 }):OnChanged(function(v) Distance = v end)

local function chat(text)
    local channel = TextChatService.TextChannels.RBXGeneral
    if channel then
        channel:SendAsync(text)
    end
end

local function onChatMessage(player, text)
    if not Enabled or player == Players.LocalPlayer then return end
    
    local char = player.Character
    local myChar = Players.LocalPlayer.Character
    if not char or not myChar then return end

    local dist = (char.HumanoidRootPart.Position - myChar.HumanoidRootPart.Position).Magnitude
    if dist > Distance then return end

    local success, response = pcall(function()
        return syn.request({ Url = url .. HttpService:UrlEncode(player.Name .. " said: " .. text), Method = "GET" })
    end)

    if success then
        local data = HttpService:JSONDecode(response.Body)
        if data.reply then chat(data.reply) end
    end
end

-- Init
pcall(function() syn.request({ Url = "http://localhost:5000/api/clear" }) end)
local prompt = "You are a chill Roblox player. Your name is " .. Players.LocalPlayer.Name .. ". Keep replies short."
pcall(function() syn.request({ Url = url .. HttpService:UrlEncode(prompt) }) end)

TextChatService.MessageReceived:Connect(function(msg)
    local p = Players:GetPlayerByUserId(msg.TextSource.UserId)
    if p then onChatMessage(p, msg.Text) end
end)

notify("Groq Bot", "AI Ready and Fast!")
