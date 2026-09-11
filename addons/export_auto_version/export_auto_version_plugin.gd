@tool
class_name ExportAutoVersionPlugin
extends EditorPlugin

# Declares the project settings the stamper reads, and hooks it into export.

const MENU_ITEM: String = "Export Auto Version: print build version"
const HELP_ITEM: String = "Export Auto Version: what do these settings do?"

const HELP: Dictionary[String, String] = {
	ExportAutoVersion.SETTING_BASE:
		"The release you are cutting, such as 0.1.",
	ExportAutoVersion.SETTING_TAG:
		"Appends nothing, the git commit count, or the short commit sha.",
	ExportAutoVersion.SETTING_SEPARATOR:
		"Joins base to tag. A dot gives 0.1.372, a plus gives 0.1+372.",
	ExportAutoVersion.SETTING_SHA_LENGTH:
		"How many characters of the sha to keep.",
	ExportAutoVersion.SETTING_PERSIST:
		"Off, the version lives only inside the exported build. On, the export "
			+ "also writes it into project.godot, so you can commit it.",
	ExportAutoVersion.SETTING_BRANCH:
		"Append the git branch, so a build off dev reads 0.1.372-dev.",
	ExportAutoVersion.SETTING_BRANCH_SEPARATOR:
		"Joins the version to the branch name.",
	ExportAutoVersion.SETTING_QUIET_BRANCHES:
		"Branches that add no suffix, so a release off main stays 0.1.372.",
	ExportAutoVersion.SETTING_CHANGELOG:
		"Write a git shortlog into the project on every export.",
	ExportAutoVersion.SETTING_CHANGELOG_PATH:
		"Where that changelog goes. It is rewritten in full each export.",
}

var _stamper: ExportVersionStamper = null
var _inspector: ExportAutoVersionInspector = null


func _enter_tree() -> void:
	_declare_settings()
	_stamper = ExportVersionStamper.new()
	add_export_plugin(_stamper)
	add_tool_menu_item(MENU_ITEM, _print_version)
	add_tool_menu_item(HELP_ITEM, _print_help)
	_inspector = ExportAutoVersionInspector.new()
	_inspector.setup(HELP)
	add_inspector_plugin(_inspector)


func _exit_tree() -> void:
	remove_tool_menu_item(MENU_ITEM)
	remove_tool_menu_item(HELP_ITEM)
	if _stamper != null:
		remove_export_plugin(_stamper)
		_stamper = null
	if _inspector != null:
		remove_inspector_plugin(_inspector)
		_inspector = null


# Answers "what would an export stamp right now" without running one.
func _print_version() -> void:
	print("ExportAutoVersion: the next export tags %s" % _stamper.build_version())


func _print_help() -> void:
	print("ExportAutoVersion settings:")
	for key: String in HELP:
		print("  %s\n      %s" % [key, HELP[key]])
	print("  Read it in game with: ExportAutoVersion.version()")


func _declare_settings() -> void:
	var added: bool = false
	added = _declare(ExportAutoVersion.SETTING_BASE, ExportAutoVersion.DEFAULT_BASE, {
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_PLACEHOLDER_TEXT,
		"hint_string": "0.1",
	}) or added
	added = _declare(ExportAutoVersion.SETTING_TAG,
			ExportAutoVersion.BuildTag.COMMIT_COUNT, {
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": "None (base version only),Commit count (numeric),Commit sha",
	}) or added
	added = _declare(ExportAutoVersion.SETTING_SEPARATOR,
			ExportAutoVersion.DEFAULT_SEPARATOR, {
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_PLACEHOLDER_TEXT,
		"hint_string": ". or + or -",
	}) or added
	added = _declare(ExportAutoVersion.SETTING_SHA_LENGTH,
			ExportAutoVersion.DEFAULT_SHA_LENGTH, {
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "4,40,1",
	}) or added
	added = _declare(ExportAutoVersion.SETTING_PERSIST, false, {
		"type": TYPE_BOOL,
	}) or added
	added = _declare(ExportAutoVersion.SETTING_BRANCH, false, {
		"type": TYPE_BOOL,
	}) or added
	added = _declare(ExportAutoVersion.SETTING_BRANCH_SEPARATOR,
			ExportAutoVersion.DEFAULT_BRANCH_SEPARATOR, {
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_PLACEHOLDER_TEXT,
		"hint_string": "- or +",
	}) or added
	added = _declare(ExportAutoVersion.SETTING_QUIET_BRANCHES,
			ExportAutoVersion.DEFAULT_QUIET_BRANCHES, {
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_PLACEHOLDER_TEXT,
		"hint_string": "main,master",
	}) or added
	added = _declare(ExportAutoVersion.SETTING_CHANGELOG, false, {
		"type": TYPE_BOOL,
	}) or added
	added = _declare(ExportAutoVersion.SETTING_CHANGELOG_PATH,
			ExportAutoVersion.DEFAULT_CHANGELOG_PATH, {
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_PLACEHOLDER_TEXT,
		"hint_string": "res://CHANGELOG.md",
	}) or added
	if added:
		ProjectSettings.save()


# True when the setting was missing, so the caller knows to write project.godot.
func _declare(key: String, default: Variant, info: Dictionary) -> bool:
	var added: bool = not ProjectSettings.has_setting(key)
	if added:
		ProjectSettings.set_setting(key, default)
	ProjectSettings.set_initial_value(key, default)
	var property: Dictionary = info.duplicate()
	property["name"] = key
	ProjectSettings.add_property_info(property)
	ProjectSettings.set_as_basic(key, true)
	return added
