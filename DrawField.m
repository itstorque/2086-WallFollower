function figure = DrawField(figureI, FieldObjects)
    figure = figureI;
    for i = 1:numel(FieldObjects)
       figure = FieldObjects(i).draw(figure);
    end
end