%Updates an existing field, given a list of field objects
function fieldObjects = UpdateField(fieldObjects)
    for i = 1:numel(fieldObjects) %Iterates over the field objects, calling their draw method
       fieldObjects(i) = fieldObjects(i).drawUpdate();
    end
end