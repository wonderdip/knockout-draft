extends Resource
class_name UpgradeData

enum UpgradeType { DMG, ATK_SPEED, KNOCKBACK, SPECIAL }
enum UpgradeRarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }

@export var texture: CompressedTexture2D
@export var name: String
@export_multiline var description: String
@export var type: UpgradeType
@export var rarity: UpgradeRarity
@export var value: float = 0.1

func apply_upgrade(fighter: Fighter) -> void:
	match type:
		UpgradeType.ATK_SPEED:
			fighter.attack_speed *= (1 + value)
			fighter.animation_player.speed_scale = fighter.attack_speed
		UpgradeType.DMG:
			fighter.damage_multiplier *= (1 + value)
		UpgradeType.KNOCKBACK:
			fighter.horizontal_knockback_multiplier *= (1 + value)
