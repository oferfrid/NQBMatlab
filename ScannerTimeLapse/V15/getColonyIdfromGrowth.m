function CID = getColonyIdfromGrowth(TotColoniesIndices, TotlbSizeTime, TotubSizeTime, lbSizeTime, ubSizeTime)
% CID = getColonyIdfromGrowth(TotColoniesIndices, TotlbSizeTime, 
%                              TotubSizeTime, lbSizeTime, ubSizeTime)
% -------------------------------------------------------------------------
% Purpose: getting the colony id from groth time scatter plot
% Description: get the list of indices and searches by the growth time
%       parameters
% Arguments: TotColoniesIndices - a list of [scanner, plate, id]
%       TotlbSizeTime - a list of the times to reach lower bound size
%       TotubSizeTime - a list of the times to reach upper bound size
%       lbSizeTime - the wanted time to reach lower bound size
%       lbSizeTime - the wanted time to reach lower bound size
% Returns: CID - Colony Id: scanner, plate, Id
% -------------------------------------------------------------------------
% Irit L. Reisman 12.09

%%
ind = (TotlbSizeTime==lbSizeTime & TotubSizeTime==ubSizeTime);
CID = TotColoniesIndices(ind,:);