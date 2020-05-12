%The field object representing the past positions of the robot. MATLAB's
%default interpolation is used to represent the intervening values.
classdef Path < FieldObject

    properties
        positions; %A list of all past positions
    end

    methods
        %Constructor method, initiallizes list of positions
        function obj = Path(pos,app)
            obj = obj@FieldObject(app); %Calls superclass constructor
            obj.positions = [pos];
        end

        %Adds a position to the list
        function obj = addPos(obj,pos)
            a = obj.positions;
            obj.positions = [a; pos];
        end

        %Plots an interpolated curve representing the path the robot has
        %traversed
        function obj = draw(obj)
            hold(obj.app.EnvAxes, 'on');
            obj.internalFigure = plot(obj.app.EnvAxes,obj.positions(:,1),obj.positions(:,2),'g','LineWidth',1.3);
            hold(obj.app.EnvAxes, 'off');
        end

    end
end
