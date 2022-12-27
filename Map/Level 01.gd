extends Node2D

const PlayerScene = preload("res://Character/Fredegar.tscn")



var player_spawn_location = Vector2.ZERO



onready var camera: = $Camera2D
onready var player: = $Fredegar
onready var timer: = $Timer



func _ready():
	player.connect_camera(camera)
	player_spawn_location = player.global_position
	MusicPlayer.backgroundMusic.play()
	Events.connect("player_died", self, "_on_player_died")
	Events.connect("hit_savepoint", self, "_on_hit_savepoint")
	
func _on_player_died():
	timer.start(1.0)
	yield(timer, "timeout")
	var player = PlayerScene.instance()
	add_child(player)
	player.position = player_spawn_location
	player.connect_camera(camera)
	
func _on_hit_savepoint(savepoint_position):
	player_spawn_location = savepoint_position

