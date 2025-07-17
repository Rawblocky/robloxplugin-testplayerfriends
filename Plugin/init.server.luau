local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StudioService = game:GetService("StudioService")

-- Client can't set a player's CharacterAppearance, so set in Server
if not RunService:IsServer() or RunService:IsClient() or not RunService:IsRunning() then
	return
end

local userId = StudioService:GetUserId()

local friendUserIds = {}
local friendUserIdsCache = plugin:GetSetting("friendUserIds")

local function onPlayerAdded(player: Player)
	-- Check if we're in a team test
	if player.UserId > 0 then
		return
	end

	if not friendUserIds[1] then
		-- If the player loads in too early before
		-- the game is even able to load friends,
		-- use cache
		if friendUserIdsCache and friendUserIdsCache[1] then
			player.CharacterAppearanceId = friendUserIdsCache[math.random(1, #friendUserIdsCache)]
		end
		return
	end
	local randomIndex = math.random(1, #friendUserIds)
	local randomUserId = friendUserIds[randomIndex]
	table.remove(friendUserIds, randomIndex)
	player.CharacterAppearanceId = randomUserId
end

for _, player in Players:GetPlayers() do
	task.spawn(onPlayerAdded, player)
end

Players.PlayerAdded:Connect(onPlayerAdded)

local friendPages = Players:GetFriendsAsync(userId)
repeat
	for _, friendInfo in friendPages:GetCurrentPage() do
		table.insert(friendUserIds, friendInfo.Id)
	end
	friendPages:AdvanceToNextPageAsync()
until friendPages.IsFinished

if friendUserIds[1] then
	plugin:SetSetting("friendUserIds", friendUserIds)
end
