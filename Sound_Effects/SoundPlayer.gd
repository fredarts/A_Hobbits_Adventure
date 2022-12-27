extends Node

const HURT = preload("res://Sound_Effects/Hurt.wav")
const JUMP = preload("res://Sound_Effects/Jump.wav")
const LAND = preload("res://Sound_Effects/Land.wav")
const COLLECTABLES = preload("res://Sound_Effects/Collectables.wav")


onready var audioPlayers = $AudioPlayers

func play_sound(sound):
	for audioStreamPlayer in audioPlayers.get_children():
		if not audioStreamPlayer.playing:
			audioStreamPlayer.stream = sound
			audioStreamPlayer.play()
			break
			
