local Players = game:GetService("Players")
 
local kickCommand = "/kick "
 
local function onOwnerChatted(player, message)
	if message:sub(1, kickCommand:len()):lower() == kickCommand:lower() then
		local name = message:sub(kickCommand:len() + 1)
		local playerToKick = Players:FindFirstChild(name)
		if playerToKick then
			playerToKick:Kick("You have been kicked by the owner.")
		else
			-- Couldn't find the player in question
		end
	end
end
 
local function onPlayerAdded(player)
	-- Restrict this command to only the creator/owner
	if player.UserId == game.CreatorId and game.CreatorType == Enum.CreatorType.User then
		player.Chatted:Connect(function (...)
			onOwnerChatted(player, ...)
		end)
	end
end
 
-- Listen for players being added
for _, player in pairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end
Players.PlayerAdded:Connect(onPlayerAdded)
