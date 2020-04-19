classdef Robot < FieldObject

    properties
        pos = [0 0]
        dTheta = 0
        theta = pi/4
        velocity = 0.1
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

            obj.ackerman_noise_factor = 4;
            obj.ackerman_noise = @(angle) angle+obj.ackerman_noise_factor*(rand()-0.5);
        end

        function [points] = findDistanceCloud(obj, walls)

        end

    end
end
