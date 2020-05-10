classdef Robot < FieldObject

    properties
        dTheta = 0;
        theta = pi/4;
        velocity = 0.1;
        ackerman_noise_factor;
        ackerman_noise;
        errors = [];
        side = -1; %-1 for left, 1 for right
        kfront = 2;
        kp = 0.8;
        kd = 0.1;
        ki = 0.01;
    end

    methods (Abstract)
        [left, center, right] = splice(obj, walls)
    end

    methods
        function obj = Robot(pos,theta,velocity, dTheta)
            obj.pos = pos;
            obj.theta = theta; %Angle, in degrees
            obj.velocity = velocity;
            obj.dTheta = dTheta; %Increment for distance cloud, in degrees

            obj.errors = [];

            obj.ackerman_noise_factor = 4;
            obj.ackerman_noise = @(angle) angle+obj.ackerman_noise_factor*(rand()-0.5);
        end

        function [distances] = findDistanceCloud(obj, walls, wallCount)
            wallCount
            distances = [];
            for i = obj.theta:obj.dTheta:(360+obj.theta-obj.dTheta)
                min = 1e300;
                phi = i*pi/180;
                c = cos(phi);
                s = sin(phi);
                for j = 1:wallCount
                    wall = walls{1, j};
                    range = NaN;
                    [x,y] = intersections([wall.x1 wall.x2], [wall.y1,wall.y2], [obj.pos(1) (obj.pos(1)+c*1e15)], [obj.pos(2) (obj.pos(2)+s*1e15)],1);
                    if(~isempty(x))
                        range = norm([x(1),y(1)]-obj.pos);
                        if(range < min)
                            min = range;
                        end
                    end
                end
                distances = [distances min];
            end
        end

    end
end
