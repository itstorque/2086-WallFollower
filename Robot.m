classdef Robot < FieldObject

    properties
        dTheta = 1;
        theta = pi/4;
        velocity = 0.01;
        ackerman_noise_factor;
        ackerman_noise;
        errors = [];
        side = -1; %-1 for left, 1 for right
        kfront = 0.5;
        kp = 0.8;
        kd = 0.2;
        ki = 0.001;

        int_lookup=5;
        dv_lookup=2;
    end

    methods (Abstract)
        [left, center, right] = splice(obj, walls)
    end

    methods
        function obj = Robot(pos,theta,velocity, dTheta,app)
            obj = obj@FieldObject(app);
            obj.pos = pos;
            obj.theta = theta; %Angle, in degrees
            obj.velocity = velocity*0.1;
            obj.dTheta = dTheta; %Increment for distance cloud, in degrees

            obj.errors = [];

            obj.ackerman_noise_factor = 4;
            obj.ackerman_noise = @(angle) angle+obj.ackerman_noise_factor*(rand()-0.5);
        end

        function [distances] = findDistanceCloud(obj, walls)
            wallCount = length(walls);
            distances = zeros(1,numel(obj.theta:obj.dTheta:(360+obj.theta-obj.dTheta)));
            k = 1;
            warning('off','MATLAB:nearlySingularMatrix');
            for i = obj.theta:obj.dTheta:(360+obj.theta-obj.dTheta)
                min = 1e300;
                phi = i*pi/180;
                c = cos(phi);
                s = sin(phi);
                for j = 1:wallCount
                    wall = walls{1, j};
                    [x,y] = intersections([wall.x1 wall.x2], [wall.y1,wall.y2], [obj.pos(1) (obj.pos(1)+c*1e15)], [obj.pos(2) (obj.pos(2)+s*1e15)],1);
                    if(~isempty(x))
                        range = norm([x(1),y(1)]-obj.pos);
                        if(range < min)
                            min = range;
                        end
                    end
                end
                if abs(min) > 1e299
                    min = 0;
                end
                distances(k) = min;
                k = k + 1;
            end
        end

    end
end
