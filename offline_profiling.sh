#!/bin/bash
                                                                                                                                         
# this script performs offline profiling
NUM_ITERS=10
                                                                                                                                         
redis-cli flushall                                                                                                                       
pythia enable-all  

for resource in "ip" "vm" # "volume"
do
    /local/tracing-pythia/workloads/create_delete_${resource}.sh ~/offline_traces.txt $NUM_ITERS
                                                                                                                                         
    pids=()
    for i in `seq $NUM_ITERS`
    do
            /local/tracing-pythia/workloads/create_delete_${resource}.sh ~/offline_traces.txt 1 &
            pids+=($!)
    done
                                                                                                                                         
    for pid in ${pids[@]}
    do
        wait $pid
    done
done
                                                                                                                                         
sleep 300
                                                                                                                                         
while read -r line

do
    pythia get-trace $line > ~/$line.dot
done < ~/offline_traces.txt
