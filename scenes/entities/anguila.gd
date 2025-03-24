extends CharacterBody2D

@export var speed: float = 150.0

var direction: Vector2 = Vector2.LEFT

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _process(delta: float) -> void:

	velocity = direction * speed
	move_and_slide()

func _input(event: InputEvent) -> void:

	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			direction = Vector2.RIGHT
			animation_player.play("move_rigth")  
		else:
			direction = Vector2.LEFT
			animation_player.play("move_left")   # Reproducir animación de la izquierda
