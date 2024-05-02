extends Node

@export var InputScheme:String
var usingGamePad:bool = false
var gamepadId:int = 0


func getInput(_character):
	if usingGamePad:
		return {
			dirAxis = round(Input.get_joy_axis(gamepadId, JOY_AXIS_LEFT_X)),
			jumped = is_joy_button_just_pressed(gamepadId, JOY_BUTTON_A)
		}
	else:
		return {
			dirAxis = Input.get_axis(InputScheme+"_left", InputScheme+"_right"),
			jumped = Input.is_action_just_pressed(InputScheme+"_jump")
		}

# this should exist in godot but it doesn't
var pressed_buttons = {}
func is_joy_button_just_pressed(id, button):
	if Input.is_joy_button_pressed(id, button):
		if button in pressed_buttons:
			return false  # Button was already pressed in previous frame
		else:
			pressed_buttons[button] = true  # Mark button as pressed
			return true
	else:
		if button in pressed_buttons:
			pressed_buttons.erase(button)  # Button is no longer pressed, remove from dictionary
		return false
		
		

var DEBUG = false
func debugDraw (character):
	if not DEBUG: return
	var default_font = ThemeDB.fallback_font
	if (usingGamePad):
		character.draw_string(default_font, Vector2(0, -15), str(gamepadId), HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color.WHITE)
