local mod = IsaacD

--Classes
local game = Game()
local room = game:GetRoom()
local level = game:GetLevel()
local HUD = game:GetHUD()
local SFX = SFXManager()

--Constants
local PLUTO_NUM = 5

local GOTO_COMMAND = "stage 13"

local GRIDINDEX_BEFORE_CLOSET = 108
local CLOSET_GRIDINDEX = 94

local WISP_POSITION = Vector(5000, 5000)

--Variables
local gameHasStarted
local gameInit

--Functions (helper)
local function MakeSuperTinyAndInvisible(player)
	for i = 1, PLUTO_NUM do
		local wisp = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ITEM_WISP, CollectibleType.COLLECTIBLE_PLUTO, WISP_POSITION, Vector.Zero, player)
		wisp:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		wisp.Visible = false
	end
	player.Visible = false
end

local function DisableContinuingRun(player)
	player:Kill()
	local playerSprite = player:GetSprite()
	playerSprite.PlaybackSpeed = 0

	SFX:Stop(SoundEffect.SOUND_DEATH_BURST_SMALL)
	SFX:Stop(SoundEffect.SOUND_ISAACDIES)
end

local function GoToHomeCloset()
	Isaac.ExecuteCommand(GOTO_COMMAND)
	level:MakeRedRoomDoor(GRIDINDEX_BEFORE_CLOSET, DoorSlot.LEFT0)
	level:ChangeRoom(CLOSET_GRIDINDEX)
	level:ChangeRoom(CLOSET_GRIDINDEX)
end

local function MakeDoorInvisible()
	room:GetDoor(DoorSlot.RIGHT0):GetSprite().Scale = Vector.Zero
end

local function RemoveShopkeepersAndCollectibles()
	local success
	for _, v in pairs(Isaac.FindByType(EntityType.ENTITY_SHOPKEEPER)) do v:Remove() success = true end
	for _, v in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do v:Remove() success = true end
	return success
end

--Functions (core)
local function PostPlayerInit(_, player)
	if not (player:GetPlayerType() == mod.Enums.PlayerType.PLAYER_CAIN_D and gameHasStarted) then return end
	player:ChangePlayerType(PlayerType.PLAYER_CAIN_B)
end

local function PostPlayerUpdate(_, player)
	if not (player:GetPlayerType() == mod.Enums.PlayerType.PLAYER_CAIN_D and gameInit) then return end
	player:GetSprite().PlaybackSpeed = 0
	for _, v in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR)) do v.Visible = false end
end

local function PostGameStarted(_, isContinue)
	gameHasStarted = true

	local player = Isaac.GetPlayer(0)
	if isContinue or player:GetPlayerType() ~= mod.Enums.PlayerType.PLAYER_CAIN_D then return end

	MakeSuperTinyAndInvisible(player)
	DisableContinuingRun(player)

	if game.Difficulty <= Difficulty.DIFFICULTY_HARD then
		GoToHomeCloset()
		MakeDoorInvisible()
	end

	HUD:SetVisible(false)
	player.MoveSpeed = 0
	player.FireDelay = 2^32-1

	gameInit = true
end

local function PreGameExit()
	gameInit, gameHasStarted = false
end

local function PostNewRoom()
	if not (gameInit and level:GetCurrentRoomIndex() ~= CLOSET_GRIDINDEX) then return end
	level:ChangeRoom(CLOSET_GRIDINDEX)
	MakeDoorInvisible()
end

mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, PostGameStarted)
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, PreGameExit)
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, PostPlayerInit)
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PostPlayerUpdate)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PostNewRoom)
