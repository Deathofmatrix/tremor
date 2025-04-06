extends Control

@onready var player_character: Player = $"../../PlayerCharacter"

@onready var buttons = [
	$CenterContainer/HBoxContainer/Button1,
	$CenterContainer/HBoxContainer/Button2,
	$CenterContainer/HBoxContainer/Button3,
	$CenterContainer/HBoxContainer/Button4
]

var upgrades = {
	"more_damage": {
		"cost": 10,
		"max_level": 2,
		"current_level": 0
	},
	"faster_dig": {
		"cost": 3,
		"max_level": 3,
		"current_level": 0
	},
	"faster_move": {
		"cost": 5,
		"max_level": 3,
		"current_level": 0
	},
	"refill_stamina": {
		"cost": 1,
		"max_level": INF,
		"current_level": 0
	}
}


func _ready() -> void:
	for button in buttons:
		button.button_down.connect(_on_button_pressed.bind(button, true))
		button.button_up.connect(_on_button_pressed.bind(button, false))

func _process(delta: float) -> void:
	for i in range(buttons.size()):
		var upgrade_name = ""
		var button : TextureButton = buttons[i]
		match i:
			0: upgrade_name = "more_damage"
			1: upgrade_name = "faster_dig"
			2: upgrade_name = "faster_move"
			3: upgrade_name = "refill_stamina"
		
		var upgrade = upgrades[upgrade_name]
		
		if player_character.money < upgrade["cost"] or upgrade["current_level"] == upgrade["max_level"]:
			button.disabled = true
			button.get_child(0).label_settings.font_color = Color.WHITE
		else:
			button.disabled = false


func _on_button_pressed(pressed_button: TextureButton, is_pressed: bool):
	var label = pressed_button.get_child(0) as Label
	label.label_settings.font_color = Color.BLACK if is_pressed else Color.WHITE
	if is_pressed == true: return
	if pressed_button == buttons[0]:
		_upgrade("more_damage", pressed_button)
	if pressed_button == buttons[1]:
		_upgrade("faster_dig", pressed_button)
	if pressed_button == buttons[2]:
		_upgrade("faster_move", pressed_button)
	if pressed_button == buttons[3]:
		_upgrade("refill_stamina", pressed_button)


func _upgrade(upgrade_name: String, pressed_button: TextureButton):
	var upgrade = upgrades.get(upgrade_name)
	if player_character.money < upgrade["cost"]:
		print("cannot afford")
		return
	
	if upgrade and upgrade["current_level"] < upgrade["max_level"]:
		player_character.set_money(player_character.money - upgrade["cost"])
		upgrade["current_level"] += 1
		player_character.apply_upgrade(upgrade_name)
		print(upgrade_name, " upgraded to level ", upgrade["current_level"])
		if upgrade["current_level"] == upgrade["max_level"]:
			var label = pressed_button.get_child(0) as Label
			label.text = "MAX\nLEVEL"
	else:
		print("Max level reached or invalid upgrade")
