classdef BoxBot < Robot
    properties
        leftStart = 30;
        leftEnd = 150;
        rightStart = 210;
        rightEnd = 330;
        forwardStart = 330;
        forwardEnd = 30;
        arrow;
        arrowScale = 5;
        size;
    end

    methods
        function obj = BoxBot(pos,theta,vel,size)
            obj = obj@Robot(pos,theta,vel,1);
            obj.size = size;
        end

        function obj = drawInit(obj)
            hold on
            rhat = [cos(obj.theta*pi/180),sin(obj.theta*pi/180)];
            xs = zeros(1,5);
            ys = zeros(1,5);
            for i = 1:4
                ri = obj.pos + obj.size*[cos((obj.theta+45+i*90)*pi/180),sin((obj.theta+45+i*90)*pi/180)];
                xs(i) = ri(1);
                ys(i) = ri(2);
            end
            xs(5) = xs(1);
            ys(5) = ys(1);
            obj.internalFigure = plot(xs,ys,'r.-');
            head = obj.pos + obj.arrowScale*obj.velocity*rhat;
            obj.arrow = arrow(obj.pos,head,'Type','line');
            hold off
            disp('Created internal bot figure');
        end

        function obj = drawUpdate(obj)
            xs = zeros(1,5);
            ys = zeros(1,5);
            for i = 1:4
                ri = obj.pos + obj.size*[cos((obj.theta+45+i*90)*pi/180),sin((obj.theta+45+i*90)*pi/180)];
                xs(i) = ri(1);
                ys(i) = ri(2);
            end
            xs(5) = xs(1);
            ys(5) = ys(1);
            set(obj.internalFigure,'xdata',xs,'ydata',ys)
            head = obj.pos + obj.arrowScale*obj.velocity*[cos(obj.theta*pi/180),sin(obj.theta*pi/180)];
            set(obj.arrow,'xdata',[],'ydata',[])
            obj.arrow = arrow(obj.pos,head,'Type','line');
        end

        function [left, center, right] = splice(distances)
            len = numel(distances);
            center = mean([distances(1:30) distances(331:360)]);
            left = mean(distances(31:150));
            right = mean(distances(211:330));
        end
    end
end
