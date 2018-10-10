function[names, isdirs] = openfileGetfilenames(directory,filter)

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
