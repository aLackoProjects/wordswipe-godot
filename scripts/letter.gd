extends Node2D
@onready var backgroundNode = $rotate_axis/background
var original_color:Color
var grid_position:Vector2i
var letter = ""
var v = 0

func touch():
	if GameGlobal.check_valid(GameGlobal.current_selected,grid_position) or not GameGlobal.is_pressed:
		grab()
	elif len(GameGlobal.selected_nodes) > 1 and GameGlobal.selected_nodes[-2] == grid_position:
		GameGlobal.release.emit(GameGlobal.selected_nodes[-1])
		GameGlobal.selected_nodes.resize(len(GameGlobal.selected_nodes)-2)
		GameGlobal.selected_word = GameGlobal.selected_word.substr(0,len(GameGlobal.selected_word)-2)
		grab()

func grab():
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property($rotate_axis,"scale",Vector2(1.2,1.2),0.1)
	tween.tween_property(backgroundNode,"self_modulate",Color8(5000,240,222),0.1)
	GameGlobal.selected_word += letter.to_upper()
	GameGlobal.current_selected = grid_position
	GameGlobal.is_pressed = true
	GameGlobal.selected_nodes.append(grid_position)
	shake()

func release():
	var tween = get_tree().create_tween()
	tween.tween_property($rotate_axis,"scale",Vector2(1,1),0.1)
	tween.tween_property(backgroundNode,"self_modulate",original_color,0.1)


func shake():
	if GameGlobal.is_pressed and GameGlobal.current_selected == grid_position:
		var tween = get_tree().create_tween()
		tween.tween_property($rotate_axis,"rotation_degrees",10,0.1)
		tween.tween_property($rotate_axis,"rotation_degrees",0,0.1)
		tween.tween_property($rotate_axis,"rotation_degrees",-10,0.1)
		tween.tween_callback(shake)
	else:
		$rotate_axis.rotation_degrees = 0

func _ready():
	set_process(false)
	$rotate_axis/letter.text = letter.to_upper()
	$rotate_axis/value.text = str(GameGlobal.get_value(letter))
	if letter in GameGlobal.special_letters:
		$rotate_axis/value.text = ''
		original_color = Color.html("e5c06b")
	else:
		original_color = GameGlobal.color_gradient(GameGlobal.weights[letter])
	if letter == "_":
		funky_loop()
	backgroundNode.self_modulate = original_color

func ihateyoucall():
	name = str(grid_position.x)

func expand():
	var tween = get_tree().create_tween()
	tween.tween_property($rotate_axis,"scale",Vector2(2,2),0.1)
	$TouchScreenButton.process_mode = Node.PROCESS_MODE_DISABLED

func funky_loop():
	var i = GameGlobal.rng.randi_range(0,len(GameGlobal.vowels)-1)
	while true:
		$rotate_axis/letter.text = GameGlobal.vowels[i%len(GameGlobal.vowels)-1].to_upper()
		i += 1
		await get_tree().create_timer(0.3).timeout

func failed():
	var tween = get_tree().create_tween()
	tween.tween_property(backgroundNode,"self_modulate",Color(1000,1,1),0.3)
	tween.tween_callback(release)

func on_mouse_input(_viewport: Node, event: InputEvent, shape_idx: int) -> void:
	print(event.as_text())
