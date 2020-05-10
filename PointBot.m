classdef PointBot < Robot
    properties
        
    end
    
    methods
        function obj = PointBot(pos,theta,vel)
            obj = obj@Robot(pos,theta,vel,1);
        end
        
        function obj = drawInit(obj)
            hold on
            obj.internalFigure = plot(obj.pos(1),obj.pos(2),'ro');
            hold off
            disp("Created internal bot figure");
        end
        
        function obj = drawUpdate(obj)
            set(obj.internalFigure,'xdata',obj.pos(1),'ydata',obj.pos(2))
        end
        
        function [left, center, right] = splice(distances)
            center = mean([distances(1:30) distances(331:360)]);
            left = mean(distances(31:150));
            right = mean(distances(211:330));
        end
    end
end

