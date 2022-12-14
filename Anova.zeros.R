# This function is to calculate the Kruskal-Wallis statistic when the data has 
# a clump of zeros. 
#

# Inputs:
# x: a numeric vector of data values, or a list of numeric data vectors.
# g: a vector or factor object giving the group for the corresponding elements of x. Ignored if x is a list.
# alpha: a constant giving the level of the testing problem. Default value as 0.05
# perm: TRUE/FALSE value. If TURE, then the p-value will be calculated through permutations. Default as FALSE.
#
# Outputs:
# H: TRUE/FALSE value, giving the hypothesis testing result
# p.value: the p-value 
# statistics: the modified Kruskal-Wallis statistic

ANOVA.zeros <- function(x, g, alpha = 0.05, perm = FALSE){
	if(class(x) == "numeric" || class(x) == "data.frame"){
		s = levels(g); newx = as.vector(NULL, mode = "list")
		for(i in 1:s){
			newx = list(newx, x[g==leves(g)[i]])
		}
		names(newx) = names(g)
	}

	K = length(x); N = n = rep(0, K); xvec = numeric(0);
	for(i in 1:K){ 
		N[i] = length(x[[i]]); n[i] = sum(x[[i]] !=0)
		xvec = c(xvec, x[[i]]);
		}
	prop = n/N; pmax = max(prop);
	Ntrun = round(pmax*N);
	
	Xtrun.vec = numeric(0);
	for(i in 1:K){ 
		data = x[[i]];
		Xtrun.vec = c(Xtrun.vec, data[data != 0], rep(0, Ntrun[i] - n[i]));
		}
	rankdata = sum(Ntrun) + 1 - rank(Xtrun.vec); 
	
	r = sum(rankdata[1:Ntrun[1]]);
	for(i in 2:K){ 
		r = c(r, sum(rankdata[1:Ntrun[i] + sum(Ntrun[1:(i-1)])]))
		}
	s = r - Ntrun*(sum(Ntrun) + 1)/2; u = numeric(0);
	for(i in 1:(K - 1)){
		u = c(u, N[i+1]*sum(s[1:i]) - sum(N[1:i])*s[i+1]);
		}
	u = u/sum(N)^2;

	thetam = mean(prop); 
	## To calculate the expectation part, we simulate 5000 trials
	simun = matrix(0, nrow = 5000, ncol = K); simup = simun;
	for(ss in 1:K){
		simun[,ss] = rbinom(5000, N[ss], thetam);		
		simup[,ss] = simun[,ss]/N[ss];
	}
	simupmax = apply(simup, 1, max);
	varsimu = numeric(K - 1);
	varsimu[1] = N[2]^2*mean(simupmax^2*(simup[,1] - simup[,2])^2)*N[1]^2;
	varu2 = N[2]*N[1]*(N[1] + N[2]);
	for(ss in 2:(K-1)){
		varsimu[ss] = N[ss+1]^2*mean(simupmax^2*(apply(simun[,1:ss], 1, sum) - simup[,ss+1]*sum(N[1:ss]))^2);
		varu2 = c(varu2, N[ss+1]*sum(N[1:ss])*sum(N[1:(ss+1)]));
	}
	varsimu = varsimu/(sum(N))^2/4;

	varu2 = varu2*thetam^2*(thetam + 1/sum(N))/12/(sum(N))^2;
	varu = varsimu + varu2;

	w = sum(u^2/varu);

	if(perm){
		numrep = 10000; permu.w = rep(0, numrep)
		for(i in 1:numrep){
			ind = sample(xvec, sum(N));
			for(i in 1:K) n[i] = sum(xvec[sum(N[0:(i - 1)]) + 1:N[i]] !=0);
			prop = n/N; pmax = max(prop);
			Ntrun = round(pmax*N);
	
			Xtrun.vec = numeric(0);
			for(i in 1:K){ 
				data = xvec[sum(N[0:(i - 1)]) + 1:N[i]];
				Xtrun.vec = c(Xtrun.vec, data[data != 0], rep(0, Ntrun[i] - n[i]));
			}
			rankdata = sum(Ntrun) + 1 - rank(Xtrun.vec); 
	
			r = sum(rankdata[1:Ntrun[i]]);
			for(i in 1:length(x)){ 
				r = c(r, sum(rankdata[1:Ntrun[i] + sum(Ntrun[1:(i-1)])]))
			}
			s = r - Ntrun*(sum(Ntrun) + 1)/2;
			for(i in 1:(K - 1))
				u = c(u, N[i+1]*sum(s[1:i]) - sum(N[1:i])*s[i+1]);
			u = u/sum(N)^2;

			thetam = mean(prop);
			simun = matrix(0, nrow = 5000, ncol = K); simup = simun;
			for(ss in 1:K){
				simun[,ss] = rbinom(5000, N[ss], thetam);		
				simup[,ss] = simun[,ss]/N[ss];
			}
			simupmax = apply(simup, 1, max);
			varsimu = numeric(K - 1);
			varsimu[1] = N[2]^2*mean(simupmax^2*(simup[,1] - simup[,2])^2)*N[1]^2;
			varu2[1] = N[2]*N[1]*(N[1]+N[2]);
			for(ss in 2:(K-1)){
				varsimu[ss] = N[ss+1]^2*mean(simupmax^2*(apply(simun[,1:ss], 1, sum) - simup[,ss+1]*sum(N[1:ss]))^2);
				varu2[ss] = N[ss+1]*sum(N[1:ss])*sum(N[1:(ss+1)]);
			}
			varsimu = varsimu/(sum(N))^2/4;

			varu2 = varu2*sum(N)*thetam^2*(sum(N)*thetam + 1)/12/(sum(N))^4;
			varu = varsimu + varu2;

			permu.w[i] = sum(u^2/varu);
			}
		pw = sum(w < permu.w)/numrep;
		}

	else{
		pw = pchisq(w, K-1, lower.tail = F);}

	H = (pw < alpha);
	result <- list(H = H, p.value = pw, statistics=w)
	return(result)
}
