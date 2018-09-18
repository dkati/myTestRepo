classdef Obstacle    
    properties
       x
       y
       radius
    end
    
    methods
        function obj = Obstacle(x_,y_,radius_)
           obj.x        = x_;
           obj.y        = y_;
           obj.radius   = radius_;
        end
    end
end

