extends Node2D
const r = Vector2(1152,648)
const loop_count =  8
const mult = 2.4
signal transition_finished
signal halfway
signal other_halfway
# Called when the node enters the scene tree for the first time.
func _ready():
	transition_setup()

@warning_ignore('narrowing_conversion')
func transition_setup(colcount:int = loop_count):
	var y = r.y/colcount
	for i in colcount:
		var pan = Panel.new()
		var box = StyleBoxFlat.new()
		box.bg_color = GameGlobal.color_gradient(i*2)
		pan.add_theme_stylebox_override('panel',box)
		pan.size = Vector2(r.x*mult,y)
		pan.position = Vector2(-r.x*mult,y*i)
		add_child(pan)

func transition_right():
	var tween = get_tree().create_tween().set_parallel()
	var m = get_tree().create_tween()
	for i in loop_count:
		var pan = get_child(i)
		pan.position.x = -r.x*mult
		tween.tween_property(pan,"position:x",r.x*mult ,1+0.2*i)
	m.tween_interval(0.50)
	m.tween_callback(half)
	tween.connect('finished',finished)

func transition_left():
	var tween = get_tree().create_tween().set_parallel()
	var m = get_tree().create_tween()
	for i in loop_count:
		var pan = get_child(i)
		pan.position.x = r.x*mult
		tween.tween_property(pan,"position:x",-r.x*(mult),1+0.07*i)
	m.tween_interval(0.75)
	m.tween_callback(other_half)
	tween.connect('finished',finished)

func finished():
	transition_finished.emit()

func half():
	halfway.emit()

func other_half():
	other_halfway.emit()
