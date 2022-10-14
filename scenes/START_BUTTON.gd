tool
extends Button

export(String, FILE) var next_scene_path = ""

func _on_START_BUTTON_button_up():
	get_node("../../sound_confirmation").play()
	get_tree().change_scene(next_scene_path)
