
# Aliases

alias youtube-mp3='youtube-dl --ignore-errors --extract-audio --audio-format mp3'
alias youtube='youtube-dl --proxy "socks5://127.0.0.1:9150" --ignore-errors -f best'
alias sy='brew services restart yabai && sudo yabai --load-sa && brew services restart skhd'
alias config-yabai='yabai -m config layout bsp'
alias ey='brew services stop yabai && brew services stop skhd'

alias comptex='latexmk -pdf -pvc'

alias ds_kekbye='find . -name ".DS_Store" -delete'
 
# Ranger
function ranger-cd {
    local IFS=$'\t\n'
    local tempfile="$(mktemp -t tmp.XXXXXX)"
    local ranger_cmd=(
        command
        ranger
        --cmd="map Q chain shell echo %d > "$tempfile"; quitall"
    )

    ${ranger_cmd[@]} "$@"
    if [[ -f "$tempfile" ]] && [[ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]]; then
        cd -- "$(cat "$tempfile")" || return
    fi
    command rm -f -- "$tempfile" 2>/dev/null
}
 
alias r='ranger-cd'
