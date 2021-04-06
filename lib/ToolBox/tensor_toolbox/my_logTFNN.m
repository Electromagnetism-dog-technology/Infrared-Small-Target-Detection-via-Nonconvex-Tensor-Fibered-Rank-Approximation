function [L,S,N,Out] = logTFNN(X,tenW,opts)

%% initial value of parameters
% M = rankN(X,0.1);
M=100;
Nway = size(X); 

tol      = 1e-4;         
max_iter = 150;
rho      = 1.2;

alpha   = [1,1,opts.theta]/(2+opts.theta);
lambda1 = opts.phi/opts.sigma;

lambda11 = 1/sqrt(max(Nway(3),Nway(2))*Nway(1));
lambda12 = 1/sqrt(max(Nway(1),Nway(3))*Nway(2));
lambda13 = 1/sqrt(max(Nway(1),Nway(2))*Nway(3));
lambda   = alpha(1)*lambda11+alpha(2)*lambda12+alpha(3)*lambda13;
lambda2  = opts.varpi*lambda;

tau      = opts.omega*[1,1,1];
mu       = alpha./tau; 
beta     = 1/mean(tau);

max_mu   = 1e10*[1,1,1];        
max_beta = 1e10; 

logtol   = opts.logtol;    

%% Initialization
L = zeros(Nway); 
S = L;
N = L; 
Z1 = L;
Z2 = L;
Z3 = L;
M1 = Z1; 
M2 = Z2;
M3 = Z3;
P = L; 

weightTen = ones(Nway);
Out.Res=[]; Out.PSNR=[];
for iter = 1 : max_iter
    %% Let
    Lold = L;
    L1 = permute(L,[2,3,1]);  L2 = permute(L,[3,1,2]);  L3 = L;
    m1 = permute(M1,[2,3,1]); m2 = permute(M2,[3,1,2]); m3 = M3;
    
    %% update Z
    tau = alpha./mu;
    Z1 = ipermute(ProTlogSum(L1+m1/mu(1),tau(1),logtol),[2,3,1]);
    Z2 = ipermute(ProTlogSum(L2+m2/mu(2),tau(2),logtol),[3,1,2]);
    Z3 = ProTlogSum(L3+m3/mu(3),tau(3),logtol);   
    
    %% update L
    temp = mu(1)*(Z1-M1/mu(1)) + mu(2)*(Z2-M2/mu(2)) + mu(3)*(Z3-M3/mu(3)) + beta*(X-N-S+P/beta);
    L = temp/(beta+sum(mu));
    
    %% update S
    S = prox_l1(X-N-L+P/beta,weightTen*lambda2/beta);
    weightTen = M./ (abs(S) + 0.01)./tenW;
    
    %% update N
    N = (beta*(X-L-S+P/beta))/(2*lambda1+beta);
      
    %% check the convergence
    dM = X-L-S-N;
    chg=norm(Lold(:)-L(:))/norm(Lold(:)); 
    Out.Res = [Out.Res,chg];
    if isfield(opts, 'Xtrue')
        XT=opts.Xtrue;
        psnr = PSNR3D(XT * 255, L * 255);
        Out.PSNR = [Out.PSNR,psnr];
    end
    
    if mod(iter, 10) == 0
         if isfield(opts, 'Xtrue')
            fprintf('3DLogTNN: iter = %d   PSNR= %f   res= %f \n', iter, psnr, chg);
         else
            fprintf('3DLogTNN: iter = %d   res= %f \n', iter, chg);
         end       
    end
    
    if chg < tol
        break;
    end
    
    %% update M & P
    P = P + beta*dM;
    M1 = M1 + mu(1)*(L-Z1);
    M2 = M2 + mu(2)*(L-Z2);
    M3 = M3 + mu(3)*(L-Z3);
    beta = min(rho*beta,max_beta);    
    mu = min(rho*mu,max_mu); 
end

function N = rankN(X, ratioN)
    [~,~,n3] = size(X);
    D = Unfold(X,n3,1);
    [~, S, ~] = svd(D, 'econ');
    [desS, ~] = sort(diag(S), 'descend');
    ratioVec = desS / desS(1);
    idxArr = find(ratioVec < ratioN);
    if idxArr(1) > 1
        N = idxArr(1) - 1;
    else
        N = 1;
    end