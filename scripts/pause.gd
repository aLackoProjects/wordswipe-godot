extends Control
signal exit()

# Called when the node enters the scene tree for the first time.
func pause(gameover = false):
	show()
	$backdrop/main/unpause.disabled = false
	$backdrop.self_modulate.a = 0
	$backdrop/main.position.y = 700
	$backdrop/main/Label.text = "Game Over" if gameover else "Paused..."
	$backdrop/main/unpause.disabled = gameover
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property($backdrop,'self_modulate:a',1,0.5)
	tween.tween_property($backdrop/main,"position:y",74,0.5)
	$backdrop/main/words.text = "You have not used a word yet" if len(GameGlobal.said_words) == 0 else "Words Used:\n%s"%JSON.stringify(GameGlobal.said_words,"").replace('"','').replace(":",": ").replace("{","").replace("}","").replace(',',',\n')
	$backdrop/main/scores.text = "Score: %s\nHigh Score: %s" % [GameGlobal.score,GameGlobal.high_score]


func _on_unpause_pressed():
	hide()
	$backdrop/main/unpause.disabled = true
	$backdrop.self_modulate.a = 1
	$backdrop/main.position.y = 74
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property($backdrop,'self_modulate:a',0,0.5)
	tween.tween_property($backdrop/main,"position:y",700,0.5)
	tween.tween_callback(hide)


func _on_exit_pressed():
	hide()
	exit.emit()
