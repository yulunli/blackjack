#!/usr/bin/env bash

declare -a dealer
dealer_idx=0
declare -a guest
guest_idx=0
declare -a deck

function get_card() {
    local card=$[RANDOM % 13 + 1]
    let deck[$card]++
    echo $card
}

function sum_arr() {
    local tot=0
    declare -a arr=("${!1}")
    for i in ${arr[@]}; do
        let tot+=$i
    done
    echo "$tot"
}

function reset_game() {
    unset guest[@]
    unset dealer[@]
    unset deck[@]
    dealer_idx=0
    guest_idx=0
    echo xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
}

function score_hand() {
    declare -a arr=("${!1}")
    local total=0
    for i in ${arr[@]}; do
        if [ $i -gt 10 ]; then
            let total+=10
        elif [ $i -gt 1 ]; then
            let total+=$i
        fi
    done
    for i in ${arr[@]}; do
        if [ $i -eq 1 ]; then
            if [ $total -lt 11 ]; then
                let total+=11
            else
                let total+=1
            fi
        fi
    done
    echo $total
}

function print_hand() {
    declare -a arr=("${!1}")
    local j=0
    for i in ${arr[@]}; do
        if [ $i -eq 1 ]; then
            hand[$j]="A"
        elif [ $i -eq 11 ]; then
            hand[$j]="J"
        elif [ $i -eq 12 ]; then
            hand[$j]="Q"
        elif [ $i -eq 13 ]; then
            hand[$j]="K"
        else
            hand[$j]="$i"
        fi
        ((j++))
    done
    echo ${hand[*]}
}

function handle_dealer() {
    local dealer_sum=$(score_hand dealer[@])
    local guest_sum=$(score_hand guest[@])
    if [ $dealer_sum -gt $guest_sum ]; then
        echo "Dealer: $(print_hand dealer[@])"
        if [ $dealer_sum -eq 21 ]; then
            echo "Dealer BlackJack"
        else
            echo "Dealer Wins!"
        fi
    elif [ $dealer_sum -eq $guest_sum ]; then
        echo "Dealer: $(print_hand dealer[@])"
        echo "Push!"
    else
        echo "Dealer: $(print_hand dealer[@])"
        echo "Guest wins!"
    fi
    reset_game
}

while [ 1 -eq 1 ]; do
    if [ $dealer_idx -eq 0 ]; then
        dealer[0]=$(get_card)
        dealer[1]=$(get_card)
        dealer_idx=2
        guest[0]=$(get_card)
        guest[1]=$(get_card)
        guest_idx=2
    fi
    temp=$(print_hand guest[@])
    echo "Guest: $(print_hand guest[@])"
    guest_sum=$(score_hand guest[@])
    if [ $guest_sum -eq 21 ]; then
        echo "Guest BlackJack!"
        reset_game
    elif [ $guest_sum -gt 21 ]; then
        echo "Guest Bust"
        reset_game
    else
        read -n 1 -p "Hit(h) or Stand(s)? " action
        printf "\n"
        if [ "$action" == "h" ]; then
            guest[$guest_idx]=$(get_card)
            guest_idx+=1
        elif [ "$action" == "s" ]; then
            handle_dealer
        elif [ "$action" == "q" ]; then
            exit
        else
            echo Invalid command
        fi
    fi
done

#TODO: dealer draws cards if current score too low
#TODO: Shuffle cards
#TODO: score over many games
