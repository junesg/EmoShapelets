__author__ = 'Juneysg'

from os import listdir
import os
import matplotlib.pyplot as plt


data_dir = '/Users/Juneysg/Documents/fall2015/Research/data/semaine-database_download_2015-10-09_17_20_59/Sessions/10/'
rater = 'R6'
session = 'S2'
target = 'TU'
character = 'CPr'
all_dimensions = []
all_data = []
file_name_partial = rater+session+target+character



all_files = listdir(data_dir)
for ff in all_files:
    if ff[0:len(file_name_partial)] == file_name_partial:
        Degree = ff[len(file_name_partial):-4]
        all_dimensions.append(Degree)
        data  = []
        time = []
        f = open(data_dir+ff,'r')
        for ll in f:
            l2 = ll.split()
            time.append(float(l2[0]))
            data.append(float(l2[1]))
        all_data.append([time,data])
        f.close()

colors = ['r','b','g','k','m','c']
all_labels = []
for int_d in range(0,len(all_dimensions)):
    if all_dimensions[int_d] in  ['DAn','DHp','DSd','DI', 'DV','DA']:
        label,=plt.plot(all_data[int_d][0],all_data[int_d][1], colors[int_d%(len(colors))], label=all_dimensions[int_d])
        all_labels.append(label)


plt.legend(handles=all_labels)
plt.show()