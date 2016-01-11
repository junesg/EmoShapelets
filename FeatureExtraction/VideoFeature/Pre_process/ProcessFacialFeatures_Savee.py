__author__ = 'Juneysg'

import os
import numpy as np

####
# this file will take the directory (eg. DC) of the speaker, and output the AU of each frame.
# AU is defined by the distance of the facial points
####



# read from points file
def read_file(file_name):
    """
    :param file_name: string of input file
    :return: x and y vectors of the point positions
    """
    f = open(file_name,'r')
    all_line = f.read()
    components = all_line.split('\n')
    f.close()
    vector = []
    for number in components:
        if len(number) > 0:
            vector.append(float(number))
    # check output
    assert(len(vector)  %2 == 0)
    x = vector[0:len(vector)/2]
    y = vector[len(vector)/2:len(vector)]
    return x,y


# get feature pairs from the previously determined IEMOCAP feature pairs
# a contains first point, which has one-to-one match to b which is the next point
def get_feature_pairs(match_dir='Facial_IEMOCAP_matchPoints.txt'):
    """
    :param match_dir: string (where facial match point file is for IEMOCAP)
    :return: a,b, which are labels associated with the points
    """
    f = open(match_dir,'r')
    all_line = f.read()
    f.close()
    all_line_comp = all_line.split('\n')
    a = []
    b = []
    for ll in all_line_comp:
        if len(ll) > 0:
            components = ll.split(' ')
            if len(components) > 1:
                a.append(components[0])
                b.append(components[1])
    return a,b


# get the label-index match between IEMOCAP and Savee
def get_label_index_match(match_dir = 'IEMOCAP-SAVEE_POINTS.txt'):
    f = open(match_dir,'r')
    all_line = f.read()
    f.close()
    all_line_comp = all_line.split('\n')
    a = []
    b = []
    for ll in all_line_comp:
        if len(ll) > 0:
            components = ll.split(' ')
            if len(components) > 1:
                a.append(components[0])
                b.append(float(components[1]))
    return a,b

# based on the label-index pairs,
# given the a_label and b_label of the distances
def convert_feature_pairs(label, index, a_labels, b_labels):
    """
    :param label:  list of string (labels in IEMOCAP)
    :param index:  list of index in Savee point system
    :param a_labels:  list of matched labels (start point) used for AU extraction in IEMOCAP
    :param b_labels: list of matched labels (end point) used for AU extraction in IEMOCAP
    :return: pairs of indices of points in the Savee point system
    """
    assert(len(label) == len(index))
    assert(len(a_labels) == len(b_labels))
    pairs = []
    for ii in range(0, len(a_labels)):
        kk = find_in_list(label, a_labels[ii])
        assert(kk < len(label)) # it should be found
        jj = find_in_list(label, b_labels[ii])
        assert(jj < len(label))
        pairs.append([index[kk],index[jj]])
    return pairs


# find the index of a label in a label_list
# if the label is not found, return len(label_list)+1
def find_in_list(label_list, a_label):
    """
    :param label_list:  a list of labels (strings)
    :param a_label:     a single label
    :return:            index of the label if it exists
    """
    for ii in range(0, len(label_list)):
        if label_list[ii] == a_label:
            return ii
    return len(label_list)+1


def dist_between_points(pair1, pair2):
    """
    :param pair1: x1,y1
    :param pair2: x2,y2
    :return: distance between x1,y1 and x2,y2
    """
    return np.sqrt((pair1[0]-pair2[0])**2 + (pair1[1]-pair2[1])**2)


def mysplit(s):
    head = s.rstrip('0123456789')
    tail = s[len(head):]
    return head, tail

# counts the number of files, and the length of the files
def main(speaker):
    emotions = ['h','a','sa','n','d','f','su']
    speakers = ['DC','JE','JK','KL']
    folder_dir = '/Users/Juneysg/Documents/fall2015/Research/Data/Savee/VisualMarkerData/'
    folder_dir = folder_dir+speaker+'/NormalizedMarker/'

    # get the name (in IEMOCAP) and index (in Savee) match
    label,index = get_label_index_match()
    # get the label pairs of features
    a,b = get_feature_pairs()
    # converts features into indices
    pairs = convert_feature_pairs(label, index, a, b)
    # create header
    title = 'Emotion, Utt_id, actor_id, frame_id'
    for ii in range(0, len(a)):
        addition = ','+a[ii]+'-'+b[ii]
        title = title+addition
    title = title + '\n'
    f = open('FacialExpressionRawFeatures.csv','a+')
    # write header
    f.write(title)
    f.close()

    # now go through the files and write each one
    # now loop through each file, extract
    # 1. emotion 2. utterance Id  3. actor Id
    # 4. frame Id  5-others. features
    files = os.listdir(folder_dir)
    for ff in files:
        if ff.find('.') == -1:
            subfolder_dir = folder_dir+ff+'/'
            text_files = os.listdir(subfolder_dir)
            component = mysplit(ff.lower())
            emotion  = find_in_list(emotions, component[0])
            uttId = ff
            speaker_id = find_in_list(speakers, speaker)
            assert(emotion < len(emotions))
            assert(speaker_id < len(speakers))

            count = 1
            for tf in text_files:
                if tf.find('points') != -1:
                    file_name = subfolder_dir + tf
                    # just one frame data
                    x,y = read_file(file_name)
                    print_string = str(emotion+1) + ',' + uttId + ','+ str(speaker_id+1)+','+str(count)
                    count = count+1
                    for pp in pairs:
                        print_string = print_string + ',' +\
                                       str(dist_between_points(  [x[int(pp[0])], y[int(pp[0])]], \
                                                                 [x[int(pp[1])], y[int(pp[1])]]))
                    print_string = print_string + '\n'
                    # now write to file
                    f = open('FacialExpressionRawFeatures.csv','a')
                    f.write(print_string)
                    f.close()



if __name__ == "__main__":
    names = ['DC','JE','JK','KL']
    for nn in names:
        main(nn)