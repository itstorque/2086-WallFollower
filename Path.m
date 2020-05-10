classdef Path < FieldObject
 
    properties
        positions;
    end
    
    methods
        function obj = Path(pos)
            obj.positions = [pos];
        end
        
        function obj = addPos(obj,pos)
            a = obj.positions;
            obj.positions = [a; pos];
        end
        
        function obj = drawInit(obj)
            hold on
            obj.internalFigure = plot(obj.positions(:,1),obj.positions(:,2),"g","LineWidth",1.3);
            hold off
        end
        
        function obj = drawUpdate(obj)
            hold on
            set(obj.internalFigure,'xdata',obj.positions(:,1),'ydata',obj.positions(:,2))
            hold off
        end
        
    end
end

