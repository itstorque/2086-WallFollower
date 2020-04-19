ackerman_noise_factor = 4;
ackerman_noise = @() ackerman_noise_factor*(rand()-0.5);

walls = [[2.5,7.5, 7.5,2.5];];

coords = [0, 0, pi/4];%[x, y, theta]
v = 0.1;
head = [v*sin(coords(3)) v*cos(coords(3))];

k = plot(coords(1), coords(2), 'ro');
hold on

for wall_idx = 1:size(walls, 1)
    
    wall = walls(wall_idx, :);
    
    plot(wall([1 3]), wall([2 4]), 'b-')
    
end

h = quiver(coords(1),coords(2),head(1),head(2), 'MaxHeadSize', 5);
axis([-10  10    -10  10], "square")

for i = 0:10000
    coords(1:2) = coords(1:2) + head;
    coords(3) = coords(3) + pi/90*ackerman_noise();
    head = [v*sin(coords(3)) v*cos(coords(3))];
    set(h,'xdata',coords(1),'ydata',coords(2),'udata',head(1),'vdata',head(2),'AutoScale','on', 'AutoScaleFactor', 10)
    set(k,'xdata',coords(1),'ydata',coords(2))
    pause(0.1)
    
    %collision checking stuff
    
    for wall_idx = 1:size(walls, 1)
    
        wall = walls(wall_idx, :);

        v1 = [head(1)-coords(1), head(2)-coords(2)];
        v2 = [wall(3)-wall(1), wall(4)-wall(2)];

        cross_prod = cross([v1, 0], [v2, 0]);

        if (cross_prod(3) ~= 0)

            dp = wall(1:2)-coords(1:2);

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