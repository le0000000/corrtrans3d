function [models, model_weights, model_geo] = straighten_array(models)
% Given an array of models, performs the following:
% - downsampling of the model to a size of 1000 vertices (if the original
% has more)
% - calculating the geodesic distance-based straightening
% - calculating the weights-based straightening


if size(models, 1) > 1
    % turn column into row
    models = models';
end

for i=1:size(models, 2)
   disp('--------------------')
   disp(i);
   if size(models(1,i).vertices,1) > 1000
       disp('Downsampling');
       models(1,i) = reduceMesh(models(1,i), 1000);
   end
   
   model_weights(1,i) = transformUsingWeights(models(1,i), 3);
   %model_geo(1,i) = transformUsingSENystrom(models(1,i),50);
   model_geo(1,i) = transformUsingSE(models(1,i));
end
