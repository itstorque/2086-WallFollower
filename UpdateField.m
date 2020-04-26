function fieldObjects = UpdateField(fieldObjects)
    for i = 1:numel(fieldObjects)
       fieldObjects(i) = fieldObjects(i).drawUpdate();
    end
end