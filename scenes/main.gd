extends Node2D

@export var obstaculos_scene: PackedScene
@export var tiempo_spawn : float = 4.0 # cada cuántos segundos aparece el obstaculo
@export var velocidad = 100.0 # píxeles por segundo, ajusta como quieras

var comida_scene : PackedScene = preload("res://scenes/comida.tscn")
var timer: Timer
var puntos: int = 0
var timer_o = 0.0
@onready var label_puntos: Label = $Label

func _process(delta):
	timer_o += delta
	if timer_o >= tiempo_spawn:
		timer_o = 0
		crear_obstaculo()
		
	# Aquí se mueve cada obstáculo hacia abajo
	for obstaculo in get_children():
		if obstaculo.is_in_group("obstaculo"):  # Asegúrate de que el obstáculo esté en la escena
			obstaculo.position.y += velocidad * delta  # Mover el obstáculo hacia abajo por la velocidad ajustada
		
func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 4.0  # Intervalo de 1 segundo
	timer.autostart = true 	
	timer.start()
	# Usamos Callable para conectar la señal
	timer.connect("timeout", Callable(self, "_on_Timer_timeout"))
	actualizar_puntos()

func _on_Timer_timeout():
	var comida = comida_scene.instantiate()  # Crear una instancia de la comida
	comida.position = Vector2(randf_range(0, get_viewport().size.x), 0)  # Posición aleatoria en X (en la parte superior)
	comida.connect("comida_comida", Callable(self, "_incrementar_puntos"))
	add_child(comida)  # Agregar la comida a la escena
	
func _incrementar_puntos():
	puntos += 1
	actualizar_puntos()

func actualizar_puntos():
	label_puntos.text = str(puntos)
	
func crear_obstaculo():
	var nuevo_obstaculo = obstaculos_scene.instantiate()
	var x_random = randf_range(-180, 200) # cambia estos valores según tu juego
	nuevo_obstaculo.position = Vector2(x_random, -700) # eje Y depende de donde quieras que aparezc
	nuevo_obstaculo.add_to_group("obstaculo")  # Asegura que se pueda identificar como obstáculo
	add_child(nuevo_obstaculo)
