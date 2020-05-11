function fieldObjects = InitField(fieldObjects)
axis([-10  10    -10  10], 'square');
title('Field Plot');
for i = 1:numel(fieldObjects)
    fieldObjects(i) = fieldObjects(i).draw();
end
end
