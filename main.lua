IsaacD = IsaacD or RegisterMod("Isaac'D", 1)

local scripts = {
    "enums",
    "customhealthapi.core",
    "customhealth.dicehearts",
    "collectibles.active.isaacdpocket",
    "pickup.diceheart",
    "player.isaacd",
    "player.caind"
}

for _, script in pairs(scripts) do
    include("lua." .. script)
end