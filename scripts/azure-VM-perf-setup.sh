#!/bin/bash

IFS=$'\n' read -d '' -r -a names < ./hostnames.txt
for i in ${names[@]}; do 
	echo $i
	ssh $i "sudo tuned-adm profile hpc-compute"
	ssh $i "sudo rmmod xpmem"

# mount anf if necessary
#	ssh $i "sudo mkdir /anf && sudo mount 10.0.2.4:/tanf /anf && sudo chmod 1777 /anf"
#	ssh $i "sudo mount 10.0.2.4:/tanf /anf && sudo chmod 1777 /anf"
done

