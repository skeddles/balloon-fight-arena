# Balloon Fight Arena
 
Balloon fight fangame, multiplayer platform fighter. 

Learn more / play online: https://skeddles.itch.io/balloon-fight-arena

# Contribute

Godot 4.2

Current version / minor version is on main branch, current next version has its own branch.

## Characters

1. Go to `res://scenes/character.tscn`
2. Right click and select `New Inherited Scene`	
3. Select the root node of the scene
4. Change the source, abilities and stats values
5. Save under `res://scenes/characters`

## Stages

1. Go to `res://scenes/stage.tscn`
2. Right click and select `New Inherited Scene`	
3. Add a tilemap node
4. Draw in new tiles
5. Place navigation tiles, leaving 1 tile of space around platforms and walls and ceiling, and 2 under platforms
6. Add 4 Marker2D nodes, named Spawn1-Spawn4
7. Add a AudioStreamPlayer2D node, named Music under the Sound node
8. Save under `res://scenes/stages`
