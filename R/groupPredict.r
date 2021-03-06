groupPredict <- function(train, test, groups, K=20, alpha=0.5, t=20, method=1, verbose=TRUE){
    # Predicts subtype of new patients from labeled training set of patients 
    #   using label propigation or local and global consistency.
    #
    # Args:
    #   train: List affinity matrices for samples with known labels
    #   test: List affinity matrices for samples with unknown labels.
    #       Length of test must match length of train (and order?)
    #   groups: Labels specifying the groups in train
    #   K: SNF parameter for number of neighbours in KNN step
    #   alpha: SNF Hyperparameter 
    #   t: SNF varaible - number of iterations
    #   method: 0/1 specifies method used (1) Label propagation or
    #       (0) Local & global consistency.
    #
    # Returns: 
    #   Vector of new labels assigned to the test samples 
    
    # update dist method
    Wi <- vector("list", length=length(train))
    
    for (i in 1:length(train)){
        view_i <- standardNormalization(rbind(train[[i]],test[[i]]))
        # Dist1 <- dist2(view_i, view_i)
        if (verbose) {print (paste("Start Dist", i))}
        Dist2 <- amap::Dist(view_i, nbproc=15)
        Wi[[i]] <- affinityMatrix(as.matrix(Dist2), K, alpha)
    }
    
    W <- SNF(Wi,K,t)
    Y0 <- matrix(0,nrow(view_i), max(groups))
    for (i in 1:length(groups)){
        Y0[i,groups[i]] <- 1
    }
    
    if (verbose) {print ("Start .csPrediction")}
    Y <- .csPrediction(W,Y0,method)
    newgroups <- rep(0,nrow(view_i))
    for (i in 1:nrow(Y)){
        newgroups[i] <- which(Y[i,] == max(Y[i,]))
    }
    
    
    return (list(W=W, Y=Y, newgroups=newgroups))
}
