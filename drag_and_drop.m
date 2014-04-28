function drag_and_drop(fig_handle, eventdata, target_handles)
% function drag_and_drop should be attached to WindowButtonMotionFcn
handles = guidata(fig_handle);
pos = get(fig_handle, 'currentpoint');  % get mouse location on figure
x = pos(1); y = pos(2);                 % assign locations to x and y
set(handles.lbl_x, 'string', ['x loc:' num2str(x)]); % update text for x loc
set(handles.lbl_y, 'string', ['y loc:' num2str(y)]); % update text for y loc

% going through each movable object

target_id = [];
% find out which one the mouse is on top of right now 
for i = 1:length(target_handles)
    % get position information of the uicontrol
    lbl_target = target_handles{i};
    bounds = get(lbl_target,'position');
    lx = bounds(1); ly = bounds(2);
    lw = bounds(3); lh = bounds(4);
    if (x >= lx && x <= (lx + lw) && y >= ly && y <= (ly + lh))
        target_id = i;
        break;
    end
end
for i = 1:length(target_handles)
    lbl_target = target_handles{i};
    if target_id == i 
        % set enable to off so that the whole static text field is hotspot
        set(lbl_target, 'enable', 'off');
        set(lbl_target, 'string', 'IN');
        set(lbl_target, 'backgroundcolor', 'red');
        set(lbl_target, 'ButtonDownFcn', @grab);
        setfigptr('hand', handles.fig_mouse);
    else
        % re-enable the uicontrol
        set(lbl_target, 'enable', 'on');
        set(lbl_target,'string', 'OUT');
        set(lbl_target, 'backgroundcolor', 'green');
    end
end
if isempty(target_id)
    setfigptr('arrow', handles.fig_mouse);
end

    function grab(target_handle, eventData)
        % to be attached to ButtonDownFcn of the uicontrol
        % change the shape of the pointer to closed hand
        setfigptr('closedhand', fig_handle);
        
        % computing x, y difference between pointer and uicontrol 
        % so that the movement can be in sync
        mouse_pos = get(fig_handle, 'currentpoint'); 
        lbl_target = target_handle;
        target_pos = get(lbl_target,'position');
        dx = mouse_pos(1) - target_pos(1);
        dy = mouse_pos(2) - target_pos(2);
        set(handles.lbl_last_action, 'string', ['Mouse pressed @ X: ', num2str(mouse_pos(1)), ', Y: ', num2str(mouse_pos(2))]);        
        % attach drag and release to WindowButtonMotionFcn and
        % WindowButtonUpFcn
        set(fig_handle,'WindowButtonMotionFcn', @drag);   
        set(fig_handle,'WindowButtonUpFcn',@release);
        
        function drag(fig_handle, eventData)
            % to be attached to WindowButtonMotionFcn
            % get mouse x,y location on figure
            mouse_pos = get(fig_handle, 'currentpoint'); 
            x = mouse_pos(1); y = mouse_pos(2); 
            set(handles.lbl_x, 'string', ['x loc:' num2str(x)]); 
            set(handles.lbl_y, 'string', ['y loc:' num2str(y)]); 
            set(handles.lbl_last_action, 'string', ['Mouse moved @ X: ', num2str(x), ', Y: ', num2str(y)]);            
            
            % get uicontrol width and height
            target_pos = get(lbl_target,'position');
            tw = target_pos(3); th = target_pos(4);
            % update uicontrol position based on the computed x,y locations
            target_pos = [x-dx, y-dy, tw, th];
            set(lbl_target,'position', target_pos);
            
        end
        
        function release(fig_handle, eventData)
            % to be attached to WindowButtonUpFcn
            % update pointer back to hand shape 
            setfigptr('hand', fig_handle);

            mouse_pos = get(fig_handle, 'currentpoint'); 
            x = mouse_pos(1); y = mouse_pos(2);            
            set(handles.lbl_last_action, 'string', ['Mouse released @ X: ', num2str(x), ', Y: ', num2str(y)]);            
            
            set(fig_handle, 'WindowButtonMotionFcn', {@drag_and_drop, target_handles});
            set(fig_handle, 'WindowButtonUpFcn', '');
            
        end % end of release function 
        
    end % end of grab function 

end % end of drag_and_drop function