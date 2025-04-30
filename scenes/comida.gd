extends Area2D

signal comida_comida  # Crear la señal

@export var speed: float = 100  # Velocidad de caída

func _ready():
	set_monitoring(true)
	# Obtener referencia al nodo "anguila"
	var anguila = get_tree().get_first_node_in_group("anguila_group")
	if anguila:
		connect("comida_comida", Callable(anguila, "_on_comida_comida"))
		connect("body_entered", Callable(self, "_on_body_entered"))
	else:
		print("Error: No se encontró el nodo 'anguila'")
	
func _process(delta):
	position.y += speed * delta  # Mueve la comida hacia abajo	
	if position.y > get_viewport_rect().size.y + 50:  # Si sale de la pantalla
		queue_free()  # Elimina el objeto

func _on_body_entered(body: Node2D) -> void:
	emit_signal("comida_comida")
	queue_free()
