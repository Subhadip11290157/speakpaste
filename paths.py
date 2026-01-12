from pathlib import Path

def project_root() -> Path:
    """
    Returns the absolute path to the project root directory.
    Assumes this file lives at the project root.
    """
    return Path(__file__).resolve().parent


def path(*parts) -> Path:
    """
    Convenience helper to build paths relative to project root.
    """
    return project_root().joinpath(*parts)
