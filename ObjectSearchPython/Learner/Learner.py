'''
Created on May 14, 2013

@author: okankoc
@contact: Stefan Koenig
'''

import numpy as np
import scipy

class Learner(object):
    '''
    Base class for all learners
    Defines a few commonalities between the learner classes.
    '''
    
    minSamples = 20

    def __init__(self,evidenceGenerator):
        '''
        OBJ=LEARNER(EVIDENCEGENERATOR)
        The standard constructor for all learner classes. An evidence
        generator is always necessary and is assigned during construction.
        '''
        self.evidenceGenerator = evidenceGenerator
        
class LocationLearner(Learner):
    '''
    Base class for location learning
    Extends the basic Learner.Learner interface. Especially adds two
    methods: getProbabilityFromEvidence, removeParents.
    '''
    

class ContinuousGMMLearner(LocationLearner):
    '''
    Models relative location as a mixture of Gaussian
    This method a used to learn a mixture of Gaussians model of the
    distribution of relative locations between object pairs.
    
    Samples are NOT slices as opposed to MATLAB code.
    TODO: consider updating models incrementally.
    '''
    
    maxComponents = 5
    splitSize = 3
    
    def learn(self, dataStr):
        '''
        Learns the GMM probabilities.
        '''
        
        #Get the relative location samples (dictionary)
        samples = self.evidenceGenerator.getEvidence(dataStr)
        classes = dataStr.getClassNames()
        
        for key,val in samples.iteritems():
            # compute the gmm
            if len(val) is not 0:
                self.doGMM(val)
                # save it
                
    def doGMM(self, samples):
        '''
        Learns the GMM probabilities for the particular class pair i,j
        with samples containing distance information as a list of 2-d vectors
        
        Learning is done with an iterative EM algorithm.
        Number of components is determined with the BIC-score.
        Restricting the number of components to MAXCOMPONENTS.
        '''
        
        # Split the dataset into 3 parts, 
        # use 2 parts for training and 1 for testing        
        randomInd = np.random.permutation(range(len(samples)))
        set_randomInd = set(randomInd.tolist())
        split = np.ceil(len(randomInd)/self.splitSize)
        
        # Generate possible combinations for CROSSVALIDATION
        
        # for array indexing convert samples list into numpy array
        npsamp = np.array(samples)
        # test and train are lists containing corresponding data
        # for crossvalidation
        test = list()
        train = list()
        
        # TODO: check to see if working
        for i in range(self.splitSize):
            ind_i = randomInd[(i * split):((i+1) * split)]
            test[i] = npsamp[ind_i]
            # get the difference of indices
            set_ind_i_diff = set_randomInd.difference(set(ind_i.tolist()))
            ind_i_diff = np.array(list(set_ind_i_diff))
            train[i] = npsamp[ind_i_diff]
        
        score = np.zeros(self.maxComponents)
        # For every possible number of components calculate the score
        for k in range(self.maxComponents):
            # add the scores for all dataset splits
            for s in range(self.splitSize):
                score[k] = score[k] + self.evaluateModelComplexity(train[s], test[s], k+1)
    
    def evaluateModelComplexity(self, trainSet, testSet, k):
        '''
        Evaluate the Bayesian Information Criterion (BIC) score 
        of the GMM where the BIC is defined as:
        
        BIC = NlogN + m * log(n)
        
        NlogN: negative-log-likelihood of the data
        m: estimated number of parameters
        n: number of data points    
        '''
        