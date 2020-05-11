%The main implementation of Robot we use, which considers itself a box.

classdef BoxBot < Robot
    properties
        %The angles of the LIDAR sweep which we care about for the left,
        %center, and right splices, in degrees
        leftStart = 10;%30
        leftEnd = 150;%150
        rightStart = 300;%210
        rightEnd = 350;%330
        centerStart = 358;%330
        centerEnd = 2;%30
        
        %Previously, an arrow was drawn to indiciate robot heading
        arrow;
        arrowScale = 5;
        size = [1, 1]; %The width and height of the robot
    end

    methods
        %A constructor
        function obj = BoxBot(pos,theta,vel,size,app)
            obj = obj@Robot(pos,theta,vel,1,app); %Calls superclass constructor
            obj.size = size;
        end

        %Draws the box of the robot
        function obj = draw(obj)
            hold(obj.app.EnvAxes, 'on') %Holds environment on
            rhat = [cos(obj.theta),sin(obj.theta)]; %The unit direction 
            %vector along robot heading
            %Coords for the vertices of the box
            xs = zeros(1,5);
            ys = zeros(1,5);
            phi = -obj.theta*180/pi;
            %Iterates over the four corners
            for i = 1:4
                ri = obj.pos + obj.size.*[cos((phi+45+i*90)*pi/180),sin((phi+45+i*90)*pi/180)];
                xs(i) = ri(1);
                ys(i) = ri(2);
            end
             %Copies first corner to last corner, closing the loop
            xs(5) = xs(1);
            ys(5) = ys(1);
            %Draws robot
            obj.internalFigure = plot(obj.app.EnvAxes,xs,ys,'r-');
            hold(obj.app.EnvAxes, 'off');
        end

        %Splices the LIDAR distance array according to the ranges specified
        %above
        function [left, center, right] = splice(obj, walls)
            distances = obj.findDistanceCloud(walls); %Calls superclass isntance method
            len = numel(distances); %Finds the number of rays found above

            %Splices array, based on proportion of angle.
            center = ([distances(round(len*obj.centerStart/360):end) distances(1:round(len*obj.centerEnd/360)) ]);
            left = (distances(round(len*obj.leftStart/360):round(len*obj.leftEnd/360)));
            right = (distances(round(len*obj.rightStart/360):round(len*obj.rightEnd/360)));
        end
    end
end
