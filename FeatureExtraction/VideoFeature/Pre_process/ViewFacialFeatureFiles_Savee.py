__author__ = 'Juneysg'

import matplotlib.pyplot as plt
from matplotlib.pyplot import figure, show

def main(fileName = 'DCmarker.points'):
    plotPoints = True
    # read numbers from file
    f = open(fileName,'r')
    all_line = f.read()
    components = all_line.split('\n')
    f.close()
    # append the number into the vector
    vector = []
    for number in components:
        if len(number) > 0:
            vector.append(float(number))
    # check output
    assert(len(vector)  %2 == 0)
    x = vector[0:len(vector)/2]
    y = vector[len(vector)/2:len(vector)]

    pairs =[[58.0, 29.0], [59.0, 29.0], [19.0, 45.0], [5.0, 36.0], [48.0, 31.0], [44.0, 51.0], [51.0, 51.0], [45.0, 23.0], [46.0, 58.0], [23.0, 44.0], [24.0, 44.0], [39.0, 31.0], [35.0, 42.0], [42.0, 55.0], [36.0, 28.0], [37.0, 59.0], [28.0, 35.0], [27.0, 35.0], [52.0, 57.0], [32.0, 33.0], [54.0, 56.0], [51.0, 55.0], [51.0, 31.0], [55.0, 31.0], [47.0, 31.0], [38.0, 31.0], [1.0, 21.0], [21.0, 3.0], [3.0, 1.0], [29.0, 21.0], [46.0, 30.0], [37.0, 30.0], [31.0, 32.0], [31.0, 33.0], [12.0, 33.0], [31.0, 49.0], [31.0, 55.0], [31.0, 50.0], [31.0, 40.0], [24.0, 44.0], [27.0, 35.0], [20.0, 21.0], [22.0, 21.0], [19.0, 24.0], [5.0, 27.0], [30.0, 45.0], [30.0, 36.0]]


    #show points and the plot
    if plotPoints:
        fig = figure(1,figsize=(10,10))
        for ii in range(0,len(vector)/2):
            plt.plot(x,y,'*')
            ax = fig.add_subplot(111, autoscale_on=False, xlim=(-0.6,0.6), ylim=(-1,1))
            ax.annotate(str(ii), xy=(x[ii], y[ii]),  xycoords='data',
                        xytext=(-15, -15), textcoords='offset points',
                        arrowprops=dict(arrowstyle="->",
                                        connectionstyle="arc3,rad=.2")
                        )
            for jj in range(0, len(pairs)):
                index1 = int(pairs[jj][0])
                index2 = int(pairs[jj][1])
                plt.plot([x[index1], x[index2]], [y[index1],y[index2]],'r')
        plt.show()


if __name__ == "__main__":
    names = ['JK','KL','JE','DC']
    for nn in names:
        main('analysis/'+nn+'marker.points')