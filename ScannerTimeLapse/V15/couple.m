function ordVec = couple(Vec, coupling)
% function ordVec = couple(Vec, coupling)
% -----------------------------------------------------------------------
% Purpose: To put the vector in the coupling order
%
% Description: coupling is like a permutation vector, but it can contain
%          zeros. Where there is a zero, we want the ord vec to contain 
%          zero also.
% Aruments: Vec - the vector for permuting.
%          coupling - the permutation vector.
% Returns: ordVec - Vec after changing the places of the cells
% -----------------------------------------------------------------------
% Irit Levin. 14.9.2006

ordVec = zeros(size(coupling,1),size(Vec,2));
ordVec(find(coupling>0),:) = Vec(coupling(coupling>0),:);