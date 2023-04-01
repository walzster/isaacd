IsaacD.Enums = {
    PlayerType = {
        PLAYER_ISAAC_D = Isaac.GetPlayerTypeByName("Isaac'D"),
        PLAYER_CAIN_D = Isaac.GetPlayerTypeByName("Cain'D", true),
    },

    CollectibleType = {
        COLLECTIBLE_ISAACD_POCKET = Isaac.GetItemIdByName("Dice'D"),
    },

    PickupVariant = {
        PICKUP_DICE_HEART = Isaac.GetEntityVariantByName("Dice Heart")
    },

    SoundEffect = {
        SOUND_POCKET_DICE_ROLL = Isaac.GetSoundIdByName("Pocket dice roll"),
        SOUND_POCKET_DICE_ROLL_LONG = Isaac.GetSoundIdByName("Pocket dice roll long"),
    },

    NullItemID = {
        ID_ISAACD_COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/isaacd_costume.anm2")
    }
}