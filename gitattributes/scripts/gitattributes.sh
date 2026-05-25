#!/usr/bin/env bash
set -euo pipefail

LANGUAGES_DIR="$(cd "$(dirname "$0")" && pwd)"

usage() {
    cat <<'EOF'
gitattributes.sh - Generate .gitattributes files

Usage:
  gitattributes.sh generate [options]        Generate .gitattributes content
  gitattributes.sh list                       List available language presets
  gitattributes.sh help                       Show this help message

Options:
  -l, --lang <langs>    Comma-separated language presets to include
  -w, --write           Write output to .gitattributes in current directory
  -a, --append          Append to existing .gitattributes instead of overwriting
  -o, --output <path>   Specify output file path (default: .gitattributes)
      --no-base         Do not include the base rule (* text=auto eol=lf)

Base rule (always included unless --no-base):
  * text=auto eol=lf

Examples:
  gitattributes.sh generate
  gitattributes.sh generate --lang python,node
  gitattributes.sh generate --lang go,rust --write
  gitattributes.sh generate --lang java --output .gitattributes
  gitattributes.sh list
EOF
}

BASE_RULE="* text=auto eol=lf"

declare -A LANG_RULES

LANG_RULES[go]="*.go text eol=lf diff=golang
go.sum text eol=lf"

LANG_RULES[python]="*.py text eol=lf
*.pyi text eol=lf
requirements.txt text eol=lf
pipfile.lock text eol=lf"

LANG_RULES[node]="*.js text eol=lf
*.jsx text eol=lf
*.ts text eol=lf
*.tsx text eol=lf
*.json text eol=lf
*.css text eol=lf
*.scss text eol=lf
*.less text eol=lf
*.html text eol=lf
*.md text eol=lf
*.yaml text eol=lf
*.yml text eol=lf
package-lock.json text eol=lf
yarn.lock text eol=lf"

LANG_RULES[rust]="*.rs text eol=lf
Cargo.lock text eol=lf"

LANG_RULES[java]="*.java text eol=lf
*.kt text eol=lf
*.kts text eol=lf
*.scala text eol=lf
*.groovy text eol=lf
*.properties text eol=lf
*.xml text eol=lf
gradlew text eol=lf"

LANG_RULES[shell]="*.sh text eol=lf
*.bash text eol=lf
*.zsh text eol=lf"

generate() {
    local use_base="$1"
    local langs="$2"

    local result=""

    if [[ "${use_base}" == "true" ]]; then
        result="${BASE_RULE}"
    fi

    if [[ -n "${langs}" ]]; then
        IFS=',' read -ra lang_array <<< "${langs}"
        for lang in "${lang_array[@]}"; do
            lang=$(echo "${lang}" | tr '[:upper:]' '[:lower:]' | xargs)
            if [[ -v LANG_RULES["${lang}"] ]]; then
                if [[ -n "${result}" ]]; then
                    result="${result}

${LANG_RULES[${lang}]}"
                else
                    result="${LANG_RULES[${lang}]}"
                fi
            else
                echo "Warning: unknown language preset '${lang}'" >&2
            fi
        done
    fi

    echo "${result}"
}

list_languages() {
    echo "Available language presets:"
    for lang in "${!LANG_RULES[@]}"; do
        echo "  ${lang}"
    done | sort
}

write_file() {
    local content="$1"
    local filepath="$2"
    local append="$3"

    if [[ "${append}" == "true" ]] && [[ -f "${filepath}" ]]; then
        echo "" >> "${filepath}"
        echo "${content}" >> "${filepath}"
        echo "Appended to ${filepath}" >&2
    else
        echo "${content}" > "${filepath}"
        echo "Written to ${filepath}" >&2
    fi
}

if [[ $# -lt 1 ]]; then
    usage
    exit 1
fi

action="$1"
shift

case "${action}" in
    generate)
        do_write=false
        do_append=false
        use_base=true
        output_file=".gitattributes"
        langs=""

        while [[ $# -gt 0 ]]; do
            case "$1" in
                -l|--lang)
                    if [[ $# -lt 2 ]]; then
                        echo "Error: --lang requires a language list" >&2
                        exit 1
                    fi
                    langs="$2"
                    shift
                    ;;
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

        content=$(generate "${use_base}" "${langs}")

        if [[ "${do_write}" == "true" ]]; then
            write_file "${content}" "${output_file}" "${do_append}"
        else
            echo "${content}"
        fi
        ;;
    list)
        list_languages
        ;;
    help|--help|-h)
        usage
        ;;
    *)
        echo "Error: unknown action '${action}'" >&2
        echo "Run 'gitattributes.sh help' for usage information." >&2
        exit 1
        ;;
esac
