# Python Development Template with uv2nix

A template for Python development using uv and Nix via uv2nix for reproducible
development environments.

## Prerequisites

- [Nix](https://nixos.org/download.html) with flakes enabled
- [direnv](https://direnv.net/) for automatic environment loading

## Quick Start

1. **Clone this template:**
   ```bash
   git clone <this-repo> my-python-project
   cd my-python-project
   ```

2. **Allow direnv:**
   ```bash
   direnv allow
   ```

3. **Start developing:**
   ```bash
   uv run python main.py
   ```

## Project Structure

```
.
├── my_package/           # Python package
│   └── __init__.py
├── main.py               # Entry point
├── pyproject.toml        # Python project configuration
├── uv.lock               # Locked dependencies
├── flake.nix             # Nix flake configuration
├── devshell.nix          # Development shell configuration
└── .envrc                # direnv configuration
```

## Managing Dependencies

### Add a dependency:

```bash
uv add requests
```

### Add a development dependency:

```bash
uv add --dev pytest black mypy
```

### Remove a dependency:

```bash
uv remove requests
```

### After adding/removing dependencies:

```bash
# Exit and re-enter the shell to rebuild the Nix environment
exit
cd .  # or just cd back into the directory
```

## Development Commands

```bash
# Run Python
uv run python

# Run your main script
uv run python main.py

# Run tests
uv run pytest

# Format code
uv run ruff format

# Lint code  
uv run ruff check
```

## Customization

### Python Version

Edit `devshell.nix` and change:

```nix
python = pkgs.python311;  # Change to python312, etc.
```

### System Dependencies

Add system packages in `devshell.nix` under `packages`:

```nix
packages = with pkgs; [
  # ... existing packages
  postgresql  # for psycopg2
  libmysqlclient  # for mysqlclient
  # etc.
];
```

### Package Overrides

If a Python package needs system dependencies, add overrides in `devshell.nix`:

```nix
overlay = workspace.mkPyprojectOverlay {
  sourcePreference = "wheel";
};
```

## Template Usage

To use this as a template:

1. **Update project name** in `pyproject.toml`:
   ```toml
   [project]
   name = "your-project-name"
   ```

2. **Rename package directory:**
   ```bash
   mv my_package your_package_name
   ```

3. **Update package reference** in `pyproject.toml`:
   ```toml
   [tool.hatch.build.targets.wheel]
   packages = ["your_package_name"]
   ```

4. **Lock dependencies:**
   ```bash
   uv lock
   ```

## Troubleshooting

### "reflexive symlinks" error

This happens when there are no dependencies. Add at least one dependency to
resolve.

### "attribute 'dev' missing" error

The development dependencies aren't available. Make sure you have dev
dependencies in `pyproject.toml` or the code handles missing dev deps
gracefully.

### Build errors

Make sure your package structure matches what's specified in `pyproject.toml`.
The package directory should exist and contain an `__init__.py` file.

## How It Works

- **uv** manages Python dependencies and virtual environments
- **uv2nix** converts `uv.lock` into Nix expressions
- **Nix** provides reproducible system dependencies and Python packages
- **direnv** automatically activates the environment when you enter the
  directory

This setup gives you:

- ✅ Reproducible environments across machines
- ✅ Fast dependency resolution with uv
- ✅ System-level dependencies managed by Nix
- ✅ Automatic environment activation with direnv
- ✅ Lock file for exact dependency versions

