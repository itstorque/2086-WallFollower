classdef Robot < FieldObject
    
    properties
        dTheta
        theta
        velocity
    end
    
    methods (Abstract)
        [left, center, right] = splice(obj, walls)
    end
    
    methods
        function obj = Robot(pos,theta,velocity, dTheta)
            obj.pos = pos;
            obj.theta = theta;
            obj.velocity = velocity;
            obj.dTheta = dTheta;
        end
        
        function [points] = findDistanceCloud(obj, walls)
            
        end
        
    end
end

