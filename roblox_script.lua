-- [[ AI BRAIN CONFIGURATION ]]
local CONFIG = {
    ENABLED = true,
    API_URL = "http://localhost:5000/api/chat",
    MAX_DISTANCE = 35,
    
    -- AI PARAMETERS (Full Control)
    MODEL = "llama-3.3-70b-versatile",
    TEMPERATURE = 0.9, -- High creativity
    MAX_TOKENS = 80,   -- Keep it short for Roblox
    MEMORY_LIMIT = 12, -- How many messages to remember
    
    -- THE BRAIN (Change this to change personality)
    SYSTEM_PROMPT = [[
        You are a funny, slightly chaotic Roblox player. 
        Current Username: ]] .. game:GetService("Players").LocalPlayer.DisplayName .. [[.
        Context: You are in a Roblox game.
        Instructions:
        - Use slang like: fr, noob, lol, bruh, skibidi, cap, afk.
        - Keep responses under 20 words.
        - If someone asks who you are, say you're a pro gamer.
        - NEVER say you are an AI.
        - Be responsive to the specific things players say.
    ]]
}

-- SERVICES
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- STATE: Memory lives here, not on the server
local ChatHistory = {
    { role = "system", content = CONFIG.SYSTEM_PROMPT }
}

local function sendMessage(text)
    local isModern = TextChatService.ChatVersion == Enum.ChatVersion.TextChatService
    if isModern then
        local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
        if channel then channel:SendAsync(text) end
    else
        local event = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
        if event then event.SayMessageRequest:FireServer(text, "All") end
    end
end

local function getAIResponse()
    local success, response = pcall(function()
        return (syn and syn.request or http_request or request)({
            Url = CONFIG.API_URL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode({
                messages = ChatHistory,
                model = CONFIG.MODEL,
                temperature = CONFIG.TEMPERATURE,
                max_tokens = CONFIG.MAX_TOKENS
            })
        })
    end)

    if success and response.StatusCode == 200 then
        return HttpService:JSONDecode(response.Body).reply
    end
    return nil
end

local function onChatted(sender, message)
    if not CONFIG.ENABLED or sender == LocalPlayer then return end
    
    -- Check Distance
    local char = sender.Character
    local myChar = LocalPlayer.Character
    if not (char and myChar and char:FindFirstChild("HumanoidRootPart")) then return end
    if (char.HumanoidRootPart.Position - myChar.HumanoidRootPart.Position).Magnitude > CONFIG.MAX_DISTANCE then return end

    -- Add to Memory
    table.insert(ChatHistory, { role = "user", content = sender.DisplayName .. ": " .. message })

    -- Trim Memory (Keep system prompt at index 1)
    if #ChatHistory > CONFIG.MEMORY_LIMIT then
        table.remove(ChatHistory, 2)
    end

    -- Process Response
    local reply = getAIResponse()
    if reply then
        table.insert(ChatHistory, { role = "assistant", content = reply })
        sendMessage(reply)
    end
end

-- INITIALIZE LISTENERS
if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
    TextChatService.MessageReceived:Connect(function(msg)
        if msg.TextSource then
            local sender = Players:GetPlayerByUserId(msg.TextSource.UserId)
            if sender then onChatted(sender, msg.Text) end
        end
    end)
else
    Players.PlayerChatted:Connect(function(_, sender, message)
        onChatted(sender, message)
    end)
end

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "AI Brain Loaded",
    Text = "Using: " .. CONFIG.MODEL,
    Duration = 5
})
