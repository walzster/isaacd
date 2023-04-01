local mod = IsaacD

--Classes
local game = Game()
local level = game:GetLevel()

--Constants
local NUM_STARTING_DICE_HEARTS = 6

local PLAYER_TYPE = mod.Enums.PlayerType.PLAYER_ISAAC_D
local PLAYER_MAX_HEART_REPLACEMENT = "DICE_HEART_1"
local PLAYER_OTHER_VALID_HEARTS = {["EMPTY_HEART"] = true, ["BROKEN_HEART"] = true}

local DICE_HEART_TURN_SUCCESS_RATE = 50
local DICE_HEART_TURN_SUCCESS_RATE_BIRTHRIGHT = 80

local POSSIBLE_PICKUP_MORPH_VARIANTS = { PickupVariant.PICKUP_COIN, PickupVariant.PICKUP_KEY, PickupVariant.PICKUP_BOMB }

--Variables
mod.IsaacDHealthBackup = {}

--Functions (helper)
local function IsCorrectPlayer(player) return player:GetPlayerType() == PLAYER_TYPE end
local function ShouldGivePocketItem(player) return not (player:HasCurseMistEffect() or player:HasCollectible(mod.Enums.CollectibleType.COLLECTIBLE_ISAACD_POCKET)) end
local function RemoveAllPossibleBrokenHearts(player) CustomHealthAPI.Library.AddHealth(player, "BROKEN_HEART", -CustomHealthAPI.Library.GetHPOfKey(player, "BROKEN_HEART")) end
local function RemoveSoulHearts(player) CustomHealthAPI.Library.AddHealth(player, "SOUL_HEART", -CustomHealthAPI.Library.GetHPOfKey(player, "SOUL_HEART", false, true)) end
local function AddNullCostumeItemWhenNeeded(player)
    local playerEffects = player:GetEffects()
    if playerEffects:HasNullEffect(IsaacD.Enums.NullItemID.ID_ISAACD_COSTUME) then return end
    playerEffects:AddNullEffect(IsaacD.Enums.NullItemID.ID_ISAACD_COSTUME)
    player:Update()
end
local function GivePlayerWaferEffect(player) player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_WAFER) end

local function HealthBackupExists(player) return mod.IsaacDHealthBackup[GetPtrHash(player)] end
local function LoadAndNilHealthBackup(player) CustomHealthAPI.Library.LoadHealthFromBackup(mod.IsaacDHealthBackup[GetPtrHash(player)]) mod.IsaacDHealthBackup[GetPtrHash(player)] = nil end

local function IsValidHeart(key) return key:find("DICE_HEART_") or PLAYER_OTHER_VALID_HEARTS[key] end
local function AddPlayerHealthBackup(player) mod.IsaacDHealthBackup[GetPtrHash(player)] = CustomHealthAPI.Library.GetHealthBackup(player) end

local function GetIfIsaacDExistsAndIfOtherPlayersExist()
    local isaacDExists, otherPlayersExist, isaacDHasBirthright
    for _, entityPlayer in pairs(Isaac.FindByType(EntityType.ENTITY_PLAYER)) do
        local player = entityPlayer:ToPlayer()
        if player:GetPlayerType() == mod.Enums.PlayerType.PLAYER_ISAAC_D then
            isaacDExists = true
            isaacDHasBirthright = isaacDHasBirthright or player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
        else
            otherPlayersExist = true
        end
    end
    return isaacDExists, otherPlayersExist, isaacDHasBirthright
end

--Functions (callback)
function mod:IsaacDPostPlayerUpdate(player)
    if not IsCorrectPlayer(player) then return end

    if ShouldGivePocketItem(player) then
        player:SetPocketActiveItem(mod.Enums.CollectibleType.COLLECTIBLE_ISAACD_POCKET)
    end

    RemoveSoulHearts(player)
    AddNullCostumeItemWhenNeeded(player)
    RemoveAllPossibleBrokenHearts(player)
    GivePlayerWaferEffect(player)
end

function mod.IsaacDPostResyncPlayer(player)
    if not IsCorrectPlayer(player) or not HealthBackupExists(player) then return end
    LoadAndNilHealthBackup(player)
end

function mod.IsaacDPreAddHealth(player, heartKey, heartNum)
    if heartNum <= 0 or not IsCorrectPlayer(player) or IsValidHeart(heartKey) then return end
    AddPlayerHealthBackup(player)
end

function mod:IsaacDPostPickupInit(pickup)
    local isaacD, otherPlayersExist, hasBirthright = GetIfIsaacDExistsAndIfOtherPlayersExist()
    if not isaacD then return end

    if Random() % 100 <= (hasBirthright and DICE_HEART_TURN_SUCCESS_RATE_BIRTHRIGHT or DICE_HEART_TURN_SUCCESS_RATE) then
        pickup:Morph(EntityType.ENTITY_PICKUP, mod.Enums.PickupVariant.PICKUP_DICE_HEART, 0, true, false, false)
    elseif not otherPlayersExist then
        local pickupTypeOffset = 0
        if pickup.Price ~= 0 then pickupTypeOffset = 1 end

        pickup:Morph(EntityType.ENTITY_PICKUP, POSSIBLE_PICKUP_MORPH_VARIANTS[Random() % (#POSSIBLE_PICKUP_MORPH_VARIANTS - pickupTypeOffset) + 1 + pickupTypeOffset], 0, true, false, false)
    end
end

--Init
CustomHealthAPI.PersistentData.CharactersThatConvertMaxHealth[PLAYER_TYPE] = PLAYER_MAX_HEART_REPLACEMENT
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.IsaacDPostPlayerUpdate)
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.IsaacDPostPickupInit, PickupVariant.PICKUP_HEART)
CustomHealthAPI.Library.AddCallback("Isaac'D", CustomHealthAPI.Enums.Callbacks.POST_RESYNC_PLAYER, 0, mod.IsaacDPostResyncPlayer)
CustomHealthAPI.Library.AddCallback("Isaac'D", CustomHealthAPI.Enums.Callbacks.PRE_ADD_HEALTH, 0, mod.IsaacDPreAddHealth)