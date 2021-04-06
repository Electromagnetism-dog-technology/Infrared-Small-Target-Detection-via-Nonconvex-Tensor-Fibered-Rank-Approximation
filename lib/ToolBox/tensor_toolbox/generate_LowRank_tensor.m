function [Core,U,T]=generate_LowRank_tensor(Size,Rank)

Dim=length(Size);

Core=tensor(rand(Rank));
for i=1:Dim
U{i}=orth(rand(Size(i),Rank(i)));
end
T=double(ttm(Core,U));
T=T-min(T(:));
T=T/max(T(:));