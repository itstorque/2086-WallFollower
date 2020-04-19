classdef Wall < FieldObject
    
    properties
        point1
        point2
    end
    
    methods
        function obj = Obstacle(x1,y1,x2,y2)
            obj.pos = 0.5*[(x1+x2),(y1+y2)];
            obj.point1 = [x1,y1];
            obj.point2 = [x2,y2];
        end
        
        function output = draw(obj, figure)
            output = figure;
        end
    end
end

