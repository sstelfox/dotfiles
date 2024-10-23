#!/usr/bin/env false

current_git_root() {
    # Git hooks commonly override this variable to tell Git where to look. If it's set we should
    # prioritize it.
    if [ -n "$GIT_DIR" ]; then
        if [ "$(basename "$GIT_DIR")" = ".git" ]; then
            echo "$(cd "$GIT_DIR/.." && pwd)"
            return 0
        elif [ -d "$GIT_DIR/.git" ]; then
            echo "$GIT_DIR"
            return 0
        fi
    fi

    # Fallback: try to find git root from current directory
    local root="$(git rev-parse --show-toplevel 2>/dev/null)"

    if [ $? -eq 0 ]; then
        echo "$root"
        return 0
    fi

    # If all methods fail
    echo "Error: Unable to determine git repository root" >&2

    return 1
}
