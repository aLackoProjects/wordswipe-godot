extends Node
const GRAVITY_DOWN = 0
const GRAVITY_UP = 1
const GRAVITY_RIGHT = 2
const GRAVITY_LEFT = 3

var current_selected:Vector2i
var selected_word = ""
var total_words = 0
var version = "0.15.08.24"
var said_words = {}
var selected_nodes = []
var global_said_words = {}
var high_score = 0
var is_pressed = false
var len_multiplier = 0.5
var universal_vowels_used = 0
var universal_letters_used = 0
var score = 0
var trash_hovered = false
var vowels = ['a','e','i','o','u','y']
var special_letters = {
	"?":r"[a-z]",
	"_":r"[a,e,i,o,u,y]"
	}

var words = []
var rng = RandomNumberGenerator.new()
@onready var weights = JSON.parse_string(FileAccess.open("res://weights.json", FileAccess.READ).get_as_text())
signal clear(total: float, multiplier: float, is_unique: bool)
signal release(pos:Vector2i)
signal failed()
signal loaded()

func check_valid(prev_position:Vector2i,cur_position:Vector2i):
	if cur_position in selected_nodes:
		return false
	var val = cur_position - prev_position
	return (abs(val.x) <= 1 and abs(val.y) <= 1)

func reset():
	selected_word = ""
	said_words = {}
	is_pressed = false
	current_selected = Vector2i(-1,-1)
	trash_hovered = false
	selected_nodes = []
	score = 0
	

func random_letter():
	var total = 0
	for weight in weights:total += weights[weight]
	var random = rng.randf_range(0,total)
	for weight in weights:
		if weights[weight] > random:
			return weight
		random -= weights[weight]

func submit():
	var total = 0
	var multiplier = 1+(len(selected_word)*len_multiplier)
	var is_unique = not selected_word in said_words
	var has_special_char = false
	for letter in selected_word:
		if not letter in special_letters:
			total += get_value(letter)
		else:
			has_special_char = true
	score += ceil(total*multiplier)
	score += 100*int(is_unique)
	print("TOTAL: ",total)
	clear.emit(ceil(total),multiplier,is_unique)
	if not has_special_char:
		add_word(selected_word)
	selected_word = ""

func is_valid(word:String = selected_word):
	if len(word) <= len(words) and len(word) >= 3:
		var reg = RegEx.new()
		var regstr = r"\n%s\n"%word.to_lower().replace("?",special_letters['?']).replace("_",special_letters['_'])
		reg.compile(regstr)
		var result = reg.search(words[len(word)-1])
		if result and ("?" in word or "_" in word):
			var new_word = result.strings[0].to_upper().replace('\n','')
			print(new_word)
			add_word(new_word)
		return result
	else:
		return false

func color_gradient(weight: float,from: Color = Color.html("531CB3"),to: Color = Color.html("DBA8AC")):
	var difference = to-from
	return from+(difference*(weight/10))

func get_value(letter:String):
	return 20-floor(weights[letter.to_lower()])

@warning_ignore("shadowed_global_identifier")
func compile_words(mini = 1,maxi = 32):
	for i in range(mini,maxi):
		words.append(FileAccess.open("res://words/%s.txt" % i, FileAccess.READ).get_as_text())

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_GO_BACK_REQUEST:
		save()

func save():
	var save_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	save_game.store_var(get_data_to_save())

func get_data_to_save():
	return {
		'high_score': high_score,
		'global_said_words': global_said_words,
		'words_total': total_words,
		'universal_vowels_used': universal_vowels_used,
		'universal_letters_used': universal_letters_used,
		'version': version,
	}

func _ready():
	compile_words()
	if FileAccess.file_exists("user://savegame.save"):
		var data = FileAccess.open("user://savegame.save", FileAccess.READ).get_var()
		high_score = get_stat(data,'high_score')
		global_said_words =  get_stat(data,'global_said_words')
		total_words =  get_stat(data,'words_total')
		universal_letters_used =  get_stat(data,'universal_letters_used')
		universal_vowels_used =  get_stat(data,'universal_vowels_used')
	loaded.emit()

func add_word(new_word:String):
	if new_word in said_words:
		said_words[new_word] += 1
	else:
		said_words[new_word] = 1
	if new_word in global_said_words:
		global_said_words[new_word] += 1
	else:
		global_said_words[new_word] = 1
	total_words += 1

func get_stat(stats:Dictionary, stat: String,default:Variant = 0):
	if stat in stats:
		return stats[stat]
	else:
		return default
