local mod = IsaacD
local sfx = SFXManager()

local PICKUP_DROP_SOUND_FRAME = 25
local HEART_TO_DICE_TURN_RATE = 1
local HEART_TO_DICE_TURN_RATE_WITH_COLLECTIBLE = 10

local function ShouldGiveDiceHeart(player) return player and CustomHealthAPI.Library.CanPickKey(player, "DICE_HEART_1") end
local function PlayerCanPayForDiceHeart(player, pickup) return player:GetNumCoins() >= pickup.Price end
local function AddRandomDiceHeart(player) CustomHealthAPI.Library.AddHealth(player, "DICE_HEART_" .. Random() % 5 + 1, 2) end
local function RemovePickupAndPlaySounds(pickup)
    pickup:Kill()
    sfx:Stop(SoundEffect.SOUND_DEATH_BURST_SMALL)
    pickup:GetSprite():Play("Collect")
    sfx:Play(mod.Enums.SoundEffect.SOUND_POCKET_DICE_ROLL)
    sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES)
end

local function ShouldPlayDropSound(pickup) local sprite = pickup:GetSprite() return sprite:GetAnimation() == "Appear" and sprite:GetFrame() == PICKUP_DROP_SOUND_FRAME end

local function GetChanceOfTurning()
    local chance = HEART_TO_DICE_TURN_RATE
    for _, entityPlayer in pairs(Isaac.FindByType(EntityType.ENTITY_PLAYER)) do 
        local player = entityPlayer:ToPlayer()
        if player:GetPlayerType() == mod.Enums.PlayerType.PLAYER_ISAAC_D then
            chance = 0
            break
        elseif player:HasCollectible(mod.Enums.CollectibleType.COLLECTIBLE_ISAACD_POCKET) then
            chance = HEART_TO_DICE_TURN_RATE_WITH_COLLECTIBLE
            break
        end
    end
    return chance
end

function mod:DiceHeartPrePickupCollision(pickup, collider)
    local player = collider:ToPlayer()
    if not (ShouldGiveDiceHeart(player) and PlayerCanPayForDiceHeart(player, pickup)) then return end
    AddRandomDiceHeart(player)
    RemovePickupAndPlaySounds(pickup)
    player:AddCoins(-pickup.Price)
end

function mod:DiceHeartPostPickupUpdate(pickup)
    if ShouldPlayDropSound(pickup) then
        sfx:Play(SoundEffect.SOUND_BONE_BOUNCE)
    end
end

function mod:DiceHeartPostPickupInit(pickup)
    if Random() % 100 > GetChanceOfTurning() then return end
    pickup:Morph(EntityType.ENTITY_PICKUP, mod.Enums.PickupVariant.PICKUP_DICE_HEART, 0, true, false, false)
end


mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.DiceHeartPrePickupCollision, mod.Enums.PickupVariant.PICKUP_DICE_HEART)
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.DiceHeartPostPickupUpdate, mod.Enums.PickupVariant.PICKUP_DICE_HEART)
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.DiceHeartPostPickupInit, PickupVariant.PICKUP_HEART)