extends Node2D

var endedMatch = false

func _process(_delta):
	if !endedMatch && (get_tree().get_nodes_in_group("character").size() == 1): 
		endedMatch = true
		var winner = get_tree().get_nodes_in_group("character")[0]
		$Sound/MatchOver.playing = true
		$MatchOver/Winner.text = "WINNER: PLAYER "+ str(winner.playerNumber)
		$MatchOver.visible = true
		
func _on_match_over_finished():
	var menu = load("res://scenes/debug_launcher.tscn").instantiate()
	get_tree().root.add_child(menu)
	get_node("/root/Level").queue_free()
