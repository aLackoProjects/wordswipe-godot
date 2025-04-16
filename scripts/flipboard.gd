@tool
extends RichTextEffect
class_name RichTextFlipBoard

var bbcode = "flipboard"

func get_text_server():
	return TextServerManager.get_primary_interface()

func _process_custom_fx(char_fx):
	var flips = char_fx.env.get("flips",20)
	char_fx.glyph_index = char_fx.glyph_index-flips-char_fx.env.get("offset",5)*char_fx.relative_index + min(char_fx.elapsed_time*char_fx.env.get("rate",5),flips+char_fx.env.get("offset",5)*char_fx.relative_index)
