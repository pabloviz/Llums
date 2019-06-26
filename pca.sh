#!/bin/bash

#if [ "$#" -ne 2 ]; then
#    echo "You must enter exactly 2 command line arguments"
#fi

# echo $#

N=$1;
orig_prog=$2;
opt_prog=$3;
param=$4;

orig_elap=0.0;
orig_cpu=0.0;

$PWD/$orig_prog $param > golden_out.out;
$PWD/$opt_prog  $param > opt_out.out;
if ! diff golden_out.out opt_out.out ; then
	>&2 echo "Different output"
	rm golden_out.out opt_out.out -f
	exit 1;
fi


function performance_eval {
	for i in `seq 1 ${N}`;
	do
		/usr/bin/time --format="%e %P" --append --output=tmp $PWD/$1  $2 > /dev/null; 

		cut -d % -f 1 < tmp > time_optimized.out

	done
# echo $0 $1 ${N};

	first=true;
	avg_elap=0;
	avg_cpu=0;
	while read line;
	do
		curr_elap=$(echo $line | awk '{ print $1}');
		curr_cpu=$(echo $line | awk '{print $2}');
	if $first ; then
		max_elap=$curr_elap;
	min_elap=$curr_elap;

	max_cpu=$curr_cpu;
	min_cpu=$curr_cpu;

	first=false;
	else
		if (( $(echo "$max_elap < $curr_elap" | bc -l) )); then max_elap=$curr_elap; fi;
	if (( $(echo "$min_elap > $curr_elap" | bc -l) )); then min_elap=$curr_elap; fi;
	if (( $(echo "$max_cpu < $curr_cpu" | bc -l) )); then max_cpu=$curr_cpu; fi;
	if (( $(echo "$min_cpu > $curr_cpu" | bc -l) )); then min_cpu=$curr_cpu; fi;
	fi;

	avg_elap=$(echo "$avg_elap + $curr_elap" | bc -l);
	avg_cpu=$(echo "$avg_cpu + $curr_cpu" | bc -l);

	done < time_optimized.out;
	avg_elap=$(echo "(${avg_elap} - ${max_elap} - ${min_elap})/(${N} - 2)" | bc -l | awk '{printf("%.4f\n", $1)}');
	avg_cpu=$(echo "(($avg_cpu - $max_cpu - $min_cpu)/(${N} - 2))* $avg_elap /100" | bc -l | awk '{printf("%.4f\n", $1)}');

	min_cpu=$(echo "($min_cpu * $min_elap) /100" | bc -l | awk '{printf("%.4f\n", $1)}');
	max_cpu=$(echo "($max_cpu * $max_elap) /100" | bc -l | awk '{printf("%.4f\n", $1)}');
	echo "avg elapsed: $avg_elap ; max elap: $max_elap ; min elap: $min_elap";
	echo "avg cpu:     $avg_cpu  ; max cpu:  $max_cpu  ; min cpu:  $min_cpu";
	
	if (( $(echo "$orig_elap == 0" | bc -l) )); then
		orig_elap=$avg_elap;
		orig_cpu=$avg_cpu;
	else
		echo -e "\nSpeedup";
		selap=$(echo "($orig_elap/$avg_elap)" | bc -l | awk '{printf("%.4f\n", $1)}');
		scpu=$(echo "($orig_cpu/$avg_cpu)" | bc -l | awk '{printf("%.4f\n", $1)}');
		echo "elap: $selap   ; cpu: $scpu";
	fi
	
	rm -f opt_out.out tmp time_optimized.out;
}

echo "Performace original program";
performance_eval $orig_prog $param ;

echo -e "\nPerformance optimized program";
performance_eval $opt_prog $param;


rm golden_out.out -f
