function [filename] = savefile(directory,filterstring)

if nargin<1,
   ud.directory = '.';
else
   ud.directory = directory;
end

if nargin<2,
   filterstring = '*';
end	

	[ud.filterstring, ud.filter] = savefileGetfilterstring(filterstring);

	[ud.names, ud.isdirs] = savefileGetfilenames(ud.directory, ud.filter);

	% height extent per line of
    	% uicontrol text, in pixels (approximate)
	listsize = [160 300];
    	txtWt = 5;  
     txtHt = 20 ;
 	btnWt = 40;
	btnHt = 30;
	space = 25; 
    	fp = get(0,'defaultfigureposition');
    	w = 2*space+listsize(1);
    	h = 4*space+listsize(2) + 2*txtHt;
    	fp = [fp(1) fp(2)+fp(4)-h w h];  % keep upper left corner fixed

    	fig = figure(	'resize', 'off', 'position', fp, 'Visible', 'on', ...
				'windowstyle', 'modal', 'createfcn', '', 'numbertitle', 'off', ...
			   	'closerequestfcn','set(gcf,''userdata'',''cancel'')' );


    	uicontrol('style','text','string','Save File',...
           'horizontalalignment','left','units','pixels',...
           'position',[0 h-1.5*txtHt txtWt*15 txtHt]);  
	ud.hok_btn = uicontrol('style','pushbutton',...
      'string','Ok',...
      'position',[space space/2 btnWt btnHt],...
      'callback','savefileAction(0)');
    	ud.hcancel_btn = uicontrol('style','pushbutton',...
      'string','Cancel',...
      'position',[space+btnWt space/2 btnWt btnHt],...
      'callback','savefileAction(1)');
	uicontrol('style','text','string','Filter',...
           'horizontalalignment','left','units','pixels',...
           'position',[0 h-3*txtHt 5*txtWt txtHt]);
    	ud.hfilterbox = uicontrol('style','edit','horizontalalignment','left',...
      'position',[5*txtWt h-3*txtHt listsize(1) txtHt],...
      'string',ud.filterstring,...
      'backgroundcolor','w',...
      'max',1,...
      'tag','filterbox',...
      'callback','savefileAction(2)');
    	ud.hlistbox = uicontrol('style','listbox',...
      'position',[space 3*space listsize],...
      'string',ud.names,...
      'backgroundcolor','w',...
      'max',1,...
      'tag','listbox',...
      'value',1,...
      'callback','savefileAction(3)');
	ud.hfilenamebox = uicontrol('style','edit','horizontalalignment','left',...
      'position',[space 2*space listsize(1) txtHt ],...
      'string', ud.names(1),...
      'backgroundcolor','w',...
      'max',1,...
      'tag','filenamebox',...
      'value',1,...
      'callback','savefileAction(4)');

	ud.filename = '';
	ud.done = 0;
   	set(fig,'Userdata',ud);

	ud.done = 0;
	while ud.done==0,
		waitfor(fig,'Userdata');
		ud = get(fig,'Userdata');
		if ~isstruct(ud),
		   	filename = '';
			delete(fig);
		   	return;
		end
	end

	fid = fopen(ud.filename,'r');

	if fid==-1,
		filename = ud.filename;
	else
		question = sprintf('The file %s already exists.  Do you wish to replace it?', ud.filename);
		answer = questdlg(question,'Warning','YES','NO','');
		
		if strcmp(answer,'YES'),
			filename = ud.filename;
		else
			filename = '';
		end
	end

	delete(fig);

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

function[filterstring, filter] = savefileGetfilterstring(newstring)

		% Make sure it is one row
		newstring = newstring(1,:);

		if ~isempty(newstring),
			% REPLACE COMMAS WITH SPACES
			commas = find(newstring==',');
			newstring(commas)=' ';
		end

		% GET RID OF LEADING SPACES
		while newstring(1)==' ' & ~isempty(newstring) ,
			newstring = newstring(2:length(newstring));
		end

		filter = cell(0);
		if isempty(newstring),
			filter(1) = '*';
		else
			% TACK ON EXTRA SPACE AT END FOR LOOP PURPOSES
			newstring = [newstring ' '];
			spaces = find(newstring==' ');
			
			filter(1) = cellstr( newstring(1:(spaces(1)-1)) );		
			for n=1:(length(spaces)-1),
				start = spaces(n)+1;
				stop = spaces(n+1)-1;
				if length(start:stop)>1,
		  			filter = [filter cellstr(newstring(start:stop))];
				end
			end
		end

		filterstring = sprintf('%s', char(filter(1)) );
		for n=2:length(filter),
	  		filterstring = sprintf('%s, %s', filterstring, char(filter(n) ) );
		end
 
function[names, isdirs] = savefileGetfilenames(directory,filter)

	s = sprintf('d = dir(''%s'');', directory);
	eval(s);
	allnames = {d.name};
	for n=1:length( {d.isdir} ), allisdirs(n) = d(n).isdir; end;

	somenames=cell(0);
	for n=1:length(filter),
		s = sprintf('d = dir(''%s/%s'');', directory, char(filter(n)) );
    		eval(s);
		somenames  = [somenames {d.name}];
     end

	names = cell(0);
	isdirs = [];
	for n=1:length(allnames),	
		keep=0;

		match = strmatch(allnames(n),somenames,'exact');	

		if ~isempty(match),
			keep=1;
		end

		if strcmp( allnames(n),'.'),
		  	keep=1;
		  	allisdirs(n)=1;
		end

		if strcmp( allnames(n),'..'),
		  	keep=1;
			allisdirs(n)=1;
		end

		if allisdirs(n)==1,
		  keep=1;
		end

		if keep==1,
			names =  [names allnames(n)];
			isdirs = [isdirs allisdirs(n)];
		end

	end	
