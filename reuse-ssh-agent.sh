env=~/.ssh/agent.env

agent_load_env_macos() {
    # At boot, macOS has a weird ssh-agent setup. (tested on 10.13.6)
    # declare -x SSH_AUTH_SOCK="/private/tmp/com.apple.launchd.dilePM7NSe/Listeners"

    # Running eval $(ssh-agent) in Terminal leads to a different environment.
    # declare -x SSH_AUTH_SOCK="/var/folders/lb/n7x34vjd64zfrnzwlhpxmtj00000gp/T//ssh-8uTDnDahLuLU/agent.4385"
    # declare -x TMPDIR="/var/folders/lb/n7x34vjd64zfrnzwlhpxmtj00000gp/T/"

    if [[ "$sys" == "Darwin" ]]; then
        echo "$SSH_AUTH_SOCK"
        echo "$TMPDIR"

        if [[ "$SSH_AUTH_SOCK" =~ "$TMPDIR" ]]; then
            echo "ssh-agent is good to go."
        else
            echo "ssh-agent won't work well with VS Code like this, terminate and unset."
            pkill ssh-agent
            unset SSH_AUTH_SOCK
        fi
    fi
}

agent_load_env () {
    agent_load_env_macos

    test -f "$env" && . "$env" >| /dev/null
}

agent_start () {
    (umask 077; ssh-agent >| "$env")
    . "$env" >| /dev/null
}

# Maxs-Air:~ nuket$ id
# uid=502(nuket) gid=20(staff) groups=20(staff),12(everyone),61(localaccounts),399(com.apple.access_ssh),701(1),702(2),100(_lpoperator)
# Maxs-Air:~ nuket$ launchctl disable user/502/com.openssh.ssh-agent

set_environment_vars() {
    if [[ "$sys" == "Darwin" ]]; then
        echo "Setting macOS SSH user environment variables   (sock: $SSH_AUTH_SOCK)"
        
        launchctl setenv SSH_AGENT_PID "$SSH_AGENT_PID"
        launchctl setenv SSH_AUTH_SOCK "$SSH_AUTH_SOCK"

        # echo "Must restart Terminal to get these environment variables to stick for all new windows"
        # exit 1
    elif [[ "$sys" == "Windows" ]]; then
        echo "Setting Windows SSH user environment variables (sock: $SSH_AUTH_SOCK)"
        
        setx SSH_AGENT_PID "$SSH_AGENT_PID"
        setx SSH_AUTH_SOCK "$SSH_AUTH_SOCK"
    elif [[ "$sys" == "Linux" ]]; then
        echo "Linux environment variables are already set-up (sock: $SSH_AUTH_SOCK)"
    else
        echo "Please add support for this system."
        return 1
    fi
}

main_() {
    sys=$(uname -s)

    agent_load_env

    # agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2= agent not running
    agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)

    if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
        echo "Starting ssh-agent and adding key"
        agent_start
        set_environment_vars
        ssh-add
    elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
        echo "Reusing ssh-agent and adding key"
        ssh-add
    elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 0 ]; then
        echo "Reusing ssh-agent and reusing key"
        ssh-add -l
    fi

    unset env
}

main_