extends Node2D

@export var speed: float = 300 

func _process(delta):
	# Mueve ambos fondos
	for sprite in [$background1, $background2]:
		sprite.position.y += speed * delta

		# Si un fondo sale de la pantalla, lo reposicionamos arriba
		if sprite.position.y >= 1280:
			sprite.position.y -= 1280 * 2
