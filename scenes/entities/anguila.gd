extends CharacterBody2D

@export var cola_texture : Texture2D
@export var speed: float = 150.0
@export var longitud_cola_maxima : int = 10
@export var distancia_cola : float = 5.0
@export var tiempo_spawn : float = 2.0 # cada cuántos segundos aparecen loss obstaculos

var direction: Vector2 = Vector2.LEFT
var cola = []
var offset_y = 65
var offset_x = 125
var historial_posiciones: Array[Vector2] = []
var timer = 0.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	animation_player.play("move_left")

	# Crear el segmento bottom inicial
	var bottom_sprite = AnimatedSprite2D.new()
	bottom_sprite.sprite_frames = preload("res://animaciones/animaccionesbottom.tres")
	if bottom_sprite.sprite_frames == null:
		printerr("Error: No se pudo cargar el archivo de animaciones del bottom.")
		return
	bottom_sprite.animation = "b_move_left"
	bottom_sprite.play()
	bottom_sprite.centered = true
	bottom_sprite.z_index = 1 # Asegurar que se dibuje por encima de otros
	if get_parent() != null:
		call_deferred("add_child", bottom_sprite)
		var bottom_posicion = position + Vector2(20, 20 + 130) # Offsets iniciales más pequeños para probar
		cola.append({
			"sprite": bottom_sprite,
			"posicion": bottom_posicion,
			"es_bottom": true
		})
		bottom_sprite.position = bottom_posicion
		print("Segmento bottom inicial creado en posición:", bottom_posicion)
	else:
		printerr("Error: El nodo anguila no tiene un padre válido.")

func _process(delta: float) -> void:
	velocity = direction * speed
	move_and_slide()
	# Guardar la posición del jugador al inicio de cada frame
	historial_posiciones.insert(0, position + Vector2(offset_x, offset_y))
	# Limitar el historial al tamaño de la cola
	var historial_max = longitud_cola_maxima * distancia_cola
	if historial_posiciones.size() > historial_max:
		historial_posiciones.resize(historial_max)
#Actualizar la cola
	for i in range(cola.size()):
		var segmento = cola[i]
		var nueva_animacion = ""
		var index_historial = (i + 1) * int(distancia_cola)

		if index_historial < historial_posiciones.size():
			var pos_from_history = historial_posiciones[index_historial]
			segmento["sprite"].global_position = Vector2(pos_from_history.x, segmento["posicion"].y)
		else:
			# Si no hay historial suficiente, mantener la posición actual
			segmento["sprite"].global_position = Vector2(segmento["posicion"].x, segmento["posicion"].y)

	for i in range(cola.size()):
		var segmento = cola[i]
		var nueva_animacion = ""

		if segmento.has("es_bottom") and segmento["es_bottom"]:
			nueva_animacion = "b_move_right" if direction == Vector2.RIGHT else "b_move_left"
		else:
			nueva_animacion = "move_right" if direction == Vector2.RIGHT else "move_left"

		if segmento["sprite"].animation != nueva_animacion:
			segmento["sprite"].animation = nueva_animacion
			segmento["sprite"].play()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		if event.pressed:
			direction = Vector2.RIGHT
			animation_player.play("move_rigth")
		else:
			direction = Vector2.LEFT
			animation_player.play("move_left")

func _on_comida_comida():
	print("¡Se ha llamado a _on_comida_comida!")

	var nuevo_sprite = AnimatedSprite2D.new()
	nuevo_sprite.sprite_frames = preload("res://animaciones/animacionescola.tres") # Cambia la ruta
	if nuevo_sprite.sprite_frames == null:
		printerr("Error: No se pudo cargar el archivo de animaciones de la cola.")
		return
	nuevo_sprite.animation = "move_left" # O el nombre de tu animación
	nuevo_sprite.play()
	nuevo_sprite.centered = true
	get_parent().add_child(nuevo_sprite)

	# Tomar el bottom actual y quitarlo temporalmente
	var bottom_segment = cola.pop_back()

		# Determinar la posición del nuevo segmento
	var posicion_nueva: Vector2
	if cola.is_empty():
		posicion_nueva = position + Vector2(offset_x, offset_y + 70)
	else:
		# Tomamos la posición del último segmento y le restamos un pequeño offset (ajusta según necesites)
		var ultimo_segmento = cola.back()
		posicion_nueva = ultimo_segmento.sprite.global_position + Vector2(0, offset_y)

	cola.append({
		"sprite": nuevo_sprite,
		"posicion": posicion_nueva,
		"es_bottom": false
	})

	nuevo_sprite.position = posicion_nueva

	# Volver a agregar el bottom al final
	var nueva_pos_bottom = nuevo_sprite.position + Vector2(0 + 30, offset_y + 20)
	bottom_segment["posicion"] = nueva_pos_bottom
	bottom_segment["sprite"].position = nueva_pos_bottom
	cola.append(bottom_segment)

	print("Nuevo segmento añadido en posición:", posicion_nueva)
	print("Segmento bottom reposicionado en:", nueva_pos_bottom)
	


func _on_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("obstaculos"):
		get_tree().change_scene_to_file("res://scenes/entities/MENU.tscn")
