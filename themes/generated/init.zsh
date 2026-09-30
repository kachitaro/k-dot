# Auto-generated Zsh init cache by 'dot inject' / 'dot theme reload'
# Do not edit manually - regenerate with 'dot inject' or 'dot theme reload'

# --- zoxide init ---
# shellcheck shell=bash

# =============================================================================
#
# Utility functions for zoxide.
#

# pwd based on the value of _ZO_RESOLVE_SYMLINKS.
function __zoxide_pwd() {
    \command cygpath -w "\builtin pwd -L"
}

# cd + custom logic based on the value of _ZO_ECHO.
function __zoxide_cd() {
    # shellcheck disable=SC2164
    \builtin cd -- "$@"
}

# =============================================================================
#
# Hook configuration for zoxide.
#

# Hook to add new entries to the database.
function __zoxide_hook() {
    # shellcheck disable=SC2312
    \command zoxide add -- "$(__zoxide_pwd)"
}

# Initialize hook.
\builtin typeset -ga precmd_functions
\builtin typeset -ga chpwd_functions
# shellcheck disable=SC2034,SC2296
precmd_functions=("${(@)precmd_functions:#__zoxide_hook}")
# shellcheck disable=SC2034,SC2296
chpwd_functions=("${(@)chpwd_functions:#__zoxide_hook}")
chpwd_functions+=(__zoxide_hook)

# Report common issues.
function __zoxide_doctor() {
    [[ ${_ZO_DOCTOR:-1} -ne 0 ]] || return 0
    [[ $- == *i* ]] || return 0
    [[ ${chpwd_functions[(Ie)__zoxide_hook]:-} -eq 0 ]] || return 0

    _ZO_DOCTOR=0
    \builtin printf '%s\n' \
        'zoxide: detected a possible configuration issue.' \
        'Please ensure that zoxide is initialized right at the end of your shell configuration file (usually ~/.zshrc).' \
        '' \
        'If the issue persists, consider filing an issue at:' \
        'https://github.com/ajeetdsouza/zoxide/issues' \
        '' \
        'Disable this message by setting _ZO_DOCTOR=0.' \
        '' >&2
}

# =============================================================================
#
# When using zoxide with --no-cmd, alias these internal functions as desired.
#

# Jump to a directory using only keywords.
function __zoxide_z() {
    __zoxide_doctor
    if [[ "$#" -eq 0 ]]; then
        __zoxide_cd ~
    elif [[ "$#" -eq 1 ]] && [[ "$1" = '-' ]]; then
        __zoxide_cd "${OLDPWD}"
    elif [[ "$#" -eq 1 ]] && { [[ "$1" =~ ^[-+][0-9]+$ ]] || (\builtin cd -q -- "$1") &>/dev/null; }; then
        __zoxide_cd "$1"
    elif [[ "$#" -eq 2 ]] && [[ "$1" = "--" ]]; then
        __zoxide_cd "$2"
    else
        \builtin local result
        # shellcheck disable=SC2312
        result="$(\command zoxide query --exclude "$(__zoxide_pwd)" -- "$@")" && __zoxide_cd "${result}"
    fi
}

# Jump to a directory using interactive search.
function __zoxide_zi() {
    __zoxide_doctor
    \builtin local result
    result="$(\command zoxide query --interactive -- "$@")" && __zoxide_cd "${result}"
}

# =============================================================================
#
# Commands for zoxide. Disable these using --no-cmd.
#

function z() {
    __zoxide_z "$@"
}

function zi() {
    __zoxide_zi "$@"
}

# Completions.
if [[ -o zle ]]; then
    __zoxide_result=''

    function __zoxide_z_complete() {
        # Only show completions when the cursor is at the end of the line.
        # shellcheck disable=SC2154
        [[ "${#words[@]}" -eq "${CURRENT}" ]] || return 0

        if [[ "${#words[@]}" -eq 2 ]]; then
            # Show completions for local directories.
            _cd -/

        elif [[ "${words[-1]}" == '' ]]; then
            # Show completions for Space-Tab.
            # shellcheck disable=SC2086
            __zoxide_result="$(\command zoxide query --exclude "$(__zoxide_pwd || \builtin true)" --interactive -- ${words[2,-1]} 2>/dev/null)" || __zoxide_result=''

            # Set a result to ensure completion doesn't re-run
            compadd -Q -S "" -- ""

            # Bind '\e[0n' to helper function.
            \builtin bindkey '\e[0n' '__zoxide_z_complete_helper'
            # Sends query device status code, which results in a '\e[0n' being sent to console input.
            \builtin printf '\e[5n'

            # Report that the completion was successful, so that we don't fall back
            # to another completion function.
            return 0
        fi
    }

    function __zoxide_z_complete_helper() {
        if [[ -n "${__zoxide_result}" ]]; then
            # shellcheck disable=SC2034,SC2296
            BUFFER="z ${(q-)__zoxide_result}"
            __zoxide_result=''
            \builtin zle reset-prompt
            \builtin zle accept-line
        else
            \builtin zle reset-prompt
        fi
    }
    \builtin zle -N __zoxide_z_complete_helper

    [[ "${+functions[compdef]}" -ne 0 ]] && \compdef __zoxide_z_complete z
fi

# =============================================================================
#
# To initialize zoxide, add this to your shell configuration file (usually ~/.zshrc):
#
# eval "$(zoxide init zsh)"

# --- atuin init ---
export ATUIN_TMUX_POPUP=false
# shellcheck disable=SC2034,SC2153,SC2086,SC2155

# Above line is because shellcheck doesn't support zsh, per
# https://github.com/koalaman/shellcheck/wiki/SC1071, and the ignore: param in
# ludeeus/action-shellcheck only supports _directories_, not _files_. So
# instead, we manually add any error the shellcheck step finds in the file to
# the above line ...

# Source this in your ~/.zshrc
autoload -U add-zsh-hook

zmodload zsh/datetime 2>/dev/null

# If zsh-autosuggestions is installed, configure it to use Atuin's search. If
# you'd like to override this, then add your config after the $(atuin init zsh)
# in your .zshrc
_zsh_autosuggest_strategy_atuin() {
    # silence errors, since we don't want to spam the terminal prompt while typing.
    # '$all-user' is a literal atuin author filter, not a shell variable
    # shellcheck disable=SC2016
    suggestion=$(ATUIN_QUERY="$1" atuin search --cmd-only --author '$all-user' --limit 1 --search-mode prefix 2>/dev/null)
}

if [ -n "${ZSH_AUTOSUGGEST_STRATEGY:-}" ]; then
    ZSH_AUTOSUGGEST_STRATEGY=("atuin" "${ZSH_AUTOSUGGEST_STRATEGY[@]}")
else
    ZSH_AUTOSUGGEST_STRATEGY=("atuin")
