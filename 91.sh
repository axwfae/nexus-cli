#!/bin/bash

export SUB_PROCESS_NUM=14

task_run=91
node_id=28066119

delay_time=10

check_list=(
"Step 2 of 4"
"Step 4 of 4")

check_max=${#check_list[@]} 

while true ; do
    kill_task="nexus-network$task_run"
    node_task="./nexus-network$task_run"
    node_log="/tmp/nodeoutput$task_run.log"

    pkill $kill_task
    sleep 2
    echo  reloadk $node_id $node_task
    #$node_task start --max-threads 1 --headless --node-id $node_id | tee $node_log &
    $node_task start --max-threads 1 --max-difficulty EXTRA_LARGE_2 --headless --node-id $node_id | tee $node_log &
     
    for((gap_time=$delay_time; gap_time > 0; gap_time--)); do
        echo "reset come down $gap_time min"
        sleep 60

        if cat $node_log | grep -q "Failed to submit proof"; then
            break
        fi    

        for((check_cnt=0; check_cnt < $check_max; check_cnt++)); do
            if cat $node_log | grep -q "${check_list[check_cnt]}"; then
                gap_time=$delay_time
                ((gap_time+=30))
                break
            fi
        done 

        if pgrep $kill_task > $node_log ; then
            echo " "
        else
            break
        fi           
    done 
done




