%Basic method to initially draw the field given a list of field objects.
%Creates a figure as needed.
function fieldObjects = InitField(fieldObjects)
axis([-10  10    -10  10], 'square');
title('Field Plot');
for i = 1:numel(fieldObjects)  %Iterates over the field objects, calling their draw method
    fieldObjects(i) = fieldObjects(i).draw();
end
end
