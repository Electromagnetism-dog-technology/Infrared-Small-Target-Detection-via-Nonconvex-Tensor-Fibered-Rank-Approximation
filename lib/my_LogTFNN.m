function [B,T,Z,Out] = my_LogTFNN(X,tenW,opts)

%% initial value of parameters
M = rankN(X,0.1);
% M=100;
Nway = size(X); 

tol      = 1e-4;         
max_iter = 20;
rho      = 1.2;

alpha   = [1,1,opts.theta]/(2+opts.theta);

lambda0 = 1/sqrt(max(Nway(3),Nway(2))*Nway(1));
lambda2  = opts.varpi*lambda0;

tau      = opts.omega*[1,1,1];
mu       = alpha./tau; 
beta     = 1/mean(tau);

max_mu   = 1e10*[1,1,1];        
max_beta = 1e10; 

logtol   = opts.logtol;    

%% Initialization
D=X;
B = zeros(Nway); 
T = B;
X1 = B;
X2 = B;
X3 = B;
M1 = X1; 
M2 = X2;
M3 = X3;
P = B; 
Z = B; 

V1=ones(Nway);
V2=ones(Nway);
V3=ones(Nway);


Y1=ones(Nway);
Y2=ones(Nway);
Y3=ones(Nway);
Y4=ones(Nway);
weightTen = ones(Nway);
Out.Res=[]; Out.PSNR=[];
for iter = 1 : max_iter
    %% Let
    Lold = B;
    B1 = permute(B,[2,3,1]);  B2 = permute(B,[3,1,2]);  B3 = B;
    m1 = permute(M1,[2,3,1]); m2 = permute(M2,[3,1,2]); m3 = M3;
    
    %% update X
    tau = alpha./mu;
    X1 = ipermute(ProTlogSum(B1+m1/mu(1),tau(1),logtol),[2,3,1]);
    X2 = ipermute(ProTlogSum(B2+m2/mu(2),tau(2),logtol),[3,1,2]);
    X3 = ProTlogSum(B3+m3/mu(3),tau(3),logtol);   
    
    %% update B
    temp = mu(1)*(X1-M1/mu(1)) + mu(2)*(X2-M2/mu(2)) + mu(3)*(X3-M3/mu(3)) + beta*(D-T+P/beta);
    B = temp/(beta+sum(mu));
    
    %% update T
    T = prox_l1(D-B+P/beta,weightTen*lambda2/beta);
    weightTen = M./ (abs(T) + 0.01)./tenW;
    
    %% update Z
    Z=prox_z(Z,Y1,Y2,Y3,Y4,B,rho,V1,V2,V3);
     
    %% update V1,V2,V3
    dim = size(X);
    tenX = reshape(X, dim);
    dfz1=diff(Z, 1, 1);
    Z1 = zeros(dim);
    Z1(1:end-1,:,:) = dfz1;
    Z1(end,:,:) = tenX(1,:,:) - tenX(end,:,:);
    
    dfz2=diff(Z, 1, 2);
    Z2 = zeros(dim);
    Z2(:,1:end-1,:) = dfz2;
    Z2(:,end,:) = tenX(:,1,:) - tenX(:,end,:);
    
    dfz3=diff(Z, 1, 3);
    Z3 = zeros(dim);
    Z3(:,:,1:end-1) = dfz3;
    Z3(:,:,end) = tenX(:,:,1) - tenX(:,:,end);
    
    dV1=Z1-Y2/rho;
    dV2=Z2-Y3/rho;
    dV3=Z3-Y4/rho;
    
    V1=prox_l1(dV1, beta/rho);    
    V2=prox_l1(dV2, beta/rho);
    V3=prox_l1(dV3, beta/rho);
    
    %% update Y1,Y2,Y3,Y4
    Y1=Y1+rho*(Z-B);
    Y2=Y2+rho*(V1-Z1);
    Y3=Y3+rho*(V2-Z2);
    Y4=Y4+rho*(V3-Z3);
    
    %% check the convergence
    dM = D-B-T;
    chg=norm(Lold(:)-B(:))/norm(Lold(:)); 
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
    M1 = M1 + mu(1)*(B-Z1);
    M2 = M2 + mu(2)*(B-Z2);
    M3 = M3 + mu(3)*(B-Z3);
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
