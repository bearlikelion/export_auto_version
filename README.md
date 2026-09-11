# Export Auto Version

Stamps every Godot export with a version: a base you set in Project Settings, plus a git tag.

```
0.1   + commit count            ->  0.1.372
0.1   + commit sha              ->  0.1.a1b2c3d
v0.1  + commit count + branch   ->  v0.1.372-dev    (on dev)
v0.1  + commit count + branch   ->  v0.1.372        (on main)
```

It writes Godot's own `application/config/version`, so anything already reading that setting picks the release up.

## Install

Copy `addons/export_auto_version/` into your project and enable **Export Auto Version** in *Project Settings > Plugins*.

## Settings

*Project Settings > Export Auto Version*. Each carries its description as a caption.

| Setting | Default | Does |
| --- | --- | --- |
| `base_version` | `0.1` | The release you are cutting. Include a `v` here if you want one. |
| `build_tag` | `Commit count` | `None`, `Commit count` (numeric), or `Commit sha`. |
| `separator` | `.` | Joins base to tag. |
| `sha_length` | `7` | Characters of the sha to keep. |
| `also_save_version_to_project_godot` | `off` | On, the version is also written to `project.godot` so it can be committed. Off, it exists only in the build. |
| `branch_in_version` | `off` | Append the git branch. Slashes become dashes. |
| `branch_separator` | `-` | Joins the version to the branch. |
| `branches_without_a_suffix` | `main,master` | Branches that add no suffix. Comma separated, case insensitive. |
| `write_changelog_on_export` | `off` | Write a git shortlog into the project on export. |
| `changelog_path` | `res://CHANGELOG.md` | Where it goes. Rewritten in full each export, so do not hand-edit it. |

## Runtime

```gdscript
var release: String = ExportAutoVersion.version()
```

Returns the stamp in an exported build, `0.1.dev` in the editor.
`ExportAutoVersion.is_tagged_build()` distinguishes them.
Reading `ProjectSettings.get_setting("application/config/version")` works too.

## Changelog output

Commits since the latest git tag, or the whole history if the repo has no tags.

```markdown
# v0.1.372-dev

Generated 2026-09-11.

## Changes since v0.1.0

Mark (15):
      Shop updates
```

It lands in the project, not in the build.

## Tools menu

- *Export Auto Version: print build version* prints what the next export would stamp.
- *Export Auto Version: what do these settings do?* prints every setting and its description.

## Requirements

Godot 4.x, `git` on `PATH`, project inside a repository.
Without git the export still runs and falls back to the base version, with a warning.

## How it works

An `EditorExportPlugin` sets `application/config/version` in `_export_begin`.
The engine writes `project.binary` into the pack from live settings after that callback, so the build carries the stamp while the file on disk is untouched.
The setting is restored when the export ends.

## License

MIT, see `LICENSE`.