fi

if [[ -z "${ATUIN_SESSION:-}" || "${ATUIN_SHLVL:-}" != "$SHLVL" ]]; then
    export ATUIN_SESSION=$(atuin uuid)
    export ATUIN_SHLVL=$SHLVL
fi
ATUIN_HISTORY_ID=""

__atuin_osc133_command_executed() {
    [[ -n "${ATUIN_PTY_PROXY_ACTIVE:-}" ]] || return
    [[ -n "${ATUIN_HISTORY_ID:-}" ]] || return

    printf '\033]133;C\a'
}

__atuin_osc133_command_finished() {
    [[ -n "${ATUIN_PTY_PROXY_ACTIVE:-}" ]] || return
    [[ -n "${ATUIN_HISTORY_ID:-}" ]] || return

    printf '\033]133;D;%s;history_id=%s;session_id=%s\a' "$1" "$ATUIN_HISTORY_ID" "${ATUIN_SESSION:-}"
}

__atuin_osc133_prompt_start=$'%{\033]133;A;cl=line\a%}'
__atuin_osc133_prompt_end=$'%{\033]133;B\a%}'

__atuin_osc133_wrap_prompt() {
    local __atuin_prompt="${PROMPT-}"
    local __atuin_rprompt="${RPROMPT-}"

    __atuin_prompt="${__atuin_prompt//$__atuin_osc133_prompt_start/}"
    __atuin_prompt="${__atuin_prompt//$__atuin_osc133_prompt_end/}"
    __atuin_rprompt="${__atuin_rprompt//$__atuin_osc133_prompt_start/}"
    __atuin_rprompt="${__atuin_rprompt//$__atuin_osc133_prompt_end/}"

    if [[ -n "${ATUIN_PTY_PROXY_ACTIVE:-}" ]]; then
        PROMPT="${__atuin_osc133_prompt_start}${__atuin_prompt}"
        RPROMPT="${__atuin_rprompt}${__atuin_osc133_prompt_end}"
    else
        PROMPT="$__atuin_prompt"
        RPROMPT="$__atuin_rprompt"
    fi
}

_atuin_preexec() {
    local id
    id=$(ATUIN_SHELL=zsh atuin history start --hook -- "$1" 2>/dev/null)
    export ATUIN_HISTORY_ID="$id"
    __atuin_osc133_command_executed
    __atuin_preexec_time=${EPOCHREALTIME-}
}

_atuin_precmd() {
    local EXIT="$?" __atuin_precmd_time=${EPOCHREALTIME-}

    __atuin_osc133_wrap_prompt

    [[ -z "${ATUIN_HISTORY_ID:-}" ]] && return

    local duration=""
    if [[ -n $__atuin_preexec_time && -n $__atuin_precmd_time ]]; then
        printf -v duration %.0f $(((__atuin_precmd_time - __atuin_preexec_time) * 1000000000))
    fi

    __atuin_osc133_command_finished "$EXIT"
    (atuin history end --hook --exit $EXIT ${duration:+--duration=$duration} -- $ATUIN_HISTORY_ID >/dev/null 2>&1 &)
    export ATUIN_HISTORY_ID=""
}

# Allow comment lines at the interactive prompt, matching the default
# behavior of bash and fish (oh-my-zsh also enables this).
setopt interactive_comments

