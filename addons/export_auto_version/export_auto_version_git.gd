@tool
class_name ExportAutoVersionGit
extends RefCounted

# Every git call the addon makes. Editor side only.

const MISSING: String = "ExportAutoVersion: git returned nothing for %s. \
Is git installed and the project inside a repository?"


# -C keeps git on the project even when the editor was launched elsewhere.
static func run(arguments: PackedStringArray, what: String, quiet: bool = false) -> String:
	var call: PackedStringArray = PackedStringArray(
		["-C", ProjectSettings.globalize_path("res://")]
	)
	call.append_array(arguments)
	var output: Array = []
	var code: int = OS.execute("git", call, output, true)
	var answer: String = String(output[0]).strip_edges() if not output.is_empty() else ""
	if code != 0 or answer.is_empty():
		if not quiet:
			push_warning(MISSING % what)
		return ""
	return answer


static func commit_count() -> String:
	return run(["rev-list", "--count", "HEAD"], "the commit count")


static func commit_sha(length: int) -> String:
	return run(["rev-parse", "--short=" + str(length), "HEAD"], "the commit sha")


static func branch_name() -> String:
	return run(["rev-parse", "--abbrev-ref", "HEAD"], "the branch name")


# Empty when the repository has no tags yet, which is not worth warning about.
static func latest_tag() -> String:
	return run(["describe", "--tags", "--abbrev=0"], "the latest tag", true)


# Never omit the range: bare `git shortlog` reads stdin and hangs the export.
static func shortlog(range_spec: String) -> String:
	return run(["shortlog", "--no-merges", range_spec], "the shortlog")
