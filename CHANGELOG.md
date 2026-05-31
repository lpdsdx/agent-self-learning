# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `update_usage.sh` — increment a record's `usageCount` and refresh its `lastVerified` timestamp when a learning is actually applied. Closes the gap where the feature was documented but the script was missing.
- `CONTRIBUTING.md` with development setup, coding conventions, and a PR checklist.
- GitHub issue templates (bug report, feature request) and a pull request template under `.github/`.

### Fixed
- Documentation referenced `update_usage.sh` without the script existing; the reference is now backed by a working implementation and listed in the README script table.

## [1.0.0] - 2026-03-23

### Added
- Initial release: cross-IDE self-learning system for AI coding agents.
- Core scripts: `add_learning.sh`, `list_learnings.sh`, `search_learnings.sh`, `decay_confidence.sh`, `detect_conflicts.sh`, `rebuild_index.sh`, `update_summary.sh`, `detect_env.sh`.
- Session lifecycle hooks: `session_start.sh`, `session_end.sh`.
- Four learning types (correction, remember, success_pattern, preference) with priority and confidence scoring.
- Confidence decay and conflict detection.
- Cross-platform support (macOS / Linux / Windows Git Bash / WSL).
- Support for Claude Code, Codex CLI, Gemini CLI, Cursor, Windsurf, and Cline / Roo Code.
- English and Chinese documentation.

[Unreleased]: https://github.com/lpdsdx/agent-self-learning/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/lpdsdx/agent-self-learning/releases/tag/v1.0.0
