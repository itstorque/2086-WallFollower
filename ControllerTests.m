ackerman_noise_factor = 4;
ackerman_noise = @(angle) angle+ackerman_noise_factor*(rand()-0.5);

w1 = Wall(2.5,7.5,7.5,2.5);
walls = [w1];

v = 0.1;
bot = PointBot([0,0],45,v);
head = [v*sin(bot.theta*pi/180) v*cos(bot.theta*pi/180)];

objects = InitField([walls bot]);
hold on
h = quiver(bot.pos(1),bot.pos(2),head(1),head(2), 'MaxHeadSize', 5);
hold off

for i = 0:10000
    bot = objects(end);
    bot.pos = bot.pos + head;
    bot.theta = bot.theta + 180/pi*ackerman_noise(pi/90);
    head = [v*sin(bot.theta*180/pi) v*cos(bot.theta*180/pi)];
    set(h,'xdata',bot.pos(1),'ydata',bot.pos(2),'udata',head(1),'vdata',head(2),'AutoScale','on', 'AutoScaleFactor', 10)
    
    objects(end) = bot;
    objects = UpdateField(objects);
    pause(0.1)

    %collision checking stuff

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

end

hold off
close