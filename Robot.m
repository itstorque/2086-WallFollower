%The abstract form of the robot class, implementing the FieldObject type.
%The robot contains the LIDAR methods, it's own drawing and updating
%code, and PID coefficients.
classdef Robot < FieldObject

    properties
        dTheta = 1; %The increments over which the LIDAR sweeps, in degrees
        theta = pi/4; %The start angle of the robot, in radians
        velocity = 0.01; %The velocity
        ackerman_noise_factor; %Noise factors
        ackerman_noise;
        errors = [];
        
        % Change this side value to make the robot track the wall on the
        % other side of it
        side = -1; % 1 for left, -1 for right
        
        %PID coefficients
        kfront = 0.5;
        kp = 0.8;
        kd = 0.2;
        ki = 0.001;

        int_lookup=5;
        dv_lookup=2;
    end

    methods (Abstract)
        %Each robot type splices it's LIDAR data differently, hence it is
        %abstracted here
        [left, center, right] = splice(obj, walls)
    end

    methods
        %Constructor method
        function obj = Robot(pos,theta,velocity, dTheta,app)
            obj = obj@FieldObject(app); %Calls superclass constructor;
            obj.pos = pos;
            obj.theta = theta; %Angle, in degrees
            obj.velocity = velocity*0.1;
            obj.dTheta = dTheta; %Increment for distance cloud, in degrees

            obj.errors = [];

            obj.ackerman_noise_factor = 4;
            obj.ackerman_noise = @(angle) angle+obj.ackerman_noise_factor*(rand()-0.5);
        end

        %Finds the distance from the robot to the nearest wall along a
        %bunch of rays emanating from the robot. Takes as input all the
        %walls on the field.
        function [distances] = findDistanceCloud(obj, walls)
            wallCount = length(walls); %The number of walls
            %Pre-allocates memorys for the distances found
            distances = zeros(1,numel(obj.theta:obj.dTheta:(360+obj.theta-obj.dTheta)));
            k = 1;
            warning('off','MATLAB:nearlySingularMatrix');
            %Iterates over all angles of these rays, starting directly in
            %front of the robot.
            for i = obj.theta*180/pi:obj.dTheta:(360+obj.theta*180/pi-obj.dTheta)
                min = 1e300;
                i = 90 - i;
                phi = i*pi/180; %Converts to degrees
                %Cosine and sine of current angle
                c = cos(phi);
                s = sin(phi);
                %Iterates over all walls
                for j = 1:wallCount
                    wall = walls{1, j};
                    %Finds intersection using FEX code
                    [x,y] = intersections([wall.x1 wall.x2], [wall.y1,wall.y2], [obj.pos(1) (obj.pos(1)+c*1e15)], [obj.pos(2) (obj.pos(2)+s*1e15)],1);
                    %If intersection exists
                    if(~isempty(x))
                        range = norm([x(1),y(1)]-obj.pos); %Find distance to intersection
                        if(range < min) %Check if its minimal (could be it intersects multiple walls)
                            min = range;
                        end
                    end
                end
                %Sets all non-intersecting rays to zero
                if abs(min) > 1e299
                    min = 0;
                end
                distances(k) = min; %Updates distance values
                k = k + 1;
            end
            
            distances(distances==0) = 10; %Cludge; sets all non-intersecting rays to ten (field size).
            
        end

    end
end
