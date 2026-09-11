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
Needs `git` on `PATH`.
Without it the export still runs, falling back to the base version with a warning.

## Settings

*Project Settings > Export Auto Version*.

| Setting | Default | Does |
| --- | --- | --- |
| `base_version` | `0.1` | The release you are cutting. Include a `v` if you want one. |
| `build_tag` | `Commit count` | What gets appended. `Commit count` always rises, `Commit sha` pins the commit, `None` leaves the base alone. |
| `separator` | `.` | Joins base to tag. A dot gives `0.1.372`, a plus gives `0.1+372`. |
| `sha_length` | `7` | Characters of the sha to keep, 4 to 40. |
| `also_save_version_to_project_godot` | `off` | Off, the version lives only inside the build. On, the export also writes it into `project.godot`, so you can commit it. |
| `branch_in_version` | `off` | Append the branch, so a build off `dev` reads `0.1.372-dev`. Slashes become dashes. |
| `branch_separator` | `-` | Joins the version to the branch. |
| `branches_without_a_suffix` | `main,master` | Branches that add no suffix. Comma separated, case insensitive. |
| `write_changelog_on_export` | `off` | Write a git shortlog into the project on every export. |
| `changelog_path` | `res://CHANGELOG.md` | Where it goes. Rewritten in full each export, so do not hand-edit it. |

## Runtime

```gdscript
var release: String = ExportAutoVersion.version()
```

Returns the stamp in an exported build, `0.1.dev` in the editor.
`ExportAutoVersion.is_tagged_build()` distinguishes them.

## Changelog

Commits since the latest git tag, or the whole history if the repo has no tags.
It lands in the project, not in the build.

```markdown
# v0.1.372-dev

Generated 2026-09-11.

## Changes since v0.1.0

Mark (15):
      Shop updates
```

## How it works

An `EditorExportPlugin` sets `application/config/version` in `_export_begin`.
The engine writes `project.binary` into the pack from live settings after that callback, so the build carries the stamp while the file on disk is untouched.

*Export Auto Version: print build version* in the Tools menu prints what the next export would stamp.

## License

MIT, see `LICENSE`.