# With interactive_comments, a line starting with '#' is added to history
# without executing anything, so preexec never fires for it. Record such
# lines from the history hook instead.
_atuin_zshaddhistory() {
    # Guard in case the user unset the option after atuin init: the line then
    # executes as a normal command and is recorded by preexec/precmd.
    [[ -o interactive_comments ]] || return 0
    local line=${1%$'\n'}
    # Skip multi-line buffers: anything after the comment executes, so the
    # whole buffer is recorded by preexec/precmd.
    [[ $line == \#* && $line != *$'\n'* ]] || return 0
    local id
    id=$(ATUIN_SHELL=zsh atuin history start --hook -- "$line" 2>/dev/null)
    [[ -n $id ]] && (atuin history end --hook --exit 0 --duration=0 -- "$id" >/dev/null 2>&1 &)
    return 0
}

# Check if tmux popup is available (tmux >= 3.2)
__atuin_tmux_popup_check() {
    [[ -n "${TMUX-}" ]] || return 1
    [[ "${ATUIN_TMUX_POPUP:-true}" != "false" ]] || return 1

    # https://github.com/tmux/tmux/wiki/FAQ#how-often-is-tmux-released-what-is-the-version-number-scheme
    local tmux_version
    tmux_version=$(tmux -V 2>/dev/null | sed -n 's/^[^0-9]*\([0-9][0-9]*\.[0-9][0-9]*\).*/\1/p') # Could have used grep...
    [[ -z "$tmux_version" ]] && return 1

    local m1 m2
    m1=${tmux_version%%.*}
    m2=${tmux_version#*.}
    m2=${m2%%.*}
    [[ "$m1" =~ ^[0-9]+$ ]] || return 1
    [[ "$m2" =~ ^[0-9]+$ ]] || m2=0
    (( m1 > 3 || (m1 == 3 && m2 >= 2) ))
}

# Use global variable to fix scope issues with traps
__atuin_popup_tmpdir=""
__atuin_tmux_popup_cleanup() {
    [[ -n "$__atuin_popup_tmpdir" && -d "$__atuin_popup_tmpdir" ]] && command rm -rf "$__atuin_popup_tmpdir"
    __atuin_popup_tmpdir=""
}

__atuin_search_cmd() {
    local -a search_args=("$@")

    if __atuin_tmux_popup_check; then
        __atuin_popup_tmpdir=$(mktemp -d) || return 1
        local result_file="$__atuin_popup_tmpdir/result"

        trap '__atuin_tmux_popup_cleanup' EXIT HUP INT TERM

        local escaped_query escaped_args
        escaped_query=$(printf '%s' "$BUFFER" | sed "s/'/'\\\\''/g")
        escaped_args=""
        for arg in "${search_args[@]}"; do
            escaped_args+=" '$(printf '%s' "$arg" | sed "s/'/'\\\\''/g")'"
        done

        # In the popup, atuin goes to terminal, stderr goes to file
        local cdir popup_width popup_height
        cdir=$(pwd)
        popup_width="${ATUIN_TMUX_POPUP_WIDTH:-80%}" # Keep default value anyways
        popup_height="${ATUIN_TMUX_POPUP_HEIGHT:-60%}"
        tmux display-popup -d "$cdir" -w "$popup_width" -h "$popup_height" -E -E -- \
            sh -c "PATH='$PATH' ATUIN_SESSION='$ATUIN_SESSION' ATUIN_SHELL=zsh ATUIN_QUERY='$escaped_query' atuin search $escaped_args -i 2>'$result_file'"

        if [[ -f "$result_file" ]]; then
            cat "$result_file"
        fi

        __atuin_tmux_popup_cleanup
        trap - EXIT HUP INT TERM
    else
        ATUIN_SHELL=zsh ATUIN_QUERY=$BUFFER atuin search "${search_args[@]}" -i 3>&1 1>&2 2>&3 3>&-
    fi
}

_atuin_search() {
    emulate -L zsh
    zle -I

    # swap stderr and stdout, so that the tui stuff works
    # TODO: not this
    local output __atuin_status
    # shellcheck disable=SC2048
    output=$(__atuin_search_cmd $*)
    __atuin_status=$?

    zle reset-prompt
    # re-enable bracketed paste
    # shellcheck disable=SC2154
    echo -n ${zle_bracketed_paste[1]} >/dev/tty

    if (( __atuin_status != 0 )); then
        [[ -n $output ]] && print -r -- "$output" >/dev/tty
        return $__atuin_status
    fi

    if [[ -n $output ]]; then
        RBUFFER=""
        LBUFFER=$output

        if [[ $LBUFFER == __atuin_accept__:* ]]
        then
            LBUFFER=${LBUFFER#__atuin_accept__:}
            zle accept-line
        fi
    fi
}
_atuin_search_vicmd() {
    _atuin_search --keymap-mode=vim-normal
}
_atuin_search_viins() {
    _atuin_search --keymap-mode=vim-insert
}

_atuin_up_search() {
    # Only trigger if the buffer is a single line
    if [[ ! $BUFFER == *$'\n'* ]]; then
        _atuin_search --shell-up-key-binding "$@"
    else
        zle up-line
    fi
}
_atuin_up_search_vicmd() {
    _atuin_up_search --keymap-mode=vim-normal
}
_atuin_up_search_viins() {
    _atuin_up_search --keymap-mode=vim-insert
}

add-zsh-hook preexec _atuin_preexec
add-zsh-hook precmd _atuin_precmd
add-zsh-hook zshaddhistory _atuin_zshaddhistory

zle -N atuin-search _atuin_search
zle -N atuin-search-vicmd _atuin_search_vicmd
zle -N atuin-search-viins _atuin_search_viins
zle -N atuin-up-search _atuin_up_search
zle -N atuin-up-search-vicmd _atuin_up_search_vicmd
zle -N atuin-up-search-viins _atuin_up_search_viins

# These are compatibility widget names for "atuin <= 17.2.1" users.
zle -N _atuin_search_widget _atuin_search
zle -N _atuin_up_search_widget _atuin_up_search
bindkey -M emacs '^r' atuin-search
bindkey -M viins '^r' atuin-search-viins
bindkey -M vicmd '/' atuin-search
bindkey -M emacs '^[[A' atuin-up-search
bindkey -M vicmd '^[[A' atuin-up-search-vicmd
bindkey -M viins '^[[A' atuin-up-search-viins
bindkey -M emacs '^[OA' atuin-up-search
bindkey -M vicmd '^[OA' atuin-up-search-vicmd
bindkey -M viins '^[OA' atuin-up-search-viins
bindkey -M vicmd 'k' atuin-up-search-vicmd
_atuin_ai_cleanup() {
    true
}

# zle reset-prompt anchors the repaint at the cursor row: a multi-line
# prompt grows *upward*, overwriting whatever the inline TUI left on the
# rows above. Pad with prompt-height - 1 newlines first so the repaint
# lands on blank rows below the conversation instead.
_atuin_ai_reset_prompt() {
    local -a _prompt_lines=("${(@f)${(%%)PROMPT}}")
    local -i _pad=$(( ${#_prompt_lines} - 1 ))
    (( _pad > 0 )) && printf '\n%.0s' {1..$_pad} >/dev/tty
    zle reset-prompt
}

# Question mark at start of line - natural language mode.
# Named with 'self-' prefix so bracketed-paste-magic activates it during
# paste, allowing url-quote-magic to escape ? in pasted URLs via self-insert.
self-atuin-ai-question-mark() {
    # If buffer is empty or just contains '?', trigger natural language mode
    if [[ -z "$BUFFER" || "$BUFFER" == "?" ]]; then
        BUFFER=""
        # Close the semantic prompt zone (OSC 133 C, "command output
        # starts") before handing the terminal to the TUI. Without it,
        # terminals with shell integration (Ghostty) believe we are
        # still at the prompt, and their resize-time prompt reflow
        # erases everything below the prompt mark — including the
        # conversation the TUI printed.
        printf '\033]133;C\007' > /dev/tty
        local output
        output=$(atuin ai inline --hook 3>&1 1>&2 2>&3)

        # Clean up the inline viewport
        _atuin_ai_cleanup

        if [[ $output == __atuin_ai_print__:* ]]; then
            echo "${output#__atuin_ai_print__:}"
            _atuin_ai_reset_prompt
        elif [[ $output == __atuin_ai_cancel__ ]]; then
            _atuin_ai_reset_prompt
        elif [[ $output == __atuin_ai_execute__:* ]]; then
            RBUFFER=""
            LBUFFER=${output#__atuin_ai_execute__:}
            _atuin_ai_reset_prompt
            zle accept-line
        elif [[ $output == __atuin_ai_insert__:* ]]; then
            RBUFFER=""
            LBUFFER=${output#__atuin_ai_insert__:}
            _atuin_ai_reset_prompt
        elif [[ -n $output ]]; then
            RBUFFER=""
            LBUFFER=$output
            _atuin_ai_reset_prompt
        else
            _atuin_ai_reset_prompt
        fi
    else
        zle self-insert
    fi
}

# Set up keybindings
zle -N self-atuin-ai-question-mark
bindkey '?' self-atuin-ai-question-mark # Question mark

# --- fnm init ---
export PATH="C:\\Users\\JohnN\\AppData\\Local\\fnm_multishells\\16200_1787837639774":$PATH
export FNM_MULTISHELL_PATH="C:\\Users\\JohnN\\AppData\\Local\\fnm_multishells\\16200_1787837639774"
export FNM_VERSION_FILE_STRATEGY="local"
export FNM_DIR="C:\\Users\\JohnN\\scoop\\apps\\fnm\\current"
export FNM_LOGLEVEL="info"
export FNM_NODE_DIST_MIRROR="https://nodejs.org/dist"
export FNM_COREPACK_ENABLED="false"
export FNM_RESOLVE_ENGINES="true"
export FNM_ARCH="x64"
autoload -U add-zsh-hook
_fnm_autoload_hook () {
    if [[ -f .node-version || -f .nvmrc || -f package.json ]]; then
    fnm use --silent-if-unchanged
fi

}

add-zsh-hook -D chpwd _fnm_autoload_hook
add-zsh-hook chpwd _fnm_autoload_hook

rehash

# --- fzf init ---
### key-bindings.zsh ###
#     ____      ____
#    / __/___  / __/
#   / /_/_  / / /_
#  / __/ / /_/ __/
# /_/   /___/_/ key-bindings.zsh
#
# - $FZF_TMUX_OPTS
# - $FZF_CTRL_T_COMMAND
# - $FZF_CTRL_T_OPTS
# - $FZF_CTRL_R_COMMAND
# - $FZF_CTRL_R_OPTS
# - $FZF_ALT_C_COMMAND
# - $FZF_ALT_C_OPTS


# Key bindings
# ------------

# The code at the top and the bottom of this file is the same as in completion.zsh.
# Refer to that file for explanation.
if 'zmodload' 'zsh/parameter' 2>'/dev/null' && (( ${+options} )); then
  __fzf_key_bindings_options="options=(${(j: :)${(kv)options[@]}})"
else
  () {
    __fzf_key_bindings_options="setopt"
    'local' '__fzf_opt'
    for __fzf_opt in "${(@)${(@f)$(set -o)}%% *}"; do
      if [[ -o "$__fzf_opt" ]]; then
        __fzf_key_bindings_options+=" -o $__fzf_opt"
      else
        __fzf_key_bindings_options+=" +o $__fzf_opt"
      fi
    done
  }
fi

'builtin' 'emulate' 'zsh' && 'builtin' 'setopt' 'no_aliases'

{
if [[ -o interactive ]]; then

#----BEGIN INCLUDE common.sh
# NOTE: Do not directly edit this section, which is copied from "common.sh".
# To modify it, one can edit "common.sh" and run "./update.sh" to apply
# the changes. See code comments in "common.sh" for the implementation details.

__fzf_defaults() {
  printf '%s\n' "--height ${FZF_TMUX_HEIGHT:-40%} --min-height 20+ --bind=ctrl-z:ignore $1"
  command cat "${FZF_DEFAULT_OPTS_FILE-}" 2> /dev/null
  printf '%s\n' "${FZF_DEFAULT_OPTS-} $2"
}

__fzf_exec_awk() {
  if [[ -z ${__fzf_awk-} ]]; then
    __fzf_awk=awk
    if [[ $OSTYPE == solaris* && -x /usr/xpg4/bin/awk ]]; then
      __fzf_awk=/usr/xpg4/bin/awk
    elif command -v mawk > /dev/null 2>&1; then
      local n x y z d
      IFS=' .' read -r n x y z d <<< $(command mawk -W version 2> /dev/null)
      [[ $n == mawk ]] &&
        (((x * 1000 + y) * 1000 + z >= 1003004)) 2> /dev/null &&
        ((d >= 20230302)) 2> /dev/null &&
        __fzf_awk=mawk
    fi
  fi
  LC_ALL=C exec "$__fzf_awk" "$@"
}
#----END INCLUDE

# CTRL-T - Paste the selected file path(s) into the command line
__fzf_select() {
  setopt localoptions pipefail no_aliases 2> /dev/null
  local item
  FZF_DEFAULT_COMMAND=${FZF_CTRL_T_COMMAND:-} \
  FZF_DEFAULT_OPTS=$(__fzf_defaults "--reverse --walker=file,dir,follow,hidden --scheme=path" "${FZF_CTRL_T_OPTS-} -m") \
  FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd) "$@" < /dev/tty | while read -r item; do
    echo -n -E "${(q)item} "
  done
  local ret=$?
  echo
  return $ret
}

__fzfcmd() {
  [ -n "${TMUX_PANE-}" ] && { [ "${FZF_TMUX:-0}" != 0 ] || [ -n "${FZF_TMUX_OPTS-}" ]; } &&
    echo "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} -- " || echo "fzf"
}

fzf-file-widget() {
  LBUFFER="${LBUFFER}$(__fzf_select)"
  local ret=$?
  zle reset-prompt
  return $ret
}
if [[ "${FZF_CTRL_T_COMMAND-x}" != "" ]]; then
  zle     -N            fzf-file-widget
  bindkey -M emacs '^T' fzf-file-widget
  bindkey -M vicmd '^T' fzf-file-widget
  bindkey -M viins '^T' fzf-file-widget
fi

# ALT-C - cd into the selected directory
fzf-cd-widget() {
  setopt localoptions pipefail no_aliases 2> /dev/null
  local dir="$(
    FZF_DEFAULT_COMMAND=${FZF_ALT_C_COMMAND:-} \
    FZF_DEFAULT_OPTS=$(__fzf_defaults "--reverse --walker=dir,follow,hidden --scheme=path" "${FZF_ALT_C_OPTS-} +m") \
    FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd) < /dev/tty)"
  if [[ -z "$dir" ]]; then
    zle redisplay
    return 0
  fi
  zle push-line # Clear buffer. Auto-restored on next prompt.
  BUFFER="builtin cd -- ${(q)dir:a}"
  zle accept-line
  local ret=$?
  unset dir # ensure this doesn't end up appearing in prompt expansion
  zle reset-prompt
  return $ret
}
if [[ "${FZF_ALT_C_COMMAND-x}" != "" ]]; then
  zle     -N             fzf-cd-widget
  bindkey -M emacs '\ec' fzf-cd-widget
  bindkey -M vicmd '\ec' fzf-cd-widget
  bindkey -M viins '\ec' fzf-cd-widget
fi

# CTRL-R - Paste the selected command from history into the command line
fzf-history-widget() {
  local selected
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases noglob nobash_rematch 2> /dev/null
  # Ensure the module is loaded if not already, and the required features, such
  # as the associative 'history' array, which maps event numbers to full history
  # lines, are set. Also, make sure Perl is installed for multi-line output.
  if zmodload -F zsh/parameter p:{commands,history} 2>/dev/null && (( ${+commands[perl]} )); then
    selected="$(printf '%s\t%s\000' "${(kv)history[@]}" |
      perl -0 -ne 'if (!$seen{(/^\s*[0-9]+\**\t(.*)/s, $1)}++) { s/\n/\n\t/g; print; }' |
      FZF_DEFAULT_OPTS=$(__fzf_defaults "" "-n2..,.. --scheme=history --bind=ctrl-r:toggle-sort,alt-r:toggle-raw --wrap-sign '\t↳ ' --highlight-line ${FZF_CTRL_R_OPTS-} --query=${(qqq)LBUFFER} +m --read0") \
      FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd))"
  else
    selected="$(fc -rl 1 | __fzf_exec_awk '{ cmd=$0; sub(/^[ \t]*[0-9]+\**[ \t]+/, "", cmd); if (!seen[cmd]++) print $0 }' |
      FZF_DEFAULT_OPTS=$(__fzf_defaults "" "-n2..,.. --scheme=history --bind=ctrl-r:toggle-sort,alt-r:toggle-raw --wrap-sign '\t↳ ' --highlight-line ${FZF_CTRL_R_OPTS-} --query=${(qqq)LBUFFER} +m") \
      FZF_DEFAULT_OPTS_FILE='' $(__fzfcmd))"
  fi
  local ret=$?
  if [ -n "$selected" ]; then
    if [[ $(__fzf_exec_awk '{print $1; exit}' <<< "$selected") =~ ^[1-9][0-9]* ]]; then
      zle vi-fetch-history -n $MATCH
    else # selected is a custom query, not from history
      LBUFFER="$selected"
    fi
  fi
  zle reset-prompt
  return $ret
}
if [[ ${FZF_CTRL_R_COMMAND-x} != "" ]]; then
  if [[ -n ${FZF_CTRL_R_COMMAND-} ]]; then
    echo "warning: FZF_CTRL_R_COMMAND is set to a custom command, but custom commands are not yet supported for CTRL-R" >&2
  fi
  zle     -N            fzf-history-widget
  bindkey -M emacs '^R' fzf-history-widget
  bindkey -M vicmd '^R' fzf-history-widget
  bindkey -M viins '^R' fzf-history-widget
fi
fi

} always {
  eval $__fzf_key_bindings_options
  'unset' '__fzf_key_bindings_options'
}
### end: key-bindings.zsh ###
### completion.zsh ###
#     ____      ____
#    / __/___  / __/
#   / /_/_  / / /_
#  / __/ / /_/ __/
# /_/   /___/_/ completion.zsh
#
# - $FZF_TMUX                 (default: 0)
# - $FZF_TMUX_OPTS            (default: empty)
# - $FZF_COMPLETION_TRIGGER   (default: '**')
# - $FZF_COMPLETION_OPTS      (default: empty)
# - $FZF_COMPLETION_PATH_OPTS (default: empty)
# - $FZF_COMPLETION_DIR_OPTS  (default: empty)


# Both branches of the following `if` do the same thing -- define
# __fzf_completion_options such that `eval $__fzf_completion_options` sets
# all options to the same values they currently have. We'll do just that at
# the bottom of the file after changing options to what we prefer.
#
# IMPORTANT: Until we get to the `emulate` line, all words that *can* be quoted
# *must* be quoted in order to prevent alias expansion. In addition, code must
# be written in a way works with any set of zsh options. This is very tricky, so
# careful when you change it.
#
# Start by loading the builtin zsh/parameter module. It provides `options`
# associative array that stores current shell options.
if 'zmodload' 'zsh/parameter' 2>'/dev/null' && (( ${+options} )); then
  # This is the fast branch and it gets taken on virtually all Zsh installations.
  #
  # ${(kv)options[@]} expands to array of keys (option names) and values ("on"
  # or "off"). The subsequent expansion# with (j: :) flag joins all elements
  # together separated by spaces. __fzf_completion_options ends up with a value
  # like this: "options=(shwordsplit off aliases on ...)".
  __fzf_completion_options="options=(${(j: :)${(kv)options[@]}})"
else
  # This branch is much slower because it forks to get the names of all
  # zsh options. It's possible to eliminate this fork but it's not worth the
  # trouble because this branch gets taken only on very ancient or broken
  # zsh installations.
  () {
    # That `()` above defines an anonymous function. This is essentially a scope
    # for local parameters. We use it to avoid polluting global scope.
    'local' '__fzf_opt'
    __fzf_completion_options="setopt"
    # `set -o` prints one line for every zsh option. Each line contains option
    # name, some spaces, and then either "on" or "off". We just want option names.
    # Expansion with (@f) flag splits a string into lines. The outer expansion
    # removes spaces and everything that follow them on every line. __fzf_opt
    # ends up iterating over option names: shwordsplit, aliases, etc.
    for __fzf_opt in "${(@)${(@f)$(set -o)}%% *}"; do
      if [[ -o "$__fzf_opt" ]]; then
        # Option $__fzf_opt is currently on, so remember to set it back on.
        __fzf_completion_options+=" -o $__fzf_opt"
      else
        # Option $__fzf_opt is currently off, so remember to set it back off.
        __fzf_completion_options+=" +o $__fzf_opt"
      fi
    done
    # The value of __fzf_completion_options here looks like this:
    # "setopt +o shwordsplit -o aliases ..."
  }
fi

# Enable the default zsh options (those marked with <Z> in `man zshoptions`)
# but without `aliases`. Aliases in functions are expanded when functions are
# defined, so if we disable aliases here, we'll be sure to have no pesky
# aliases in any of our functions. This way we won't need prefix every
# command with `command` or to quote every word to defend against global
# aliases. Note that `aliases` is not the only option that's important to
# control. There are several others that could wreck havoc if they are set
# to values we don't expect. With the following `emulate` command we
# sidestep this issue entirely.
'builtin' 'emulate' 'zsh' && 'builtin' 'setopt' 'no_aliases'

# This brace is the start of try-always block. The `always` part is like
# `finally` in lesser languages. We use it to *always* restore user options.
{
# The 'emulate' command should not be placed inside the interactive if check;
# placing it there fails to disable alias expansion. See #3731.
if [[ -o interactive ]]; then

# To use custom commands instead of find, override _fzf_compgen_{path,dir}
#
#   _fzf_compgen_path() {
#     echo "$1"
#     command find -L "$1" \
#       -name .git -prune -o -name .hg -prune -o -name .svn -prune -o \( -type d -o -type f -o -type l \) \
#       -a -not -path "$1" -print 2> /dev/null | sed 's@^\./@@'
#   }
#
#   _fzf_compgen_dir() {
#     command find -L "$1" \
#       -name .git -prune -o -name .hg -prune -o -name .svn -prune -o -type d \
#       -a -not -path "$1" -print 2> /dev/null | sed 's@^\./@@'
#   }

###########################################################

#----BEGIN INCLUDE common.sh
# NOTE: Do not directly edit this section, which is copied from "common.sh".
# To modify it, one can edit "common.sh" and run "./update.sh" to apply
# the changes. See code comments in "common.sh" for the implementation details.

__fzf_defaults() {
  printf '%s\n' "--height ${FZF_TMUX_HEIGHT:-40%} --min-height 20+ --bind=ctrl-z:ignore $1"
  command cat "${FZF_DEFAULT_OPTS_FILE-}" 2> /dev/null
  printf '%s\n' "${FZF_DEFAULT_OPTS-} $2"
}

__fzf_exec_awk() {
  if [[ -z ${__fzf_awk-} ]]; then
    __fzf_awk=awk
    if [[ $OSTYPE == solaris* && -x /usr/xpg4/bin/awk ]]; then
      __fzf_awk=/usr/xpg4/bin/awk
    elif command -v mawk > /dev/null 2>&1; then
      local n x y z d
      IFS=' .' read -r n x y z d <<< $(command mawk -W version 2> /dev/null)
      [[ $n == mawk ]] &&
        (((x * 1000 + y) * 1000 + z >= 1003004)) 2> /dev/null &&
        ((d >= 20230302)) 2> /dev/null &&
        __fzf_awk=mawk
    fi
  fi
  LC_ALL=C exec "$__fzf_awk" "$@"
}
#----END INCLUDE

__fzf_comprun() {
  if [[ "$(type _fzf_comprun 2>&1)" =~ function ]]; then
    _fzf_comprun "$@"
  elif [ -n "${TMUX_PANE-}" ] && { [ "${FZF_TMUX:-0}" != 0 ] || [ -n "${FZF_TMUX_OPTS-}" ]; }; then
    shift
    if [ -n "${FZF_TMUX_OPTS-}" ]; then
      fzf-tmux ${(Q)${(Z+n+)FZF_TMUX_OPTS}} -- "$@"
    else
      fzf-tmux -d ${FZF_TMUX_HEIGHT:-40%} -- "$@"
    fi
  else
    shift
    fzf "$@"
  fi
}

# Extract the name of the command. e.g. ls; foo=1 ssh **<tab>
__fzf_extract_command() {
  # Control completion with the "compstate" parameter, insert and list nothing
  compstate[insert]=
  compstate[list]=
  cmd_word="${(Q)words[1]}"
}

__fzf_generic_path_completion() {
  local base lbuf compgen fzf_opts suffix tail dir leftover matches
  base=$1
  lbuf=$2
  compgen=$3
  fzf_opts=$4
  suffix=$5
  tail=$6

  setopt localoptions nonomatch
  if [[ $base = *'$('* ]] || [[ $base = *'<('* ]] || [[ $base = *'>('* ]] || [[ $base = *':='* ]] || [[ $base = *'`'* ]]; then
    return
  fi
  eval "base=$base" 2> /dev/null || return
  [[ $base = *"/"* ]] && dir="$base"
  while [ 1 ]; do
    if [[ -z "$dir" || -d ${dir} ]]; then
      leftover=${base/#"$dir"}
      leftover=${leftover/#\/}
      [ -z "$dir" ] && dir='.'
      [ "$dir" != "/" ] && dir="${dir/%\//}"
      matches=$(
        export FZF_DEFAULT_OPTS
        FZF_DEFAULT_OPTS=$(__fzf_defaults "--reverse --scheme=path" "${FZF_COMPLETION_OPTS-}")
        unset FZF_DEFAULT_COMMAND FZF_DEFAULT_OPTS_FILE
        if declare -f "$compgen" > /dev/null; then
          eval "$compgen $(printf %q "$dir")" | __fzf_comprun "$cmd_word" ${(Q)${(Z+n+)fzf_opts}} -q "$leftover"
        else
          if [[ $compgen =~ dir ]]; then
            walker=dir,follow
            rest=${FZF_COMPLETION_DIR_OPTS-}
          else
            walker=file,dir,follow,hidden
            rest=${FZF_COMPLETION_PATH_OPTS-}
          fi
          __fzf_comprun "$cmd_word" ${(Q)${(Z+n+)fzf_opts}} -q "$leftover" --walker "$walker" --walker-root="$dir" ${(Q)${(Z+n+)rest}} < /dev/tty
        fi | while read -r item; do
          item="${item%$suffix}$suffix"
          echo -n -E "${(q)item} "
        done
      )
      matches=${matches% }
      if [ -n "$matches" ]; then
        LBUFFER="$lbuf$matches$tail"
      fi
      zle reset-prompt
      break
    fi
    dir=$(dirname "$dir")
    dir=${dir%/}/
  done
}

_fzf_path_completion() {
  __fzf_generic_path_completion "$1" "$2" _fzf_compgen_path \
    "-m" "" " "
}

_fzf_dir_completion() {
  __fzf_generic_path_completion "$1" "$2" _fzf_compgen_dir \
    "" "/" ""
}

_fzf_feed_fifo() {
  command rm -f "$1"
  mkfifo "$1"
  cat <&0 > "$1" &|
}

_fzf_complete() {
  setopt localoptions ksh_arrays
  # Split arguments around --
  local args rest str_arg i sep
  args=("$@")
  sep=
  for i in {0..${#args[@]}}; do
    if [[ "${args[$i]-}" = -- ]]; then
      sep=$i
      break
    fi
  done
  if [[ -n "$sep" ]]; then
    str_arg=
    rest=("${args[@]:$((sep + 1)):${#args[@]}}")
    args=("${args[@]:0:$sep}")
  else
    str_arg=$1
    args=()
    shift
    rest=("$@")
  fi

  local fifo lbuf matches post
  fifo="${TMPDIR:-/tmp}/fzf-complete-fifo-$$"
  lbuf=${rest[0]}
  post="${funcstack[1]}_post"
  type $post > /dev/null 2>&1 || post=cat

  _fzf_feed_fifo "$fifo"
  matches=$(
    FZF_DEFAULT_OPTS=$(__fzf_defaults "--reverse" "${FZF_COMPLETION_OPTS-} $str_arg") \
    FZF_DEFAULT_OPTS_FILE='' \
      __fzf_comprun "$cmd_word" "${args[@]}" -q "${(Q)prefix}" < "$fifo" | $post | tr '\n' ' ')
  if [ -n "$matches" ]; then
    LBUFFER="$lbuf$matches"
  fi
  command rm -f "$fifo"
}

# To use custom hostname lists, override __fzf_list_hosts.
# The function is expected to print hostnames, one per line as well as in the
# desired sorting and with any duplicates removed, to standard output.
if ! declare -f __fzf_list_hosts > /dev/null; then
  __fzf_list_hosts() {
    command sort -u \
      <(
        # Note: To make the pathname expansion of "~/.ssh/config.d/*" work
        # properly, we need to adjust the related shell options.  We need to
        # unset "NO_GLOB" (or reset "GLOB"), which disable the pathname
        # expansion totally.  We need to unset "DOT_GLOB" and set "CASE_GLOB"
        # to avoid matching unwanted files.  We need to set "NULL_GLOB" to
        # avoid attempting to read the literal filename '~/.ssh/config.d/*'
        # when no matching is found.
        setopt GLOB NO_DOT_GLOB CASE_GLOB NO_NOMATCH NULL_GLOB

        __fzf_exec_awk '
          # Note: mawk <= 1.3.3-20090705 does not support the POSIX brackets of
          # the form [[:blank:]], and Ubuntu 18.04 LTS still uses this
          # 16-year-old mawk unfortunately.  We need to use [ \t] instead.
          match(tolower($0), /^[ \t]*host(name)?[ \t]*[ \t=]/) {
            $0 = substr($0, RLENGTH + 1) # Remove "Host(name)?=?"
            sub(/#.*/, "")
            for (i = 1; i <= NF; i++)
              if ($i !~ /[*?%]/)
                print $i
          }
        ' ~/.ssh/config ~/.ssh/config.d/* /etc/ssh/ssh_config 2> /dev/null
      ) \
      <(
        __fzf_exec_awk -F ',' '
          match($0, /^[][a-zA-Z0-9.,:-]+/) {
            $0 = substr($0, 1, RLENGTH)
            gsub(/[][]|:[^,]*/, "")
            for (i = 1; i <= NF; i++)
              print $i
          }
        ' ~/.ssh/known_hosts 2> /dev/null
      ) \
      <(
        __fzf_exec_awk '
          {
            sub(/#.*/, "")
            for (i = 2; i <= NF; i++)
              if ($i != "0.0.0.0")
                print $i
          }
        ' /etc/hosts 2> /dev/null
      )
  }
fi

_fzf_complete_telnet() {
  _fzf_complete +m -- "$@" < <(__fzf_list_hosts)
}

# The first and the only argument is the LBUFFER without the current word that contains the trigger.
# The current word without the trigger is in the $prefix variable passed from the caller.
_fzf_complete_ssh() {
  local -a tokens
  tokens=(${(z)1})
  case ${tokens[-1]} in
    -i|-F|-E)
      _fzf_path_completion "$prefix" "$1"
      ;;
    *)
      local user
      [[ $prefix =~ @ ]] && user="${prefix%%@*}@"
      _fzf_complete +m -- "$@" < <(__fzf_list_hosts | __fzf_exec_awk -v user="$user" '{print user $0}')
      ;;
  esac
}

_fzf_complete_export() {
  _fzf_complete -m -- "$@" < <(
    declare -xp | sed 's/=.*//' | sed 's/.* //'
  )
}

_fzf_complete_unset() {
  _fzf_complete -m -- "$@" < <(
    declare -xp | sed 's/=.*//' | sed 's/.* //'
  )
}

_fzf_complete_unalias() {
  _fzf_complete +m -- "$@" < <(
    alias | sed 's/=.*//'
  )
}

_fzf_complete_kill() {
  local transformer
  transformer='
    if [[ $FZF_KEY =~ ctrl|alt|shift ]] && [[ -n $FZF_NTH ]]; then
      nths=( ${FZF_NTH//,/ } )
      new_nths=()
      found=0
      for nth in ${nths[@]}; do
        if [[ $nth = $FZF_CLICK_HEADER_NTH ]]; then
          found=1
        else
          new_nths+=($nth)
        fi
      done
      [[ $found = 0 ]] && new_nths+=($FZF_CLICK_HEADER_NTH)
      new_nths=${new_nths[*]}
      new_nths=${new_nths// /,}
      echo "change-nth($new_nths)+change-prompt($new_nths> )"
    else
      if [[ $FZF_NTH = $FZF_CLICK_HEADER_NTH ]]; then
        echo "change-nth()+change-prompt(> )"
      else
        echo "change-nth($FZF_CLICK_HEADER_NTH)+change-prompt($FZF_CLICK_HEADER_WORD> )"
      fi
    fi
  '
  _fzf_complete -m --header-lines=1 --no-preview --wrap --color fg:dim,nth:regular \
    --bind "click-header:transform:$transformer" -- "$@" < <(
    command ps -eo user,pid,ppid,start,time,command 2> /dev/null ||
      command ps -eo user,pid,ppid,time,args 2> /dev/null || # For BusyBox
      command ps --everyone --full --windows # For cygwin
  )
}

_fzf_complete_kill_post() {
  __fzf_exec_awk '{print $2}'
}

fzf-completion() {
  local tokens prefix trigger tail matches lbuf d_cmds cursor_pos cmd_word
  setopt localoptions noshwordsplit noksh_arrays noposixbuiltins

  # http://zsh.sourceforge.net/FAQ/zshfaq03.html
  # http://zsh.sourceforge.net/Doc/Release/Expansion.html#Parameter-Expansion-Flags
  tokens=(${(z)LBUFFER})
  if [ ${#tokens} -lt 1 ]; then
    zle ${fzf_default_completion:-expand-or-complete}
    return
  fi

  # Explicitly allow for empty trigger.
  trigger=${FZF_COMPLETION_TRIGGER-'**'}
  [[ -z $trigger && ${LBUFFER[-1]} == ' ' ]] && tokens+=("")

  # When the trigger starts with ';', it becomes a separate token
  if [[ ${LBUFFER} = *"${tokens[-2]-}${tokens[-1]}" ]]; then
    tokens[-2]="${tokens[-2]-}${tokens[-1]}"
    tokens=(${tokens[0,-2]})
  fi

  lbuf=$LBUFFER
  tail=${LBUFFER:$(( ${#LBUFFER} - ${#trigger} ))}

  # Trigger sequence given
  if [ ${#tokens} -gt 1 -a "$tail" = "$trigger" ]; then
    d_cmds=(${=FZF_COMPLETION_DIR_COMMANDS-cd pushd rmdir})

    {
      cursor_pos=$CURSOR
      # Move the cursor before the trigger to preserve word array elements when
      # trigger chars like ';' or '`' would otherwise reset the 'words' array.
      CURSOR=$((cursor_pos - ${#trigger} - 1))
      # Check if at least one completion system (old or new) is active.
      # If at least one user-defined completion widget is detected, nothing will
      # be completed if neither the old nor the new completion system is enabled.
      # In such cases, the 'zsh/compctl' module is loaded as a fallback.
      if ! zmodload -F zsh/parameter p:functions 2>/dev/null || ! (( ${+functions[compdef]} )); then
        zmodload -F zsh/compctl 2>/dev/null
      fi
      # Create a completion widget to access the 'words' array (man zshcompwid)
      zle -C __fzf_extract_command .complete-word __fzf_extract_command
      zle __fzf_extract_command
    } always {
      CURSOR=$cursor_pos
      # Delete the completion widget
      zle -D __fzf_extract_command  2>/dev/null
    }

    [ -z "$trigger"      ] && prefix=${tokens[-1]} || prefix=${tokens[-1]:0:-${#trigger}}
    if [[ $prefix = *'$('* ]] || [[ $prefix = *'<('* ]] || [[ $prefix = *'>('* ]] || [[ $prefix = *':='* ]] || [[ $prefix = *'`'* ]]; then
      return
    fi
    [ -n "${tokens[-1]}" ] && lbuf=${lbuf:0:-${#tokens[-1]}}

    if eval "noglob type _fzf_complete_${cmd_word} >/dev/null"; then
      prefix="$prefix" eval _fzf_complete_${cmd_word} ${(q)lbuf}
      zle reset-prompt
    elif [ ${d_cmds[(i)$cmd_word]} -le ${#d_cmds} ]; then
      _fzf_dir_completion "$prefix" "$lbuf"
    else
      _fzf_path_completion "$prefix" "$lbuf"
    fi
  # Fall back to default completion
  else
    zle ${fzf_default_completion:-expand-or-complete}
  fi
}

[ -z "$fzf_default_completion" ] && {
  binding=$(bindkey '^I')
  [[ $binding =~ 'undefined-key' ]] || fzf_default_completion=$binding[(s: :w)2]
  unset binding
}

# Normal widget
zle     -N   fzf-completion
bindkey '^I' fzf-completion
fi

} always {
  # Restore the original options.
  eval $__fzf_completion_options
  'unset' '__fzf_completion_options'
}
### end: completion.zsh ###

# --- starship init ---
# ZSH has a quirk where `preexec` is only run if a command is actually run (i.e
# pressing ENTER at an empty command line will not cause preexec to fire). This
# can cause timing issues, as a user who presses "ENTER" without running a command
# will see the time to the start of the last command, which may be very large.

# To fix this, we create STARSHIP_START_TIME upon preexec() firing, and destroy it
# after drawing the prompt. This ensures that the timing for one command is only
# ever drawn once (for the prompt immediately after it is run).

zmodload zsh/parameter  # Needed to access jobstates variable for STARSHIP_JOBS_COUNT

# Defines a function `__starship_get_time` that sets the time since epoch in millis in STARSHIP_CAPTURED_TIME.
if [[ $ZSH_VERSION == ([1-4]*) ]]; then
    # ZSH <= 5; Does not have a built-in variable so we will rely on Starship's inbuilt time function.
    __starship_get_time() {
        STARSHIP_CAPTURED_TIME=$('C:\Users\JohnN\scoop\apps\starship\current\starship.exe' time)
    }
else
    zmodload zsh/datetime
    zmodload zsh/mathfunc
    __starship_get_time() {
        (( STARSHIP_CAPTURED_TIME = int(rint(EPOCHREALTIME * 1000)) ))
    }
fi

# The two functions below follow the naming convention `prompt_<theme>_<hook>`
# for compatibility with Zsh's prompt system. See
# https://github.com/zsh-users/zsh/blob/2876c25a28b8052d6683027998cc118fc9b50157/Functions/Prompts/promptinit#L155

# Runs before each new command line.
prompt_starship_precmd() {
    # Save the status, because subsequent commands in this function will change $?
    STARSHIP_CMD_STATUS=$? STARSHIP_PIPE_STATUS=(${pipestatus[@]})

    # Calculate duration if a command was executed
    if (( ${+STARSHIP_START_TIME} )); then
        # If an arithmetic expression evaluates to 0, its exit status is 1:
        # "The return status is 0 if the arithmetic value of the expression is non-zero, 1 if it is zero, and 2 if an error occurred."
        # In rare cases, the subtraction below can result in an int 0 result (yes, really),
        # which would then kill the shell if 'set -e' is in effect.
        # We therefore have to assign the result outside the expression (using 'STARSHIP_DURATION=$((...))'),
        # because unlike '(())', '$(())' gets a return status of 0 even if the expression evaluates to int 0
        # (but it still surfaces a potential error, normally status 2, as status 1).
        __starship_get_time && STARSHIP_DURATION=$(( STARSHIP_CAPTURED_TIME - STARSHIP_START_TIME ))
        unset STARSHIP_START_TIME
    # Drop status and duration otherwise
    else
        unset STARSHIP_DURATION STARSHIP_CMD_STATUS STARSHIP_PIPE_STATUS
    fi

    # Use length of jobstates array as number of jobs. Expansion fails inside
    # quotes so we set it here and then use the value later on.
    STARSHIP_JOBS_COUNT="${#jobstates[*]}"
}

# Runs after the user submits the command line, but before it is executed and
# only if there's an actual command to run
prompt_starship_preexec() {
    __starship_get_time && STARSHIP_START_TIME=$STARSHIP_CAPTURED_TIME
}

# Add hook functions
autoload -Uz add-zsh-hook
add-zsh-hook precmd prompt_starship_precmd
add-zsh-hook preexec prompt_starship_preexec

# Set up a function to redraw the prompt if the user switches vi modes
starship_zle-keymap-select() {
    zle reset-prompt
}

## Check for existing keymap-select widget.
if [[ -v widgets[zle-keymap-select] ]]; then
    # zle-keymap-select is a special widget so it'll be "user:fnName" or nothing. Let's get fnName only.
    __starship_preserved_zle_keymap_select=${widgets[zle-keymap-select]#user:}
fi

if [[ -z ${__starship_preserved_zle_keymap_select:-} ]]; then
    zle -N zle-keymap-select starship_zle-keymap-select;
else
    # Define a wrapper fn to call the original widget fn and then Starship's.
    starship_zle-keymap-select-wrapped() {
        $__starship_preserved_zle_keymap_select "$@";
        starship_zle-keymap-select "$@";
    }
    zle -N zle-keymap-select starship_zle-keymap-select-wrapped;
fi

export STARSHIP_SHELL="zsh"

# Set up the session key that will be used to store logs
STARSHIP_SESSION_KEY="$RANDOM$RANDOM$RANDOM$RANDOM$RANDOM"; # Random generates a number b/w 0 - 32767
STARSHIP_SESSION_KEY="${STARSHIP_SESSION_KEY}0000000000000000" # Pad it to 16+ chars.
export STARSHIP_SESSION_KEY=${STARSHIP_SESSION_KEY:0:16}; # Trim to 16-digits if excess.

VIRTUAL_ENV_DISABLE_PROMPT=1

setopt promptsubst

PROMPT='$(''C:\Users\JohnN\scoop\apps\starship\current\starship.exe'' prompt --terminal-width="$COLUMNS" --keymap="${KEYMAP:-}" --status="${STARSHIP_CMD_STATUS:-}" --pipestatus="${STARSHIP_PIPE_STATUS[*]:-}" --cmd-duration="${STARSHIP_DURATION:-}" --jobs="$STARSHIP_JOBS_COUNT")'
RPROMPT='$(''C:\Users\JohnN\scoop\apps\starship\current\starship.exe'' prompt --right --terminal-width="$COLUMNS" --keymap="${KEYMAP:-}" --status="${STARSHIP_CMD_STATUS:-}" --pipestatus="${STARSHIP_PIPE_STATUS[*]:-}" --cmd-duration="${STARSHIP_DURATION:-}" --jobs="$STARSHIP_JOBS_COUNT")'
PROMPT2="$('C:\Users\JohnN\scoop\apps\starship\current\starship.exe' prompt --continuation)"

