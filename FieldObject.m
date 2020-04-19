classdef FieldObject
    properties
        pos
    end
    
    methods (Abstract)
        figure = draw(obj, figure)
    end
end

