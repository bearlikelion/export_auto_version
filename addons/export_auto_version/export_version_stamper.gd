@tool
class_name ExportVersionStamper
extends EditorExportPlugin

# project.binary is written from live settings after _export_begin, so the stamp ships.

var _restore_to: String = ""


func _get_name() -> String:
	return "ExportAutoVersion"


func _export_begin(_features: PackedStringArray, _is_debug: bool, _path: String,
		_flags: int) -> void:
	_restore_to = String(ProjectSettings.get_setting(ExportAutoVersion.VERSION_SETTING, ""))
	var stamped: String = build_version()
	ProjectSettings.set_setting(ExportAutoVersion.VERSION_SETTING, stamped)
	if _persisting():
		ProjectSettings.save()
	print("ExportAutoVersion: tagged this build %s" % stamped)
	if ExportAutoVersion.writes_changelog():
		ExportChangelogWriter.write(stamped)


func _export_end() -> void:
	# The editor session outlives the export, so leave its settings as they were.
	if not _persisting():
		ProjectSettings.set_setting(ExportAutoVersion.VERSION_SETTING, _restore_to)


# Base version, the tag the settings asked for, then the branch if it earns one.
func build_version() -> String:
	var version: String = ExportAutoVersion.base_version()
	var tag: String = build_tag_value()
	if not tag.is_empty():
		version += ExportAutoVersion.separator() + tag
	var branch: String = branch_suffix()
	if not branch.is_empty():
		version += ExportAutoVersion.branch_separator() + branch
	return version


# Empty on the release branches, so main reads as a plain version.
func branch_suffix() -> String:
	if not ExportAutoVersion.branch_in_version():
		return ""
	var branch: String = ExportAutoVersionGit.branch_name()
	if branch.is_empty() or ExportAutoVersion.branch_is_quiet(branch):
		return ""
	# Slashes would read as a path in a version string.
	return branch.replace("/", "-")


# Empty when tagging is off, or when git cannot answer.
func build_tag_value() -> String:
	match ExportAutoVersion.build_tag():
		ExportAutoVersion.BuildTag.COMMIT_COUNT:
			return ExportAutoVersionGit.commit_count()
		ExportAutoVersion.BuildTag.COMMIT_SHA:
			return ExportAutoVersionGit.commit_sha(ExportAutoVersion.sha_length())
		_:
			return ""


func _persisting() -> bool:
	return bool(ProjectSettings.get_setting(ExportAutoVersion.SETTING_PERSIST, false))

