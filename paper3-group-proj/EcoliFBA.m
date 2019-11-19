%initCobraToolbox;

%fullEcoliModel = readCbModel('iJO1366.xml');
numReactions = length(fullEcoliModel.rxns);
baseGrowth = optimizeCbModel(fullEcoliModel,'max');

allGrowth = cell(numReactions,1);
cutoff = times(0.05,baseGrowth.f);

for reaction = 1:numReactions
   newGrowth = drop_and_calculate(fullEcoliModel, reaction); 
   if newGrowth < cutoff
      newCell = {fullEcoliModel.rxns{reaction}, newGrowth};
      allGrowth{reaction} = newCell;
   end
end

essential = allGrowth(~cellfun('isempty', allGrowth));
%write essential reactions to a file that we can open in python
fileID = fopen('essential_rxns.txt','w');
for reaction = 1:size(essential)
rxn_name = essential{reaction}{1};
fprintf(fileID,'%s\n', rxn_name);
end
fclose(fileID);

function growth = drop_and_calculate(eColiModel, i)
    eColiModel.rxns(i) = []; % drop reaction
    eColiModel.S(:,i) = []; %drop reaction column - does this work?
     %dropping corresponding things....
    eColiModel.lb(i) = [];
    eColiModel.ub(i) = [];
    eColiModel.c(i) = [];
    %calculate new growth without reaction at i
    solvedFBA  = optimizeCbModel(eColiModel,'max');
    growth = solvedFBA.f; 
end
