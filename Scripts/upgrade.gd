extends Resource
class_name UpgradeData

enum UpgradeType { DMG, SPEED, ATK_SPEED, HEALTH, OTHER }
enum UpgradeRarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }

@export var name: String
@export_multiline var description: String
@export var type: UpgradeType
@export var rarity: UpgradeRarity

## Percent it increases by
@export var value: float = 0.1  # percent bonus (0.1 = 10%)
