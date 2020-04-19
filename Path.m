classdef Path < FieldObject
 
    properties
        positions
    end
    
    methods
        function obj = Path(pos)
            obj.positions = pos;
        end
        
        function obj = addPos(obj,pos)
            obj.positions = [obj.positions pos];
        end
        
        function figure = draw(figureI)
            figure = figureI;
        end
    end
end

