
import numpy as np
from numpy import matlib
import scipy.stats
import csv

# normalize the features first --> based on speaker
def feature_normalization_speaker(act_id , features):
    """
    Z-normalize the features based on speaker_id
    :param act_id:  1-4
    :param features:  (number of samples, number of features)
    :return: normalized features :same size as features
    """
    assert(len(act_id)==len(features))
    normalized_features = []
    nf_np =np.asanyarray(normalized_features,dtype=float)
    for speaker in range(1,5):
        x = []
        inds = find_indices_in_list(act_id,speaker)
        for id in inds:
            x.append(features[id])
        #done gather the speaker's features, now noramlize
        x_np = np.asarray(x,dtype=float)
        # z-normalize
        z_scores_np = np.divide( np.subtract(x_np,\
                                np.matlib.repmat(x_np.mean(axis=0),len(x_np),1)),\
                                 np.matlib.repmat(x_np.std(axis=0),len(x_np),1))
        if len(nf_np) > 0:
            nf_np =  np.append(nf_np, z_scores_np , axis=0)
        else:
            nf_np = z_scores_np
    return nf_np


def find_indices_in_list (a_list, a_value):
    """
    helper function, finds the indices of a value in a list
    :param a_list: list of values
    :param a_value:  a single value
    :return: all indices of the value in the list
    """
    inds = []
    for al_it in range(0,len(a_list)):
        if a_list[al_it]!= '':
            if int(a_list[al_it]) == a_value:
                inds.append(al_it)
    return inds


def statistics_of_features(feat_mat):
    """
    Take statistics of the features (in various window sizes)
    :param feat_mat:  (number of samples,  features)
    :return: statistics of features
    """
    f_np = np.asarray(feat_mat, dtype=float)
    final_feat = np.mean(f_np, axis=0) #mean
    final_feat = np.append(final_feat, np.std(f_np, axis=0)) #standard deviation
    final_feat = np.append(final_feat, np.amax(f_np, axis=0)- np.amin(f_np,axis=0)) #range
    final_feat = np.append(final_feat, np.amax(f_np, axis=0)) #max
    final_feat = np.append(final_feat, np.percentile(f_np, 25, axis=0))
    final_feat = np.append(final_feat, np.percentile(f_np, 50, axis=0))
    final_feat = np.append(final_feat, np.percentile(f_np, 75, axis=0))
    final_feat = np.append(final_feat, np.median(f_np, axis=0))
    final_feat = np.append(final_feat, scipy.stats.skew(f_np,axis=0))
    final_feat = np.append(final_feat, scipy.stats.kurtosis(f_np,axis=0))
    return final_feat


def generate_new_title(comp):
    """
    :param original_noprefix:  original title without emotion, utterance, actor id or frame id
    :return: new title with statistics
    """
    new_title = 'Emotion, Utt_id, actor_id, window_id'
    stats = ['mean', 'std', 'range', 'maximum', '25perc',
             '50perc','75perc', 'median', 'skew', 'kurtosis' ]
    added = 0
    for ss in stats:
        for cc in comp:
            new_title = new_title +  ',' + ss + '_' + cc
            added = added+1
    assert(added == len(comp)*len(stats))
    return new_title


# store statistics into new file
def read_data_from_csvfile(file_name = 'FacialExpressionRawFeatures.csv'):
    feature_data = []
    emotion_data = np.asarray([],dtype = int)
    Utt_id  = []
    actor_id = np.asarray([],dtype = int)
    frame_id = np.asarray([],dtype = int)
    with open(file_name, 'rb') as csvfile:
        data_reader = csv.reader(csvfile, delimiter=',')
        for row in data_reader:
            if row[0]!= 'Emotion':
                feature_data.append(row[4:])
                emotion_data = np.append(emotion_data,row[0])
                Utt_id.append(row[1])
                actor_id = np.append(actor_id,row[2])
                frame_id = np.append(frame_id,row[3])
            else :
                feat_title = row[4:]
    return feat_title, emotion_data, Utt_id, actor_id, frame_id,feature_data


