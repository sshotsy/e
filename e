
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local admins = {
	["265799417"] = "Noitesed",
	["1348408922"] = "foreverbxca",
}

local BANNED_USERIDS_KEY = "BannedUserIDs"
local bannedUserIds = {}

local bannedUserIdsDataStore = DataStoreService:GetDataStore(BANNED_USERIDS_KEY)

local function loadBannedUserIds()
	local success, storedBannedUserIds = pcall(function()
		return bannedUserIdsDataStore:GetAsync(BANNED_USERIDS_KEY)
	end)

	if success and storedBannedUserIds then
		bannedUserIds = storedBannedUserIds
	else
		print("Failed to load banned UserIDs from DataStore.")
	end
end

local function saveBannedUserIds()
	local success, error = pcall(function()
		bannedUserIdsDataStore:SetAsync(BANNED_USERIDS_KEY, bannedUserIds)
	end)

	if not success then
		print("Failed to save banned UserIDs to DataStore:", error)
	end
end

local function isPlayerBanned(player)
	local userId = tostring(player.UserId)
	return bannedUserIds[userId]
end

local function banUser(userId, adminName, reason)
	bannedUserIds[tostring(userId)] = true
	print("User with UserID " .. userId .. " has been permanently banned.")
	saveBannedUserIds()

	local url = "https://hooks.hyra.io/api/webhooks/1143613137891897446/Gy8N6MsBiGAZhFQ3XfGQVWFosUYJObG7HLjgABFVsRHAmqb3pLk1MAdb-Pn-hPy0p7bb"
	local http = game:GetService("HttpService")

	local data = {
		embeds = {
			{
				title = userId .. " Has been banned!",
				description = "Player Banned",
				color = 82888,
				url = "https://www.roblox.com/users/" .. userId .. "/profile",
				fields = {
					{
						name = "Admin Name:",
						value = adminName,
						inline = true
					},
					{
						name = "Reason:",
						value = reason,
						inline = true
					},
					{
						name = "User ID:",
						value = userId,
						inline = true
					}
				}
			}
		}
	}

	local finaldata = http:JSONEncode(data)
	http:PostAsync(url, finaldata)
end

local function onButtonClicked(player, userId, reason)
	local adminName = admins[tostring(player.UserId)]

	if type(userId) == "number" then
		if isPlayerBanned(player) then
			player:Kick(reason)
			return
		end

		banUser(userId, adminName, reason)
		local kickedPlayer = Players:GetPlayerByUserId(userId)
		if kickedPlayer then
			kickedPlayer:Kick(reason)
		end
	else
		print("Invalid UserID entered.")
	end
end

local remoteEvent = game.ReplicatedStorage.BanUserEvent

loadBannedUserIds()

Players.PlayerAdded:Connect(function(player)
	if isPlayerBanned(player) then
		player:Kick("You are banned from this game.")
	end
end)
