classdef FieldObject < matlab.mixin.Heterogeneous
    properties
        pos;
        internalFigure;
        app;
    end
    
    methods
        function obj = FieldObject(app)
            obj.app = app;
        end
    end
    
    methods (Abstract)
        obj = drawInit(obj);
        obj = drawUpdate(obj);
    end
end

