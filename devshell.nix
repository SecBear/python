{
  pkgs,
  inputs,
  ...
}: let
  # Python version - change this as needed
  python = pkgs.python313;

  # Load workspace from current directory
  workspace = inputs.uv2nix.lib.workspace.loadWorkspace {
    workspaceRoot = ./.;
  };

  # Create overlay from uv.lock
  overlay = workspace.mkPyprojectOverlay {
    sourcePreference = "wheel";
  };

  # Build Python package set
  pythonSet =
    (pkgs.callPackage inputs.pyproject-nix.build.packages {
      inherit python;
    }).overrideScope (
      pkgs.lib.composeManyExtensions [
        inputs.pyproject-build-systems.overlays.default
        overlay
        # Add any package-specific overrides here
        (final: prev: {
          # Example: Fix a package that needs system deps
          # some-package = prev.some-package.overrideAttrs (old: {
          #   buildInputs = old.buildInputs ++ [ pkgs.some-lib ];
          # });
        })
      ]
    );

  # Create virtual environment from uv.lock
  pythonEnv = pythonSet.mkVirtualEnv "dev-env" (workspace.deps.default);
in
  pkgs.mkShell {
    packages = with pkgs; [
      # Shell
      zsh

      # Python tooling
      uv
      pythonEnv

      # Development tools
      git
      ripgrep
      fd

      # Common system dependencies for Python packages
      gcc
      stdenv.cc.cc.lib

      # Add these as needed for specific packages:
      # postgresql  # for psycopg2
      # libmysqlclient  # for mysqlclient
      # libjpeg  # for pillow
      # zlib  # for pillow
      # openssl  # for cryptography
      # libffi  # for cffi
    ];

    shell = "${pkgs.zsh}/bin/zsh";

    env =
      {
        # Prevent uv from downloading Python
        UV_PYTHON_DOWNLOADS = "never";
        UV_PYTHON = python.interpreter;

        # Useful for development
        PYTHONDONTWRITEBYTECODE = "1";
        PYTHONUNBUFFERED = "1";
      }
      // pkgs.lib.optionalAttrs pkgs.stdenv.isLinux {
        # For binary wheels on Linux
        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (with pkgs; [
          stdenv.cc.cc.lib
          # Add more libraries as needed
        ]);
      };

    shellHook = ''
      echo "🐍 Python ${python.version} environment ready!"
      echo "📦 Packages loaded from uv.lock via uv2nix"
      echo ""
      echo "Commands:"
      echo "  uv add <package>     - Add a dependency"
      echo "  uv add --dev <pkg>   - Add a dev dependency"
      echo "  uv remove <package>  - Remove a dependency"
      echo "  uv run python        - Run Python"
      echo "  uv run pytest        - Run tests"
      echo ""
      echo "After adding packages, restart shell with: exit && nix develop"
    '';
  }
