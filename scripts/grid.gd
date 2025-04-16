extends Node2D
var size:Vector2
var offset_size:Vector2
@onready var resource = load("res://scenes/letter.tscn") 
# Called when the node enters the scene tree for the first time.
func make_grid(offset: Vector2i, length: Vector2i,object: Resource = resource):
	offset_size = offset
	size = length
	purge_children()
	for y in range(length.y):
		var row = Node2D.new()
		row.name = str(y)
		row.position.y = offset.y*y
		for x in range(length.x):
			var obj = object.instantiate()
			obj.position.x = offset.x*x
			obj.name = str(x)
			obj.grid_position = Vector2i(x,y)
			obj.letter = GameGlobal.random_letter()
			row.add_child(obj)
		add_child(row)


func purge_children():
	for child in get_children():child.free()

func remove_objs(positions:Array):
	for obj in positions:
		obj = get_grid_node(obj)
		obj.name = "QFREE"
		obj.free()

func release(obj:Vector2i):
	get_grid_node(obj).release()

func get_grid_node(pos: Vector2i):
	if pos.y >= 0 and get_child_count() > pos.y and not is_queued_for_deletion():
		if get_child(pos.y).get_node_or_null(str(pos.x)) != null:
			return get_child(pos.y).get_node(str(pos.x))
		elif last_resort_check_cause_im_tired_0n0(pos) != null:
			return last_resort_check_cause_im_tired_0n0(pos)

func last_resort_check_cause_im_tired_0n0(pos:Vector2i):
	for child in get_child(pos.y).get_children():
		if child.grid_position == pos:
			return child
	return null
	

func is_valid_point(pos: Vector2i):
	return pos.y >= 0 and get_child_count() > pos.y and pos.x >= 0 and not is_queued_for_deletion() and get_child(pos.y).get_node_or_null(str(pos.x)) != null


@warning_ignore("narrowing_conversion")
func shmoove(dir:int):
	var moves = {}
	
	for x in size.x:
		for y in size.y:
			if not is_valid_point(Vector2i(x,y)):
				if dir == GameGlobal.GRAVITY_UP:
					for i in size.y-y:
						i+=y
						if is_valid_point(Vector2i(x,i)):
							if not x in moves:
								moves[x] = {}
							if Vector2i(x,i) in moves[x]:
								moves[x][Vector2i(x,i)] += Vector2i(0,-1)
							else:
								moves[x][Vector2i(x,i)] = Vector2i(0,-1)
				elif dir == GameGlobal.GRAVITY_DOWN:
					for i in range(y,-1,-1):
						if is_valid_point(Vector2i(x,i)):
							if not x in moves:
								moves[x] = {}
							if Vector2i(x,i) in moves[x]:
								moves[x][Vector2i(x,i)] += Vector2i(0,1)
							else:
								moves[x][Vector2i(x,i)] = Vector2i(0,1)
				elif dir == GameGlobal.GRAVITY_LEFT:
					for i in size.x-x:
						i += x
						if is_valid_point(Vector2i(i,y)):
							if not y in moves:
								moves[y] = {}
							if Vector2i(i,y) in moves[y]:
								moves[y][Vector2i(i,y)] += Vector2i(-1,0)
							else:
								moves[y][Vector2i(i,y)] = Vector2i(-1,0)
				elif dir == GameGlobal.GRAVITY_RIGHT:
					for i in range(x,-1,-1):
						if is_valid_point(Vector2i(i,y)):
							if not y in moves:
								moves[y] = {}
							if Vector2i(i,y) in moves[y]:
								moves[y][Vector2i(i,y)] += Vector2i(1,0)
							else:
								moves[y][Vector2i(i,y)] = Vector2i(1,0)
	
	if len(moves) != 0:
		for i in moves:
			for index in len(moves[i]):
				var move = moves[i].keys()[index]
				change(move,move+moves[i][move],index,dir == GameGlobal.GRAVITY_DOWN or dir == GameGlobal.GRAVITY_UP)

@warning_ignore("incompatible_ternary")
func change(old_pos: Vector2i, new_pos: Vector2i,offset:float = 0,vertical:bool = true):
	var node = get_grid_node(old_pos)
	var tween = get_tree().create_tween()
	var pos_dif = abs(old_pos - new_pos)
	node.reparent(get_child(new_pos.y))
	tween.tween_interval(offset/10)
	tween.tween_property(node,"position:y" if vertical else "position:x",-32 if vertical else offset_size.x*new_pos.x,0.1*max(pos_dif.x,pos_dif.y))
	node.call_deferred("ihateyoucall")
	node.grid_position = new_pos
	
func clear_and_move(objs: Array,dir: int):
	remove_objs(objs)
	shmoove(dir)

#OLD COPYZ OF FUNC
#func shmoove(gravity: Vector2i = Vector2i(0,1)):
	#for y in range(len(object_matrix)-1,-1,-1):
		#for x in range(len(object_matrix[y])):
			#if size.x > x+gravity.x and size.y > y+gravity.y and typeof(object_matrix[y+gravity.y][x+gravity.x]) == 2 and typeof(object_matrix[y][x]) != 2:
				#object_matrix[y][x].reparent(get_node(str(y+gravity.y)))
				#object_matrix[y][x].grid_position = Vector2i(x+gravity.x,y+gravity.y)
				#var tween = get_tree().create_tween()
				#tween.tween_property(object_matrix[y][x],"position:y",-32,0.2)
				#object_matrix[y+gravity.y][x+gravity.x] = object_matrix[y][x] 
				#object_matrix[y][x] = 0

#NEWCOPYOFFUNC
#@warning_ignore("narrowing_conversion")
#func shmoove():
	#for y in size.y:
		#for x in size.x:
			#if not is_valid_point(Vector2i(x,y)):
				#print("NOT FOUND:", Vector2i(x,y))
				#for i in range(y,-1,-1):
					#if is_valid_point(Vector2i(x,i)) and i != 5:
						#var tween = get_tree().create_tween()
						#tween.tween_property(get_grid_node(Vector2i(x,i)),"position:y",-32,0.2)
						#change_no_tween(Vector2i(x,i),Vector2i(x,i+1))

func call_mass(nodes:Array,function:StringName):
	for obj in nodes:
		get_grid_node(obj).call(function)

func create_node(pos: Vector2i,letter: String):
	if not is_valid_point(pos):
		var node = resource.instantiate()
		node.position.x = pos.x*offset_size.x
		node.name = pos.x
		node.grid_position = pos
		node.letter = letter
		get_child(pos.y).add_child(node)
	else:
		print("%s IS A NODE THAT ALREADY EXISTS: FUNC CREATE NODE" % pos)

func has_vowel():
	for row in get_children():
		for node in row.get_children():
			if node.letter in GameGlobal.vowels:
				return true
	return false

func count():
	var number = 0
	for row in get_children():
		number += row.get_child_count()
	return number

"Happy birthday dad!!!!!!!!!!!!! 
I hope you had an incredible year! 
I am always grateful for everything you do.
From cooking to just being there for us. 
You are the perfect dad.
Lets have an even better year. Love, Farrel"
