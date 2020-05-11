% This file was used to test random functionality of the WallFollower
% and aided in the merging of the many modules, however, it has no use
% past testing only. Moreover, it may no longer be functional.

close
ackerman_noise_factor = 4;
ackerman_noise = @(angle) angle+ackerman_noise_factor*(rand()-0.5);

%Manually creates a wall
w1 = Wall(2.5,7.5,7.5,2.5);
walls = [w1];

%Creates an instance of the BoxBot
v = 0.5;
bot = BoxBot([0,0],25,v,1);
path = Path([0,0]);
head = [v*sin(bot.theta*pi/180) v*cos(bot.theta*pi/180)];

%Inits the field
objects = InitField([walls path bot]);
pause(1)
%A test just to check the field re-draws properly with an updated theta
"Changed Theta"
objects(end).theta = -22;
"Tried to Update Field"
objects = UpdateField(objects);

%Early loop to run the noise component of the algorithm
for i = 0:10000
    %Noise algorithm
    bot = objects(end);
    bot.theta = bot.theta + 180/pi*ackerman_noise(pi/90);
    head = [v*sin(bot.theta*180/pi) v*cos(bot.theta*180/pi)];
    %Updates robot position
    bot.pos = bot.pos + head
    %Displaces LIDAR splice data
    [left, center, right] = bot.splice(walls)
    %Test of Path field object functionality
    path = objects(end-1);
    path = path.addPos(bot.pos);
    objects(end-1) = path;
    %set(h,'xdata',bot.pos(1),'ydata',bot.pos(2),'udata',head(1),'vdata',head(2),'AutoScale','on', 'AutoScaleFactor', 10)

    objects(end) = bot;
    objects = UpdateField(objects);
    pause(0.5)
    coords = bot.pos;
    %{
    %collision checking stuff. Early implementation

    for wall_idx = 1:size(walls, 1)

        wall = walls(wall_idx, :);

        v1 = [head(1)-coords(1), head(2)-coords(2)];
        v2 = [wall.x2-wall.x1, wall.y2-wall.y1];

        cross_prod = cross([v1, 0], [v2, 0]);

        if (cross_prod(3) ~= 0)

            dp = wall.point1-coords(1:2);

            lambda1 = cross([dp, 0], [v2, 0]) / cross_prod;
            lambda2 = cross([dp, 0], [v1, 0]) / cross_prod;

            collide = all([lambda1 >= 0, lambda1 <= 1, lambda2 >= 0, lambda2 <= 1]);

        end

    end

    if collide == true
        'COLLISION DETECTED'
        break
    end
    %}
end

hold off
close
%}
