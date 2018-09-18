classdef Line
    properties
        startX
        startY
        endX
        endY
        length 
        globalIndex % just in case
    end
    
    methods
        function obj = Line(startX_,startY_,endX_,endY_,globalIndex_)
            obj.startX = startX_;
            obj.startY = startY_;
            obj.endX = endX_;
            obj.endY = endY_;
            obj.globalIndex=globalIndex_;
            
            latlon1=[startX_ startY_];
            latlon2=[endX_ endY_];
            obj.length = Functions.lldistkm(latlon1,latlon2);
        end
        
        function itIs = isObstacleInLine(obj,x,y,offset)
            offset=offset* 0.0000089;
     
            % number of km per degree = ~111km (111.32 in google maps, but range varies
            %between 110.567km at the equator and 111.699km at the poles)
            % 1km in degree = 1 / 111.32km = 0.0089
            % 1m in degree = 0.0089 / 1000 = 0.0000089

            poly1=polyshape([x-offset x-offset  x+offset x+offset],[y+offset y-offset y-offset y+offset]);
            line=[obj.startX obj.startY ; obj.endX obj.endY];
            [in,out]=intersect(poly1,line);
            if (isempty(in))
                itIs = 0;
            else
                itIs = 1;
            end
        end
       
    end
end

