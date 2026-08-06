alias e="$EDITOR"
alias copy='printf "\033]52;c;$(base64 | tr -d "\n")\a"'
alias j='fg %$(jobs | fzf | sed '\''s/^\[\([0-9]*\)\].*/\1/'\'')'
