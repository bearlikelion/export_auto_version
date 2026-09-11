@tool
class_name ExportChangelogWriter
extends RefCounted

# Rewritten in full each export, so exporting twice cannot stack duplicate sections.

const SINCE_TAG: String = "## Changes since %s\n\n"
const SINCE_START: String = "## Changes so far\n\n"
const NOTHING: String = "No commits in this range.\n"


static func write(version: String) -> Error:
	var path: String = ExportAutoVersion.changelog_path()
	if path.is_empty():
		return ERR_INVALID_PARAMETER
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_warning("ExportAutoVersion: cannot write the changelog to %s" % path)
		return FileAccess.get_open_error()
	file.store_string(_document(version))
	file.close()
	print("ExportAutoVersion: wrote the changelog to %s" % path)
	return OK


static func _document(version: String) -> String:
	var tag: String = ExportAutoVersionGit.latest_tag()
	var range_spec: String = "%s..HEAD" % tag if not tag.is_empty() else "HEAD"
	var log: String = ExportAutoVersionGit.shortlog(range_spec)
	var text: String = "# %s\n\n" % version
	text += "Generated %s.\n\n" % Time.get_date_string_from_system()
	text += SINCE_TAG % tag if not tag.is_empty() else SINCE_START
	text += log + "\n" if not log.is_empty() else NOTHING
	return text
