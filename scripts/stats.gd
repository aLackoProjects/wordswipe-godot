extends Control


func show_stats():
	show()
	$global_words/Label.text = get_global_words()
	$favorite_word/Label.text = "N/A" if len(GameGlobal.global_said_words) == 0 else favorite_word()
	


func get_global_words():
	return "You have not used a word yet" if len(GameGlobal.global_said_words) == 0 else JSON.stringify(GameGlobal.global_said_words,"").replace('"','').replace(":",": ").replace("{","").replace("}","").replace(',',',\n')

func favorite_word():
	var highest_word = ""
	var highest_val = 0
	for word in GameGlobal.global_said_words:
		if GameGlobal.global_said_words[word] > highest_val:
			highest_val = GameGlobal.global_said_words[word]
			highest_word = word
	return highest_word


func _on_exit_pressed():
	hide()
