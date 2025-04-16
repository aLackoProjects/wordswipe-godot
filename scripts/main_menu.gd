extends Control
signal play
signal stats

func _ready():
	GameGlobal.connect("loaded",on_bootup)
	menu()

func on_bootup():
	$version.text = GameGlobal.version
	print('loaded!!')

func menu():
	show()
	rot()

func rot():
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_CIRC)
	tween.tween_property($Icon,'rotation_degrees',3.6, 3)
	tween.tween_property($Icon,'rotation_degrees',-3.6, 3)
	if visible:
		tween.tween_callback(rot)


func _on_play_pressed():
	play.emit()



func _on_stats_pressed():
	stats.emit()
