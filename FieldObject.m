classdef FieldObject < matlab.mixin.Heterogeneous
    properties
        pos;
        internalFigure;
    end
    
    methods (Abstract)
        obj = drawInit(obj);
        obj = drawUpdate(obj);
    end
end

