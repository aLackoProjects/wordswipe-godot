extends Node2D
@onready var new_word_bonus_pos = $score/new_word_bonus.position
@onready var len_multi_pos = $score/length_multiplier.position
@onready var word_total_pos = $score/word_total.position
@export var level_multi_multi:float = 5
var gravity:int = 0
var turns_before_switch = -1
var show_quick_menu = false
var next_turn:int = 1
signal quit_desired(failed)
signal lose(failed)

func _ready():
	GameGlobal.connect("clear",clear)
	GameGlobal.connect("release",release)
	GameGlobal.connect("failed",failed)

func _process(_delta):
	$word.text = GameGlobal.selected_word

func clear(total,multiplier,is_unique):
	$score/score.text = "[font_size=32][right][flipboard rate=20]%s"%[GameGlobal.score]
	if GameGlobal.score > GameGlobal.high_score:
		GameGlobal.high_score = GameGlobal.score
		$score/high_score.text = "[right]High Score: [flipboard rate=20 offset=10]%s" % [GameGlobal.high_score]
	$score/word_total.text = "[right][font_size=24][shake rate=%s level=%s]Character Score + %s" % [total/5,5+multiplier*level_multi_multi,total]
	score_tween($score/word_total,word_total_pos,0.2)
	$score/length_multiplier.text = "[right][font_size=24][shake rate=%s]Length Multiplier x %s" % [multiplier*10,multiplier]
	score_tween($score/length_multiplier,len_multi_pos,0.4)
	if is_unique:
		score_tween($score/new_word_bonus,new_word_bonus_pos,0.6)
	else:
		$score/new_word_bonus.self_modulate.a = 0
	turns_before_switch -= 1
	check_switch()
	$grid.clear_and_move(GameGlobal.selected_nodes,gravity)
	GameGlobal.selected_nodes = []

func check_switch():
	if turns_before_switch < 0:
		turns_before_switch = 5
		gravity = next_turn
		switch_gravity(gravity)
		while next_turn == gravity:
			next_turn = GameGlobal.rng.randi_range(0,3)
		switch_gravity(next_turn,$direction/next)
	$direction/moves_left.text = str(turns_before_switch)

func release(pos):
	$grid.release(pos)

func score_tween(node:Control,original_pos: Vector2,offset: float):
	var tween = get_tree().create_tween ().set_parallel()
	node.show()
	tween.tween_interval(offset)
	tween.chain().tween_property(node,"self_modulate:a",0,0.1)
	tween.tween_property(node,"position:y",original_pos.y,1)
	tween.chain().tween_property(node,"self_modulate:a",1,0.2)
	tween.chain().tween_property(node,"position:y",81,2)
	tween.tween_property(node,"self_modulate:a",0,1)


func _on_button_pressed():
	$grid.shmoove()


func _on_reset_pressed():
	print("RESETTING")
	var tween = get_tree().create_tween()
	$settings/restart.rotation_degrees = 0
	tween.tween_property($settings/restart, "rotation_degrees",360,0.5)
	$grid.purge_children()
	start()


func trash_hover():
	GameGlobal.trash_hovered = true
	var tween = get_tree().create_tween()
	tween.tween_property($trash/trash_under,"position:x",0,0.2)
	trash_shake()

func trash_released():
	var tween = get_tree().create_tween()
	tween.tween_property($trash/trash_under,"position:x",-80,0.2)

func trash_shake():
	var trash = $trash/trash_under/trash
	var tween = get_tree().create_tween()
	tween.tween_property(trash,"rotation_degrees",-10,0.1)
	tween.tween_property(trash,"rotation_degrees",0,0.1)
	tween.tween_property(trash,"rotation_degrees",10,0.1)
	if GameGlobal.trash_hovered:
		tween.tween_callback(trash_shake)

func _input(event):
	if event is InputEventScreenTouch and not event.pressed:
		if GameGlobal.trash_hovered:
			GameGlobal.selected_word = ""
			GameGlobal.is_pressed = false
			$grid.call_mass(GameGlobal.selected_nodes,'release')
			GameGlobal.current_selected = Vector2i(-1,-1)
			GameGlobal.selected_nodes = []
			GameGlobal.trash_hovered = false
		elif GameGlobal.is_pressed:
			if GameGlobal.is_valid():
				$grid.call_mass(GameGlobal.selected_nodes,'expand')
				var tween = get_tree().create_tween()
				tween.tween_interval(0.1)
				tween.tween_callback(GameGlobal.submit)
				check_end_state()
			else:
				failed()
		GameGlobal.is_pressed = false
		

func start():
	gravity = 0
	turns_before_switch = -1
	show_quick_menu = false
	next_turn = 1
	check_switch()
	$grid.make_grid(Vector2(69,69),Vector2(8,6))
	GameGlobal.reset()
	$score/score.text = "[font_size=32][right][flipboard rate=20]%s"%[GameGlobal.score]
	$score/high_score.text = "[right]High Score: [flipboard rate=20 offset=10]%s"%GameGlobal.high_score
	set_process(true)

func cancel_trash():
	GameGlobal.trash_hovered = false

func switch_gravity(dir:int,node:Node = $direction/current):
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_ELASTIC)
	if dir == GameGlobal.GRAVITY_UP:
		tween.tween_property(node,"rotation_degrees",-90,0.2)
	elif dir == GameGlobal.GRAVITY_DOWN:
		tween.tween_property(node,"rotation_degrees",90,0.2)
	elif dir == GameGlobal.GRAVITY_LEFT:
		tween.tween_property(node,"rotation_degrees",180,0.2)
	elif dir == GameGlobal.GRAVITY_RIGHT:
		tween.tween_property(node,"rotation_degrees",0,0.2)


func _on_quick_menu_pressed():
	show_quick_menu = not show_quick_menu
	var tween = get_tree().create_tween().set_parallel()
	if show_quick_menu:
		tween.tween_property($settings, 'position:x',0,0.5)
		tween.tween_property($settings/ra, 'rotation_degrees',0,0.5)
		$settings/restart/restart.disabled = false
		$settings/exit.disabled = false
	else:
		tween.tween_property($settings, 'position:x',-194,0.5)
		tween.tween_property($settings/ra, 'rotation_degrees',180,0.5)
		$settings/restart/restart.disabled = true
		$settings/exit.disabled = true

func hidequickmen():
	show_quick_menu = true
	_on_quick_menu_pressed()

func failed():
	$grid.call_mass(GameGlobal.selected_nodes,'failed')
	GameGlobal.selected_nodes = []
	GameGlobal.current_selected = Vector2i(-1,-1)
	GameGlobal.selected_word = ""

func check_end_state():
	if $grid.count() == 0:
		$grid.make_grid(Vector2(69,69),Vector2(8,6))
		GameGlobal.score += 1000
		$score/word_total.text = "[right][font_size=24][shake rate=20 level=5]FULL CLEAR - 1000"
		score_tween($score/word_total,word_total_pos,0.2)
	elif not $grid.has_vowel() and $grid.count() < 3:
		lose.emit(true)

func _on_quit_pressed():
	quit_desired.emit(false)

func quit():
	$grid.purge_children()

#TODO: QUIT AND STATS MENU!!!!
