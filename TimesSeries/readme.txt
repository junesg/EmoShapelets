 g++ omp_hello.c -fopenmp
 export OMP_NUM_THREADS=4
 ./a.out



 g++ TimeSeries1.cpp modUCRDTW.cpp Shapelet.cpp myquicksort.cpp -fopenmp -o varyActorSegmentsumIGAUDIO.out
 actorId normalization segLen updateShaeplet



./varyActorSegmentsumIGAUDIO.out  9 0 5  1  & 
./varyActorSegmentsumIGAUDIO.out  9 0 10 1 & 
./varyActorSegmentsumIGAUDIO.out  9 0 15 1 & 
./varyActorSegmentsumIGAUDIO.out  9 0 20 1 & 
./varyActorSegmentsumIGAUDIO.out  9 0 25 1 & 
./varyActorSegmentsumIGAUDIO.out  9 0 30 1 & 
./varyActorSegmentsumIGAUDIO.out  9 0 35 1 & 
./varyActorSegmentsumIGAUDIO.out  9 0 40 1 & 





 varyActorSegment40to5sumIG.out

 g++ TimeSeries1.cpp modUCRDTW.cpp Shapelet2.cpp myquicksort.cpp -fopenmp -o varyActorSegmentmaxIG.out

 varyActorSegment40to5MaxIG.out




g++ TimeSeries.cpp modUCRDTW.cpp Shapelet.cpp myquicksort.cpp ReadShapeletsFromFileMod.cpp -fopenmp  -g -o gatherShapelet.out


actorsId emoId segLen training_bool max(0)/sum(1) noupdate(0)/updated(1)


%% matlab
./gatherShapelet.out 0 1 5 1 0  1  & 
./gatherShapelet.out 0 2 5 1 0  1  &
./gatherShapelet.out 0 3 5 1 0  1  &
./gatherShapelet.out 0 4 5 1 0  1 &



for trainBool =1 
for person = 0:9
for emotoins= 1:4
for segLen = 5:5:25
	system(['./gatherShapelet.out ', num2str(person),' ' , num2str(emotoins),' ',...
	num2str(segLen), ' ', num2str(trainBool),'  0 1  ',' '])
end


end
end
end







valgrind --leak-check=full --track-origins=yes ./varyActorSegment.out 3



./varyActorSegment.out 4

scp juneysg@napoli8.eecs.umich.edu:~/Documents/MyCode/*.* . 

 export OMP_NUM_THREADS=4
 valgrind --leak-check=yes ./a.out


#!/bin/sh
#PBS -S/bin/sh
#PBS -N RunEmotion 
#PBS -A eecs587f13_flux
#PBS -l qos=flux
#PBS -l nodes=1:ppn=12,pmem= 2gb
#PBS -l walltime=00:05:00
#PBS -q flux
#PBS -M juneysg@umich.edu
#PBS -m abe
#PBS -j oe
#PBS -V
#
echo "with Emotion;STRATEGYMUTATE=0.10;MAX_ZERO_CONVERGE=10, iterations =1000, np = 12, I ran on:"
cat $PBS_NODEFILE

# Let PBS handle your output
cd ~/final_project/TSP_Parallel/

mpirun -