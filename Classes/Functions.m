classdef Functions    
    methods (Static)
        function printGoogle(table_)
            latRow1=[];
            lonRow1=[];
            latRow2=[];
            lonRow2=[];
            latRow3=[];
            lonRow3=[];
            latRow4=[];
            lonRow4=[];
            for j=1:3
                latRow1=[latRow1 table_{j,1}(1)];
                lonRow1=[lonRow1 table_{j,1}(2)];
            end
            for j=1:3
                latRow2=[latRow2 table_{j,2}(1)];
                lonRow2=[lonRow2 table_{j,2}(2)];
            end
            for j=1:3
                latRow3=[latRow3 table_{j,3}(1)];
                lonRow3=[lonRow3 table_{j,3}(2)];
            end
            for j=1:3
                latRow4=[latRow4 table_{j,4}(1)];
                lonRow4=[lonRow4 table_{j,4}(2)];
            end
            
            
            plot(lonRow1, latRow1, '.r', 'MarkerSize', 20)
            hold on
            plot(lonRow2, latRow2, '.b', 'MarkerSize', 20)
            hold on
            plot(lonRow3, latRow3, '.g', 'MarkerSize', 20)
            hold on
            plot(lonRow4, latRow4, '.r', 'MarkerSize', 20)
            hold on
            
            plot_google_map('MapScale', 0,'MapType','satellite')
        end
        function printGoogleObs(pointX_,pointY_)
            latRow1=pointX_;
            lonRow1=pointY_;
            
            plot(lonRow1, latRow1,'.r', 'MarkerSize', 10)
            hold on
            
            plot_google_map('MapScale', 0,'MapType','satellite')
        end
        function d1km=lldistkm(latlon1,latlon2)
            
            %
            %when applied to the Earth, which is not a perfect sphere:
            %the "Earth radius" R varies from 6356.752 km at the poles to 6378.137 km at the equator.
            %
            
            radius=6371;
            lat1=latlon1(1)*pi/180;
            lat2=latlon2(1)*pi/180;
            lon1=latlon1(2)*pi/180;
            lon2=latlon2(2)*pi/180;
            deltaLat=lat2-lat1;
            deltaLon=lon2-lon1;
            a=sin((deltaLat)/2)^2 + cos(lat1)*cos(lat2) * sin(deltaLon/2)^2;
            c=2*atan2(sqrt(a),sqrt(1-a));
            d1km=radius*c;    %Haversine distance
            
        end
        function indexes_ = getObstacleIndexes(LinesWithObs_,Lines_)
            
            % printGoogleObs(pointX_,pointY_);
            % printGoogle(table_);
            
            %LinesWithObs_[WHICH_LINE OBS_X OBS_Y;] the semicolon means that each
            %line of this array is 1 obstacle
            
            indexes_ = [];
            %disp(LinesWithObs_(1,2));
            % this one returns the firstrow-second element
            [colLength,row]=size(LinesWithObs_);
            
            for i=1:colLength
                WhichLineWithObstacle = LinesWithObs_(i,1);
                middle = [((Lines_{WhichLineWithObstacle}.startX + Lines_{WhichLineWithObstacle}.endX )/2) ((Lines_{WhichLineWithObstacle}.endY + Lines_{WhichLineWithObstacle}.startY )/2)];
                middledist = Functions.lldistkm(middle,[LinesWithObs_(i,2) LinesWithObs_(i,3)]);
                top= [Lines_{WhichLineWithObstacle}.startX Lines_{WhichLineWithObstacle}.startY];
                bottom = [Lines_{WhichLineWithObstacle}.endX Lines_{WhichLineWithObstacle}.endY];
                topdist = Functions.lldistkm(top,[LinesWithObs_(i,2) LinesWithObs_(i,3)]);
                bottomdist = Functions.lldistkm(bottom,[LinesWithObs_(i,2) LinesWithObs_(i,3)]);
                dists=[topdist middledist bottomdist];
                mindist = min(dists);
                if (mindist == topdist)
                    indexes_ = [indexes_ LinesWithObs_(i,1)*3];
                elseif (mindist == middledist)
                    indexes_ = [indexes_ LinesWithObs_(i,1)*2];
                else
                    indexes_ = [indexes_ (LinesWithObs_(i,1)*3)-2];
                end
            end
            
        end
        function myindex = getGlobalIndex(pointX_,pointY_,table_)
            [rows,cols]=size(table_);
            
            % TODO->ADD OFFSET EXISTANCE INTO ANY NODE.IF NOT A VALID NODE,POP A
            % MESSAGE
            %      for j=1:cols
            %         for i=1:3
            %             poly1=polyshape([pointX_-offset pointX_-offset  pointX_+offset pointX_+offset],[pointY_+offset pointY_-offset pointY_-offset pointY_+offset]);
            %             line=[table_(j){1} obj.startY ; obj.endX obj.endY];
            %             [in,out]=intersect(poly1,line);
            %             if (isempty(in) )
            %                 disp('not an obstacle')
            %             else
            %                 disp('obstacle')
            %             end
            %         end
            %      end
            
            %------------------
            %table[row,col]
            %------------------
            
            %add zeros to the middle row in order to replace the NULL string
            for i=1:cols
                table_{2,i}=[0 0];
            end
            %fill up the middle nodes with the middle coord of line
            for i=1:cols
                table_{2,i}(1) = (table_{1,i}(1) + table_{3,i}(1)) /2;
                table_{2,i}(2) = (table_{1,i}(2) + table_{3,i}(2)) /2;
            end
            
            tmpP1 = [pointX_ pointY_];
            tmpP2 = [table_{1,1}(1) table_{1,1}(2)];
            mindist = Functions.lldistkm(tmpP1,tmpP2);
            minj=-1;
            mini=-1;
            
            for j=1:cols
                for i=1:3
                    tmpP2 = [table_{i,j}(1) table_{i,j}(2)];
                    tmpdist = Functions.lldistkm(tmpP1,tmpP2 );
                    if (tmpdist <= mindist)
                        mindist = tmpdist;
                        minj=j;
                        mini=i;
                    end
                    
                end
            end
            
            if (mini==3)        %bottom
                if(minj ~= 1)
                    myindex = (minj*3)-2;
                else
                    myindex = 1;
                end
            elseif (mini==2)    %middle
                myindex = (minj*3)-1;
            else                %top
                if (minj ~= cols)
                    myindex = minj*3;
                else
                    myindex = cols*3;
                end
            end
            
        end
    end
end

