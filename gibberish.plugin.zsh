local from="йцукенгшщзхъфывапролджэячсмитьбюёЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮЁ\"№;:?.,/"
local to="qwertyuiop[]asdfghjkl;'zxcvbnm,.\`QWERTYUIOP{}ASDFGHJKL:\"ZXCVBNM<>~@#\$^&/?|"

typeset -gA _gibberish_map
local i

for (( i=1; i <= $#from; ++i )); do
    _gibberish_map[${from[i]}]="${to[i]}"
done

_gibberish_fix() {
    local input="$*"

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
        echo "zsh: command not found: $1"
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
        [YyНн])
            ;;
        *)
            return
            ;;
    esac

    "$cmd" "${args[@]}"
    return $?
}
