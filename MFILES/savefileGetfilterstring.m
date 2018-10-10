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
 