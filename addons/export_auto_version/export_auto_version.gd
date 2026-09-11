class_name ExportAutoVersion
extends RefCounted

# Runtime face of the addon: the settings it owns and the version a build carries.

enum BuildTag {
	NONE,
	COMMIT_COUNT,
	COMMIT_SHA,
}

const SETTING_BASE: String = "export_auto_version/base_version"
const SETTING_TAG: String = "export_auto_version/build_tag"
const SETTING_SEPARATOR: String = "export_auto_version/separator"
const SETTING_SHA_LENGTH: String = "export_auto_version/sha_length"
const SETTING_PERSIST: String = "export_auto_version/also_save_version_to_project_godot"
const SETTING_BRANCH: String = "export_auto_version/branch_in_version"
const SETTING_BRANCH_SEPARATOR: String = "export_auto_version/branch_separator"
const SETTING_QUIET_BRANCHES: String = "export_auto_version/branches_without_a_suffix"
const SETTING_CHANGELOG: String = "export_auto_version/write_changelog_on_export"
const SETTING_CHANGELOG_PATH: String = "export_auto_version/changelog_path"

# Godot's own field, so anything already reading it picks the stamp up.
const VERSION_SETTING: String = "application/config/version"
const DEV_SUFFIX: String = "dev"

const DEFAULT_BASE: String = "0.1"
const DEFAULT_SEPARATOR: String = "."
const DEFAULT_SHA_LENGTH: int = 7
const DEFAULT_BRANCH_SEPARATOR: String = "-"
const DEFAULT_QUIET_BRANCHES: String = "main,master"
const DEFAULT_CHANGELOG_PATH: String = "res://CHANGELOG.md"


# The exported build's version, or "<base>.dev" when running from the editor.
static func version() -> String:
	var stamped: String = String(ProjectSettings.get_setting(VERSION_SETTING, "")).strip_edges()
	if not stamped.is_empty():
		return stamped
	return "%s%s%s" % [base_version(), separator(), DEV_SUFFIX]


static func base_version() -> String:
	return String(ProjectSettings.get_setting(SETTING_BASE, DEFAULT_BASE)).strip_edges()


static func separator() -> String:
	return String(ProjectSettings.get_setting(SETTING_SEPARATOR, DEFAULT_SEPARATOR))


static func build_tag() -> BuildTag:
	return ProjectSettings.get_setting(SETTING_TAG, BuildTag.COMMIT_COUNT) as BuildTag


static func sha_length() -> int:
	return clampi(int(ProjectSettings.get_setting(SETTING_SHA_LENGTH, DEFAULT_SHA_LENGTH)), 4, 40)


static func branch_in_version() -> bool:
	return bool(ProjectSettings.get_setting(SETTING_BRANCH, false))


static func branch_separator() -> String:
	return String(ProjectSettings.get_setting(SETTING_BRANCH_SEPARATOR, DEFAULT_BRANCH_SEPARATOR))


# The branches that read as "the release line", so they add no suffix.
static func branch_is_quiet(branch: String) -> bool:
	var listed: String = String(
		ProjectSettings.get_setting(SETTING_QUIET_BRANCHES, DEFAULT_QUIET_BRANCHES)
	)
	for entry: String in listed.split(",", false):
		if entry.strip_edges().nocasecmp_to(branch) == 0:
			return true
	return false


static func writes_changelog() -> bool:
	return bool(ProjectSettings.get_setting(SETTING_CHANGELOG, false))


static func changelog_path() -> String:
	return String(
		ProjectSettings.get_setting(SETTING_CHANGELOG_PATH, DEFAULT_CHANGELOG_PATH)
	).strip_edges()


# True once an export has stamped this build.
static func is_tagged_build() -> bool:
	return not String(ProjectSettings.get_setting(VERSION_SETTING, "")).strip_edges().is_empty()
