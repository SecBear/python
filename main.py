#!/usr/bin/env python3
"""Main entry point for the application."""

import my_package


def main() -> None:
    """Main function."""
    print(f"Hello from {my_package.__name__} v{my_package.__version__}")
    print("🐍 Your uv2nix Python environment is working!")


if __name__ == "__main__":
    main()
