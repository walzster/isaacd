local mod = IsaacD
local sfx = SFXManager()

--Functions (helper)
local function GetDiceHeartNum(player)
    local num = 0
    for i = 1, 5 do
        num = num + CustomHealthAPI.Library.GetHPOfKey(player, "DICE_HEART_" .. i)
    end
    num = num + CustomHealthAPI.Library.GetHPOfKey(player, "SOUL_HEART")
    return num
end

local function RemovePlayerDiceHP(player)
    for i = 1, 5 do
        CustomHealthAPI.Library.AddHealth(player, "DICE_HEART_" .. i, -100)
    end
    CustomHealthAPI.Library.GetHPOfKey(player, "SOUL_HEART", -CustomHealthAPI.Library.GetHPOfKey(player, "SOUL_HEART") * 2)
end

local function RestorePlayerDiceHealthInRandomDice(player, num)
    for i = 1, math.floor(num/2) do
        CustomHealthAPI.Library.AddHealth(player, "DICE_HEART_" .. Random() % 5 + 1, 2)
    end
end

local function PlaySounds()
    sfx:Play(mod.Enums.SoundEffect.SOUND_POCKET_DICE_ROLL_LONG)
end

--Function (callback)
local function UseItem(_, _, _, player)
    local diceHeartNum = GetDiceHeartNum(player)
    RemovePlayerDiceHP(player)
    RestorePlayerDiceHealthInRandomDice(player, diceHeartNum)
    PlaySounds()
    return {
        Discharge = true,
        ShowAnim = true,
    }
end

--Init
mod:AddCallback(ModCallbacks.MC_USE_ITEM, UseItem, mod.Enums.CollectibleType.COLLECTIBLE_ISAACD_POCKET)