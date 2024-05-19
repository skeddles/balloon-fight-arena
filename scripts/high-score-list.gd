extends Control

## The identifier for this high score list, which will be used to save and look up it's contents - should probably be camel case
@export var HighScoreListName:String

const HIGH_SCORE_TABLE_ENTRIES = 10
const TROPHY_GOALS = [0,25,50,100,250,500,1000,2500,5000,10000,25000,50000,100000,250000,500000,1000000]

func _ready():
	visible = false

func update_and_reveal_high_scores(newScore):
	var data = get_highscore_data()
	var entries = data.entries
	print("high score data: ", data)
	
	if entries.size() < HIGH_SCORE_TABLE_ENTRIES or entries.back().score <= newScore:
		var position = 0
		for e in entries:
			if newScore < e.score: position += 1
			else: break
		print("inserting new high score ("+str(newScore)+") at position: "+str(position))
		entries.insert(position,{score=newScore, name="SKDLS"})
		if entries.size() == HIGH_SCORE_TABLE_ENTRIES + 1: 
			entries.pop_back()
		$Panel/Highlight.position.y += position * 19
	else:
		$Panel/Highlight.visible = false
		
	update_high_score_list(entries)
	save_highscore_data(entries)
	visible = true

func update_high_score_list(entries):
	$Panel/Names.text = "\n".join(entries.map(func (e): return e.name))
	$Panel/Scores.text = "\n".join(entries.map(func (e): return e.score))
	#for i in range(1,11):
	var i = 1
	for e in entries:
		print("entriey tropy ",i," - ",e)
		get_node("Panel/Icons/"+str(i)+"/Sprite").region_rect = Rect2(get_trophy_level(e.score)*16,0,16,16)
		i += 1
	
	if entries.size() < 10:
		for ei in range(entries.size()+1,11):
			get_node("Panel/Icons/"+str(ei)+"/Sprite").visible = false

func get_highscore_data():
	var dataPath = "user://highscores-"+HighScoreListName+".json"
	if FileAccess.file_exists(dataPath):
		var gameData = FileAccess.open(dataPath, FileAccess.READ)
		var parsed = JSON.parse_string(gameData.get_as_text())
		print("loaded high score data: ", dataPath)
		return parsed
	else:
		var file = FileAccess.open(dataPath, FileAccess.WRITE)
		var data = {
			"_v" = 1,
			"entries" = [],
		}
		file.store_string(JSON.stringify(data))
		print("initialized high score data: ",dataPath)
		return data

func save_highscore_data(entries):
	var dataPath = "user://highscores-"+HighScoreListName+".json"
	var file = FileAccess.open(dataPath, FileAccess.WRITE)
	var data = {
		"_v" = 1,
		"entries" = entries,
	}
	file.store_string(JSON.stringify(data))
	print("saved high score data: ",dataPath)


func get_trophy_level(score):
	var level = 0
	for g in TROPHY_GOALS: 
		if g > score: break
		level+=1
	return level
	
