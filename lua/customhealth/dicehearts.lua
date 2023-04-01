local mod = IsaacD

--Constants
local HURT_FUNCTION_FILEPATH = "lua.customhealth.hurtfunctions.dice_"

--Variables
mod.DiceHeartHealthFunctions = {}

for i = 1, 5 do
    mod.DiceHeartHealthFunctions[tostring(i)] = include(HURT_FUNCTION_FILEPATH .. i)
    CustomHealthAPI.Library.RegisterSoulHealth("DICE_HEART_" .. i,
                                    {   AnimationFilename = "gfx/ui/dice_hearts.anm2",
                                        AnimationName = {"DiceHeart" .. i},
                                        SortOrder = 100,
                                        AddPriority = 100,
                                        HealFlashRO = 125/255,
                                        HealFlashGO = 25/255,
                                        HealFlashBO = 25/255,
                                        MaxHP = 2,
                                        PickupEntities = {{ID = EntityType.ENTITY_PICKUP, Var = 816, Sub = 0}},
                                        ProtectsDealChance = true,
                                        PrioritizeHealing = false,
    })
end

local function GetDiceNum(key) return key:find("DICE_HEART_") and key:gsub("DICE_HEART_", "") end

local function DiceHeartsExist()
    for _, entityPlayer in pairs(Isaac.FindByType(EntityType.ENTITY_PLAYER)) do
        local player = entityPlayer:ToPlayer()
        for i = 1, 5 do
            if CustomHealthAPI.Library.GetHPOfKey(player, "DICE_HEART_" .. i) ~= 0 then return true end
        end
    end
end

function mod.DiceHeartPostHealthDamaged(player, _, key, damaged)
    local diceNum = GetDiceNum(key)
    if not diceNum then return end
    mod.DiceHeartHealthFunctions[diceNum](player)
    CustomHealthAPI.Library.AddHealth(player, key, damaged - 2)
end

function mod:DiceHeartPreGameExit()
    if FiendFolio or not DiceHeartsExist() then
        mod:SaveData("")
    else
        mod:SaveData(CustomHealthAPI.Library.GetHealthBackup())
    end
end

function mod:DiceHeartPostGameStarted(continued)
    if not (continued and mod:HasData() and mod:LoadData() ~= "") then return end
    CustomHealthAPI.Library.LoadHealthFromBackup(mod:LoadData())
end

CustomHealthAPI.Library.AddCallback("Isaac'D", CustomHealthAPI.Enums.Callbacks.POST_HEALTH_DAMAGED, 0, mod.DiceHeartPostHealthDamaged)
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.DiceHeartPostGameStarted)
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.DiceHeartPreGameExit)
