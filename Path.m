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
        
        function obj = drawInit(obj)
            figure = figureI;
        end
        
        function obj = drawUpdate(obj)
            
        end
        
    end
end

