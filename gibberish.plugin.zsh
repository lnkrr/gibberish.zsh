local ycuken=$'йцукенгшщзхъфывапролджэячсмитьбюё\
ЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮЁ\
"№;:?.,/'

local qwerty=$'qwertyuiop[]asdfghjkl;\'zxcvbnm,.`\
QWERTYUIOP{}ASDFGHJKL:"ZXCVBNM<>~@#$^&/?|'

_gibberish_error() {
    echo "gibberish: error: $1" >&2
}

_gibberish_get_layout() {
    case "$1" in
        "qwerty")
            echo "$qwerty"
            ;;
        "ycuken" | "йцукен")
            echo "$ycuken"
            ;;
        *)
            _gibberish_error "invalid layout: '$1'"
            return 1
            ;;
    esac
}

if [[ ! -v GIBBERISH_MAP_FROM ]]; then
    export GIBBERISH_MAP_FROM="$ycuken"
fi

if [[ ! -v GIBBERISH_MAP_TO ]]; then
    export GIBBERISH_MAP_TO="$qwerty"
fi

if [[ -v GIBBERISH_FROM ]]; then
    export GIBBERISH_MAP_FROM="$(_gibberish_get_layout "$GIBBERISH_FROM")"
fi

if [[ -v GIBBERISH_TO ]]; then
    export GIBBERISH_MAP_TO="$(_gibberish_get_layout "$GIBBERISH_TO")"
fi

typeset -gA _gibberish_map
local i

for (( i=1; i <= $#GIBBERISH_MAP_FROM; ++i )); do
    _gibberish_map[${GIBBERISH_MAP_FROM[i]}]="${GIBBERISH_MAP_TO[i]}"
done

_gibberish_fix() {
    local input="$*"
    local i output="" char mapped

    for (( i=1; i <= $#input; i++ )); do
        char="${input[i]}"
        mapped="${_gibberish_map[$char]}"

        if [ -n "$mapped" ]; then
            output+="$mapped"
        else
            output+="$char"
        fi
    done

    echo "$output"
}

command_not_found_handler() {
    local cmd="$(_gibberish_fix "$1")"

    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "zsh: command not found: $1" >&2
        return 127
    fi

    shift

    local args=()

    for arg in "$@"; do
        args+=( "$(_gibberish_fix "$arg")" )
    done

    local suggestion="$cmd"

    if (( ${#args[@]} )); then
        suggestion+=" ${args[*]}"
    fi

    echo -n "zsh: correct to '$suggestion' [ny]? "
    read -k 1 reply
    echo

    case "$reply" in
        [Yy])
            ;;
        *)
            return
            ;;
    esac

    "$cmd" "${args[@]}"
    return $?
}
