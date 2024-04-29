extends Node

@export var InputScheme:String

func getInput(_character):
	return {
		dirAxis = Input.get_axis(InputScheme+"_left", InputScheme+"_right"),
		jumped = Input.is_action_just_pressed(InputScheme+"_jump")
	}
