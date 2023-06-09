%% 

clearvars -except C5verts bone C5_temp 


baseMat =  [0.983779190519565,0.111377061025630,-0.140618827252835,-3.70057510934157;0.152136682022866,-0.102709030018099,0.983008283350560,-11.0370183496182;0.0950417502140134,-0.988456375076834,-0.117987542928153,1.53053669600982;0,0,0,1]

    C5_temp_verts = inv(baseMat) * C5verts;    
    C5_temp_verts2 = C5_temp_verts(1:3, :)';
    
    
f = figure('Position',[1 0 640 640],'Visible', 'on', 'HandleVisibility', 'on');
frame = 1;

warning('off', 'all')

% Translation loop


    for i = 1:100
        disp(i)
    %     baseMat(2,4) = C5toC6(2,4) + (i*0.1);


        C5_temp.Vertices(:,2) = C5_temp_verts2(:,2) + ((i-50)*0.06);

            %% plot

             set(0, 'currentfigure', f);  %# for figures

             colors = {[250 70 22]./256, [0 33 165]./265};

           % Fix the axes scaling, and set a nice view angle
           axis('off')
             subplot_tight(2,2,1,[])
             title("Frontal View");

               axis('off');
               grid('off');
               axis('equal');
               ax.Clipping = 'off';
                view([90 0]); % Frontal View

                 patch(bone.C6, 'FaceColor', colors{2}, ...
                     'EdgeColor', 'none', ...
                     'FaceLighting', 'gouraud', ...
                     'BackFaceLighting', 'reverselit', ...
                      'FaceAlpha', 0.8, ...
                      'AmbientStrength', 0.9); 

                 patch(C5_temp, 'FaceColor', colors{1}, ...
                     'EdgeColor', 'none', ...
                     'FaceLighting', 'gouraud', ...
                     'BackFaceLighting', 'reverselit',...
                      'FaceAlpha', 0.8, ...
                      'AmbientStrength', 0.9); 

                 %          Add camera lights
                 light('Position',[0 -1 0],'Style','infinite')
                 camlight('headlight');
                 material('dull');


                subplot_tight(2,2,2,[])
                   axis('off');
                   axis('equal');
                   ax.Clipping = 'off';
                   title("Angle: 0 Degrees")
                    view([90 90]); % Coronal View

                     patch(bone.C6, 'FaceColor', colors{2}, ...
                         'EdgeColor', 'none', ...
                         'FaceLighting', 'gouraud', ...
                         'BackFaceLighting', 'reverselit', ...
                          'FaceAlpha', 0.8, ...
                          'AmbientStrength', 0.9); 

                     patch(C5_temp, 'FaceColor', colors{1}, ...
                         'EdgeColor', 'none', ...
                         'FaceLighting', 'gouraud', ...
                         'BackFaceLighting', 'reverselit',...
                          'FaceAlpha', 0.8, ...
                          'AmbientStrength', 0.9); 

                               % Add camera lights
                     light('Position',[0 -1 0],'Style','infinite')
                     camlight('headlight');
                     material('dull');
                     
             subplot_tight(2,2,3,[])
                   title("Angle: -30 Degrees")
                   axis('off');
                   axis('equal');
                   ax.Clipping = 'off';
                    view([90 60]); % Lateral View
    
                     patch(bone.C6, 'FaceColor', colors{2}, ...
                         'EdgeColor', 'none', ...
                         'FaceLighting', 'gouraud', ...
                         'BackFaceLighting', 'reverselit', ...
                          'FaceAlpha', 0.8, ...
                          'AmbientStrength', 0.9); 
    
                     patch(C5_temp, 'FaceColor', colors{1}, ...
                         'EdgeColor', 'none', ...
                         'FaceLighting', 'gouraud', ...
                         'BackFaceLighting', 'reverselit',...
                          'FaceAlpha', 0.8, ...
                          'AmbientStrength', 0.9);
    
                               % Add camera lights
                     light('Position',[0 -1 0],'Style','infinite')
                     camlight('headlight');
                     material('dull');
    %     %              
                 subplot_tight(2,2,4,[])
                   title("Angle: -45 Degrees")
                   axis('off');
                   axis('equal');
                   ax.Clipping = 'off';
                    view([90 45]); % Lateral View
    
                     patch(bone.C6, 'FaceColor', colors{2}, ...
                         'EdgeColor', 'none', ...
                         'FaceLighting', 'gouraud', ...
                         'BackFaceLighting', 'reverselit', ...
                          'FaceAlpha', 0.8, ...
                          'AmbientStrength', 0.9); 
    
                     patch(C5_temp, 'FaceColor', colors{1}, ...
                         'EdgeColor', 'none', ...
                         'FaceLighting', 'gouraud', ...
                         'BackFaceLighting', 'reverselit',...
                          'FaceAlpha', 0.8, ...
                          'AmbientStrength', 0.9);
    
                               % Add camera lights
                     light('Position',[0 -1 0],'Style','infinite')
                     camlight('headlight');
                     material('dull');
        % %         


             if i == 1
                 hold on
                 axis('vis3d')
                 axis manual
             end

                animation(frame) = getframe(gcf);
                frameIdxs(frame) = i;
                frame = frame+1;

             if i ~= 100
                 % don't clear the screen at the last iteration
                 clf
             end
    %     %   save the videos every 400 frames as a safeguard   
    %         if mod(idx, 400) == 0
    %             vidOut(sac, animation, videoPath)
    %         end
    end
    
  %close(f)

%% Write Videos


function vidOut(sac_temp, animation, videoPath)
    % restructure SAC images
    sac_temp{2,end} = []; % add blank double arrays to become colormap field
    sacStruc = cell2struct(sac_temp, {'cdata', 'colormap'}, 1);

    renderPath = videoPath + "_render";
    sacPath = videoPath + "_SAC";

    vid_out = write_avi_animation(renderPath, animation);
    vid_out = write_avi_animation(sacPath, sacStruc);
end
    %close(gcf);
