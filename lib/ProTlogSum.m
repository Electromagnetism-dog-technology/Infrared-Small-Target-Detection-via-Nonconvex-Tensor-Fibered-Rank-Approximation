function [X] = ProTlogSum(Y, rho, tol)

dim = ndims(Y);
[n1, n2, n3] = size(Y);
n12 = min(n1, n2);
Yf = fft(Y, [], dim);
Uf = zeros(n1, n12, n3);
Vf = zeros(n2, n12, n3);
Sf = zeros(n12,n12, n3);

Yf(isnan(Yf)) = 0;
Yf(isinf(Yf)) = 0;

trank = 0;
endValue = n3/2 + 1;
for i = 1 : endValue
    [ temp, Sf(:, :, i),Uf(:,:,i),Vf(:,:,i)] = Pro2MlogSum(Yf(:,:,i), rho, tol); 
    trank = max(temp, trank);
end

for j =n3:-1:endValue+1
    Uf(:,:,j) = conj(Uf(:,:,n3-j+2));
    Vf(:,:,j) = conj(Vf(:,:,n3-j+2));
    Sf(:,:,j) = Sf(:,:,n3-j+2);
end

Uf = Uf(:, 1:trank, :);
Vf = Vf(:, 1:trank, :);
Sf = Sf(1:trank, 1:trank, :);

U = ifft(Uf, [], dim);
S = ifft(Sf, [], dim);
V = ifft(Vf, [], dim);

X = tprod( tprod(U,S), tran(V) );
end



function [n, SigmaNew, U, V] = Pro2MlogSum(Z, tau, tol)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% min: 1/2*||Z-X||^2 + tau * P_ls^*(X)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [U, Sigma, V] = svd(Z, 'econ');
    Sigma         = diag(Sigma);
    c1            = Sigma-tol;
    c2            = c1.^2-4*(tau-tol*Sigma);    
%     tol           = Sigma.^2/100000000;
%     c1            = Sigma-tol;
%     c2            = c1.^2-4*(tau-tol.*Sigma);  
    ind           = find (c2>0);
    n             = length(ind);
    SigmaNew      = zeros(length(Sigma),1) ;
    SigmaNew(1:n) = (c1(1:n)+sqrt(c2(1:n)))/2;
    SigmaNew      = diag(SigmaNew);
end