#!/bin/bash

PID_FILENAME=/run/user/$UID/gtklock-timeout.pid

screen_lock() {

    if [[ -n "$1" && -n "$2" ]]; then
        path="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)/$(basename "${BASH_SOURCE[0]}")"

        if [[ -n $3 && $3 -eq true ]]; then
            systemd-inhibit --what=idle:sleep \
                --who="GTK Lock" --why="Para impedir a suspensão por inatividade e bloquear a tela" \
                --mode=block \
                gtklock --idle-hide --start-hidden --lock-command "$path display_power_off 1"
        else
            gtklock --idle-hide --start-hidden --lock-command "$path set_timeout $1 $2" --unlock-command "$path unset_timeout"
        fi
    else
        echo "Há argumentos faltando para a execução da função"
    fi
}

set_timeout() {

    echo "$$" >$PID_FILENAME

    # Valida se o arquivo foi criado
    if [[ -e "$PID_FILENAME" && -s "$PID_FILENAME" ]]; then
        display_power_off $1

        # Valida se o PID existe e foi salvo
        if [ "$(cat $PID_FILENAME)" -eq "$$" ]; then
            sleep $2 && systemctl suspend
        fi

    else
        echo "Erro: O arquivo contendo o PID do processo não pode ser criado."
    fi
}

unset_timeout() {
    PID="$(cat $PID_FILENAME)"

    # Valida se o PID ainda está ativo
    if ps -p $PID >/dev/null; then
        kill $PID && rm $PID_FILENAME
        echo "Timeout encerrado"
    fi
}

display_power_off() {
    sleep $1 && swaymsg output "*" power off

}

"$@"
