#!/usr/bin/env false

# Note: Haven't tested this inside a submodule, not sure how it'll behave
current_git_root() {
    # Git hooks commonly override this variable to tell Git where to look. If it's set we should
    # prioritize it.
    if [ -n "${GIT_DIR:-}" ]; then
      # This sometimes points at the actual .git directory inside the repo...
      if [ "$(basename "${GIT_DIR}")" = ".git" ]; then
        # ... which is not what we want. This little hack is more reliable than just taking the
        # dirname and resolves symlinks as well.
        (cd "${GIT_DIR}/.." && pwd)
        return 0
      elif [ -d "${GIT_DIR}/.git" ]; then
        # Double check the root we were provided actually is a repo, this could probably be more
        # robust but ehh
        echo "${GIT_DIR}"
        return 0
      fi
    fi

    # If there wasn't an environment override then we're probably being called from within the
    # target git repo. Annoyingly if you're INSIDE the .git directory it won't recognize itself but
    # that's a pretty hard edge case.
    root="$(git rev-parse --show-toplevel 2>/dev/null)"

    # And we were in a repo, go ahead and return that
    if [ $? ]; then
      echo "${root}"
      return 0
    fi

    # Return an error if we weren't in a repo
    return 1
}
