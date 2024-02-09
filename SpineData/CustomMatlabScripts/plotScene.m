function f = plotScene(f, mats, stls, frameMats)
         set(0, 'currentfigure', f);  %# for figures
    % plot the entire scene, including  
    % inputs: mats 
    %         stls (stack of stls, bone1, bone2, bead1, bead2, polhemus 1, polhemus 2)
    title = ["C5", "C6", "C5beads", "C6beads", "C5Pol", "C6Pol"];
%         f = figure();

        %ax.Clipping = 'off';
        %        view([0 +90]); % Coronal View
        %        camroll(180); % Coronal View
     colors = {[250 70 22]./256, [0 33 165]./265, [250 70 22]./256, [0 33 165]./265,[250 70 22]./256, [0 33 165]./265};
    
     stls{6} = stls{5};
     mats{5} = eye(4);
     mats{6} = eye(4);
     
     
for sp = 1:3

    if sp == 1
        subplot_tight(2,1,1,[]);
        view([90 0]); % Lateral View
    
    elseif sp == 2
        subplot_tight(2,2,3,[])
        view([90 90]);
    else
        subplot_tight(2,2,4,[])
        view([0,0]);
    end

            axis('off');
        axis('equal');
    
    for n = 1:6
        
        [F,V] = readSTL(stls{n});
        
        obj.(title(n)).Faces = F;
        obj.(title(n)).Vertices = V;
        
        verts.(title(n)) = [V.'; ones(1,length(V.'))];
        
        %% transformation
        tmp = [];
%         % center the object at 0,0,0
        verts.(title(n)) = inv(mats{n})*verts.(title(n));
%         % change it to its posed position
        tmp = (frameMats{n})*verts.(title(n));
%         tmp = verts.(title(n));
        
        obj.(title(n)).Vertices = tmp(1:3,:)';
        
        %% plot
        patch(obj.(title(n)), 'FaceColor', colors{n}, ...
             'EdgeColor', 'none') %, ...
%              'FaceLighting', 'gouraud', ...
%              'BackFaceLighting', 'reverselit')
        hold on
        
    end
    %                    % Add camera lights
          light('Position',[0 -1 0],'Style','infinite')
          camlight('headlight');
          material('dull');
end
        