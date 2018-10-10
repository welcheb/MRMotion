function savefileAction(action)

fig = gcbf;

ud = get(fig,'Userdata');
v = get(ud.hlistbox,'value');

switch action
    	case 0  % OK button callback
             
          if (ud.isdirs(v)==1) | strcmp( ud.names(v),'..'),
             	ud.directory = sprintf('%s/%s', ud.directory, char(ud.names(v)));
			[ud.names, ud.isdirs] = savefileGetfilenames(ud.directory, ud.filter);             	
			set(ud.hlistbox,'string',ud.names);
             	newname = get(ud.hfilenamebox,'string');
			match = strmatch(newname,ud.names,'exact');
			if ~isempty(match),
				set(ud.hlistbox,'value',match);
			else
				set(ud.hlistbox,'value',1);
			end			
			set(fig,'userdata',ud);
          else
			ud.filename = sprintf('%s/%s', ud.directory, char(ud.names(v)) );
			ud.done = 1;
             	set(fig,'Userdata',ud);
          end
  
    	case 1  % cancel button callback
 	  ud.done = 1;       
       set(fig,'Userdata',ud)       

	case 2 % Filter Box Change
		newstring = get(ud.hfilterbox,'string');
		[ud.filterstring, ud.filter] = savefileGetfilterstring(newstring);
		[ud.names, ud.isdirs] = savefileGetfilenames(ud.directory, ud.filter);
		set(ud.hfilterbox,'string',ud.filterstring);
		set(ud.hlistbox,'string',ud.names);
		newname = get(ud.hfilenamebox,'string');
		match = strmatch(newname,ud.names,'exact');
		if ~isempty(match),
			set(ud.hlistbox,'value',match);
		else
			set(ud.hlistbox,'value',1);
		end
		set(fig,'Userdata',ud); 
 
    case 3

       % Check to see if it is a double click
       if strcmp(get(gcf,'SelectionType'),'open')
          if (ud.isdirs(v)==1) | strcmp( ud.names(v),'..'),
             	ud.directory = sprintf('%s/%s', ud.directory, char(ud.names(v)) );		             	
			[ud.names, ud.isdirs] = savefileGetfilenames(ud.directory, ud.filter);
			set(ud.hlistbox,'string',ud.names);
             	newname = get(ud.hfilenamebox,'string');
			match = strmatch(newname,ud.names,'exact');
			if ~isempty(match),
				set(ud.hlistbox,'value',match);
			else
				set(ud.hlistbox,'value',1);	
			end
			set(fig,'userdata',ud);
          else
			ud.filename = sprintf('%s/%s', ud.directory, char(ud.names(v)) );
			ud.done = 1;
             	set(fig,'userdata',ud);
          end
  	  else
			if (ud.isdirs(v)==0),
				set(ud.hfilenamebox,'string',ud.names(v) );
			end
       end
   
    	case 4  % Filename Entered
		filenameboxentry = get(ud.hfilenamebox,'string');
		ud.filename = sprintf('%s/%s', ud.directory, char(filenameboxentry) );
		ud.done = 1;
		set(fig,'Userdata',ud);
end
