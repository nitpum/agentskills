#!/usr/bin/env bash
set -euo pipefail

BASE_URL="https://www.toptal.com/developers/gitignore/api"
BASE_TEMPLATES="windows,linux,macos,dotenv"

usage() {
    cat <<'EOF'
gitignore.sh - Interact with the gitignore.io API

Usage:
  gitignore.sh list                    List all available templates
  gitignore.sh search <keyword>        Search templates matching a keyword
  gitignore.sh generate <templates>    Generate .gitignore content
  gitignore.sh generate <templates> -w Generate and write to .gitignore file
  gitignore.sh help                    Show this help message

Options:
  -w, --write       Write output to .gitignore in the current directory
  -a, --append      Append to existing .gitignore instead of overwriting
  -o, --output      Specify output file path (default: .gitignore)
      --no-base     Do not include base templates (windows,linux,macos,dotenv,log)

Base templates (always included unless --no-base):
  windows,linux,macos,dotenv

Examples:
  gitignore.sh list
  gitignore.sh search python
  gitignore.sh generate python,node,visualstudiocode
  gitignore.sh generate python,node --write
  gitignore.sh generate go,rust,vim --output .gitignore
  gitignore.sh generate python --no-base
EOF
}

list_templates() {
    curl -sf "${BASE_URL}/list" | tr ',' '\n' | sort
}

search_templates() {
    local keyword="$1"
    curl -sf "${BASE_URL}/list" | tr ',' '\n' | grep -i "${keyword}" || echo "No templates found matching '${keyword}'"
}

generate() {
    local templates="$1"
    curl -sf "${BASE_URL}/${templates}"
}

write_gitignore() {
    local content="$1"
    local filepath="$2"
    local append="$3"

    if [[ "${append}" == "true" ]] && [[ -f "${filepath}" ]]; then
        echo "" >> "${filepath}"
        echo "${content}" >> "${filepath}"
        echo "Appended to ${filepath}"
    else
        echo "${content}" > "${filepath}"
        echo "Written to ${filepath}"
    fi
}

if [[ $# -lt 1 ]]; then
    usage
    exit 1
fi

command -v curl >/dev/null 2>&1 || { echo "Error: curl is required but not installed." >&2; exit 1; }

action="$1"
shift

case "${action}" in
    list)
        list_templates
        ;;
    search)
        if [[ $# -lt 1 ]]; then
            echo "Error: search requires a keyword argument" >&2
            exit 1
        fi
        search_templates "$1"
        ;;
    generate)
        if [[ $# -lt 1 ]]; then
            echo "Error: generate requires at least one template name" >&2
            exit 1
        fi
        templates="$1"
        shift

        do_write=false
        do_append=false
        use_base=true
        output_file=".gitignore"

        while [[ $# -gt 0 ]]; do
            case "$1" in
                -w|--write)
                    do_write=true
                    ;;
                -a|--append)
                    do_append=true
                    do_write=true
                    ;;
                --no-base)
                    use_base=false
                    ;;
                -o|--output)
                    if [[ $# -lt 2 ]]; then
                        echo "Error: --output requires a file path" >&2
                        exit 1
                    fi
                    output_file="$2"
                    do_write=true
                    shift
                    ;;
                *)
                    echo "Error: unknown option '$1'" >&2
                    exit 1
                    ;;
            esac
            shift
        done

        if [[ "${use_base}" == "true" ]]; then
            templates="${BASE_TEMPLATES},${templates}"
        fi

        content=$(generate "${templates}")

        if [[ "${do_write}" == "true" ]]; then
            write_gitignore "${content}" "${output_file}" "${do_append}"
        else
            echo "${content}"
        fi
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        echo "Error: unknown action '${action}'" >&2
        echo "Run 'gitignore.sh help' for usage information." >&2
        exit 1
        ;;
esac