def get_chunk_from_utterances(emotion_data, Utt_id, 
                                actor_id ,frame_id,
                                normalized_feature,
                                win,step_size):
    # single out one utterance
    next_utt = Utt_id[0]
    collect_data = []
    item_it = 0
    fps = 60 # this is the frame reate per second
    if win == np.inf:
        chunk_len = np.inf
    else:
        chunk_len = int(np.ceil(fps*win))
    step_size2 = int(np.ceil(fps*step_size))
    final_feat = []
    final_emo = []
    final_utt = []
    final_act = []
    final_wind = []
    while(item_it < len(normalized_feature)):
        print(item_it)
        collect_data = []
        original_utt = next_utt
        print(next_utt)
        while original_utt == next_utt:
            collect_data.append(normalized_feature[item_it])
            original_utt = next_utt
            item_it = item_it + 1
            if item_it >= len(normalized_feature):
                break
            else:
                next_utt = Utt_id[item_it]
        temp_emo = emotion_data[item_it-1]
        temp_utt = Utt_id[item_it -1 ]
        temp_act = actor_id[item_it-1]
        temp_wind = []
        if len(collect_data) <= chunk_len and len(collect_data) > 2:
             #first case, length of utterance shorter than chunk
            chunk_data =  statistics_of_features(collect_data)
            temp_wind = [1]
        elif len(collect_data) > chunk_len : # if we have more, then we start
            chunk_data = []
            wind_id = 1
            for chunk_id in drange(1,len(collect_data)-chunk_len+2, step_size2):
                start_point = chunk_id -1
                end_point = start_point + chunk_len - 1
                temp_wind.append(wind_id)
                wind_id = wind_id + 1
                if chunk_id == 1:
                    temp_data= statistics_of_features(collect_data[start_point:end_point])
                    chunk_data = temp_data.reshape((1,len(temp_data)))
                else:
                    temp_data= statistics_of_features(collect_data[start_point:end_point])
                    chunk_data = np.append(chunk_data, temp_data.reshape((1,len(temp_data))), axis= 0)
        else:
            print('too short '+ str(item_it))
        if len(final_feat) == 0:
            if win != np.inf:
                # final_feat = chunk_data.reshape((1,len(chunk_data)))
                final_feat = chunk_data
                final_emo = np.matlib.repmat(temp_emo,len(chunk_data),1)
                final_utt = np.matlib.repmat(temp_utt, len(chunk_data),1)
                final_act = np.matlib.repmat(temp_act, len(chunk_data), 1)
                final_wind = np.asarray(temp_wind)
                print(final_emo)
            else:
                final_feat = chunk_data.reshape((1,len(chunk_data)))
                final_emo = np.asarray([temp_emo])
                final_utt = np.asarray([temp_utt])
                final_act = np.asarray([temp_act])
                final_wind = np.asarray(temp_wind)
        else:
            if win == np.inf:
                final_feat = np.append(final_feat,[chunk_data],axis=0)
                final_emo = np.append(final_emo, [temp_emo], axis=0 )
                final_utt = np.append(final_utt, [temp_utt], axis=0)
                final_act = np.append(final_act,  [temp_act], axis=0)
                final_wind = np.append(final_wind, temp_wind, axis=0)
            else:
                final_feat = np.append(final_feat,chunk_data,axis=0)
                final_emo = np.append(final_emo, np.matlib.repmat(temp_emo,len(chunk_data),1), axis=0 )
                final_utt = np.append(final_utt, np.matlib.repmat(temp_utt, len(chunk_data),1), axis=0)
                final_act = np.append(final_act,  np.matlib.repmat(temp_act, len(chunk_data),1), axis=0)
                final_wind = np.append(final_wind, temp_wind, axis=0)
    return final_feat, final_emo, final_utt, final_act, final_wind



# use drange to have a step sizes
def drange(start, stop, step):
     r = start
     while r < stop:
        yield r
        r += step



def main(feature_stat_file = 'FacialExpression_stats_win'):
    print('getting raw feature data from the csv file')
    feat_title, emotion_data, Utt_id, actor_id, frame_id,feature_data = read_data_from_csvfile()
    print('getting new title for the stats data')
    new_title = generate_new_title(feat_title)
    print('getting the speaker-based z-normalized data')
    normalized_feature = feature_normalization_speaker(actor_id , feature_data)
    # now need to loop through each window size
    print('for each window size')
    # now define the step size 
    step_size = 0.1;
    # for window sizes, create feature files 
    for win in [0.5]:#[0.125, 0.25, 0.5, 1.0, np.inf]:
        final_feat, final_emo, final_utt, final_act, final_wind = \
            get_chunk_from_utterances(emotion_data, Utt_id, actor_id, frame_id, normalized_feature, win, step_size)
        assert(len(final_feat)== len(final_emo))
        assert(len(final_feat)== len(final_utt))
        assert(len(final_feat)== len(final_act))
        print('ready to print')
        f = open(feature_stat_file+str(win)+'_overlap'+str(step_size)+'s.csv','w')
        f.write(new_title+"\n")
        for f_it in range(0,len(final_feat)):
            if win == np.inf:
                w_string = str(int(final_emo[f_it][0])) + ',' + \
                final_utt[f_it] + ',' + \
                str(int(final_act[f_it][0])) + ',' + \
                str(final_wind[f_it])
            else:
                w_string = str(int(final_emo[f_it][0])) + ',' + \
                    final_utt[f_it][0] + ',' + \
                    str(int(final_act[f_it][0])) + ',' + \
                    str(final_wind[f_it])
            for ff_it in final_feat[f_it]:
                w_string = w_string + ',' + str(ff_it)
            f.write(w_string + '\n')
        f.close()


if __name__ == "__main__":
    main()