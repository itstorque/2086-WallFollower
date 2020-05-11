classdef Path < FieldObject

    properties
        positions;
    end

    methods
        function obj = Path(pos,app)
            obj = obj@FieldObject(app);
            obj.positions = [pos];
        end

        function obj = addPos(obj,pos)
            a = obj.positions;
            obj.positions = [a; pos];
        end

        function obj = draw(obj)
            hold(obj.app.EnvAxes, 'on');
            obj.internalFigure = plot(obj.app.EnvAxes,obj.positions(:,1),obj.positions(:,2),'g','LineWidth',1.3);
            hold(obj.app.EnvAxes, 'off');
        end

    end
end
