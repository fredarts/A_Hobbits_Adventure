extends Node

const LEVEL_01 = preload("res://Music/BackgroundMusic_01.wav")

onready var backgroundMusic = $BackgroundMusicPlayer/AudioStreamPlayer

func play_background_music():
	backgroundMusic.play()
			
			
