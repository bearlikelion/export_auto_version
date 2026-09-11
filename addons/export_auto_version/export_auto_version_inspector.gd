@tool
class_name ExportAutoVersionInspector
extends EditorInspectorPlugin

# Godot has no tooltip hook for custom project settings; descriptions ride as captions.

# Project Settings inspects a wrapper around ProjectSettings, not the singleton.
const FILTER_CLASS: String = "SectionedInspectorFilter"
const DIM: float = 0.6

var _descriptions: Dictionary[String, String] = {}


func setup(descriptions: Dictionary[String, String]) -> void:
	_descriptions = {}
	for key: String in descriptions:
		_descriptions[_leaf(key)] = descriptions[key]


func _can_handle(object: Object) -> bool:
	return object is ProjectSettings or object.get_class() == FILTER_CLASS


func _parse_property(_object: Object, _type: Variant.Type, name: String,
		_hint_type: PropertyHint, _hint_string: String, _usage_flags: int,
		_wide: bool) -> bool:
	var key: String = _leaf(name)
	if not _descriptions.has(key):
		return false
	# Added at the end so the caption lands under the setting's own editor.
	add_property_editor(name, _caption(_descriptions[key]), true)
	return false


# The wrapper strips the section, so settings arrive as bare names.
func _leaf(key: String) -> String:
	return key.substr(key.rfind("/") + 1)


func _caption(text: String) -> Label:
	var label: Label = Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.modulate.a = DIM
	return label
