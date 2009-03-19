function test_nc_getbuffer ( ncfile )
% TEST_NC_GETBUFFER
%
% Relies upon nc_addvar, nc_addnewrecs, nc_add_dimension
%
% test 1:  no input arguments, should fail
% test 2:  2 inputs, 2nd is not a cell array, should fail
% test 3:  3 inputs, 2nd and 3rd are not numbers, should fail
% test 4:  4 inputs, 2nd is not a cell array, should fail
% test 5:  4 inputs, 3rd and 4th are not numbers, should fail
% test 6:  1 input, 1st is not a file, should fail.
% test 7:  5 inputs, should fail
% test 8:  1 input, an empty netcdf with no variables, should fail
%          because no record variable was found
%
% test 9:  1 input, 3 record variables. Should succeed.
% test 10:  2 inputs, same netcdf file as 9.  Restrict output to two
%           of the variables.  Should succeed.
% test 11:  3 inputs, same netcdf file as 9.  Restrict output to given
%           start:start+count range, which is given as valid.
% test 12:  3 inputs, same netcdf file as 9.  Restrict output to given
%           start:start+count range.  Start is negative number.  Result 
%           should be the last few "count" records.
% test 13:  3 inputs, same netcdf file as 9.  Restrict output to given
%           start:start+count range.  count is negative number.  Result 
%           should be everything from start to "end - count"
% test 14:  4 inputs.  Otherwise the same as test 11.


fprintf ( 1, '%s:  starting...\n', upper ( mfilename ) );



testid = 'Test 1';
fprintf ( 1, '%s.\n', testid );
[nb, status] = nc_getbuffer;
if ( status >= 0 )
	msg = sprintf ( '%s:  %s succeeded when it should have failed.\n', mfilename, testid );
	error ( msg );
end
fprintf ( 1, '%s:  passed.\n', testid );




testid = 'Test 2';
fprintf ( 1, '%s.\n', testid );
[nb, status] = nc_getbuffer ( ncfile, 1 );
if ( status >= 0 )
	msg = sprintf ( '%s:  %s succeeded when it should have failed.\n', mfilename, testid );
	error ( msg );
end
fprintf ( 1, '%s:  passed.\n', testid );




testid = 'Test 3';
fprintf ( 1, '%s.\n', testid );
[nb, status] = nc_getbuffer ( ncfile, 'a', 'b' );
if ( status >= 0 )
	msg = sprintf ( '%s:  %s succeeded when it should have failed.\n', mfilename, testid );
	error ( msg );
end
fprintf ( 1, '%s:  passed.\n', testid );





testid = 'Test 4';
fprintf ( 1, '%s.\n', testid );
[nb, status] = nc_getbuffer ( ncfile, 1, 1, 2 );
if ( status >= 0 )
	msg = sprintf ( '%s:  %s succeeded when it should have failed.\n', mfilename, testid );
	error ( msg );
end
fprintf ( 1, '%s:  passed.\n', testid );





testid = 'Test 5';
fprintf ( 1, '%s.\n', testid );
[nb, status] = nc_getbuffer ( ncfile, cell(1), 'a', 'b' );
if ( status >= 0 )
	msg = sprintf ( '%s:  %s succeeded when it should have failed.\n', mfilename, testid );
	error ( msg );
end
fprintf ( 1, '%s:  passed.\n', testid );





testid = 'Test 6';
fprintf ( 1, '%s.\n', testid );
[nb, status] = nc_getbuffer ( 5 );
if ( status >= 0 )
	msg = sprintf ( '%s:  %s succeeded when it should have failed.\n', mfilename, testid );
	error ( msg );
end
fprintf ( 1, '%s:  passed.\n', testid );





testid = 'Test 7';
fprintf ( 1, '%s.\n', testid );
[nb, status] = nc_getbuffer ( ncfile, cell(1), 3, 4, 5 );
if ( status >= 0 )
	msg = sprintf ( '%s:  %s succeeded when it should have failed.\n', mfilename, testid );
	error ( msg );
end
fprintf ( 1, '%s:  passed.\n', testid );





%
% empty file case
create_empty_file ( ncfile );
testid = 'Test 8';
fprintf ( 1, '%s.\n', testid );
[nb, status] = nc_getbuffer ( ncfile );
if ( status >= 0 )
	msg = sprintf ( '%s:  %s: succeeded when it should have failed.\n', mfilename, testid );
	error ( msg );
end
fprintf ( 1, '%s:  passed.\n', testid );




%
% baseline case
create_empty_file ( ncfile );
testid = 'Test 9';
fprintf ( 1, '%s.\n', testid );
status = nc_add_dimension ( ncfile, 'ocean_time', 0 );
status = nc_add_dimension ( ncfile, 'x', 2 );

clear varstruct;
varstruct.Name = 'x';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'x' };
nc_addvar ( ncfile, varstruct );

clear varstruct;
varstruct.Name = 'ocean_time';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'ocean_time' };
nc_addvar ( ncfile, varstruct );

clear varstruct;
varstruct.Name = 't1';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'ocean_time' };
nc_addvar ( ncfile, varstruct );

clear varstruct;
varstruct.Name = 't2';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'ocean_time' };
nc_addvar ( ncfile, varstruct );

clear varstruct;
varstruct.Name = 't3';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'ocean_time' };
nc_addvar ( ncfile, varstruct );

%
% write ten records
x = [0:9]';
b.ocean_time = x;
b.t1 = x;
b.t2 = 1./(1+x);
b.t3 = x.^2;
[nb,status] = nc_addnewrecs ( ncfile, b, 'ocean_time' );
if ( status < 0 )
	msg = sprintf ( '%s:  nc_addnewrecs failed on %s.\n', mfilename, ncfile );
	error ( msg );
end


[nb, status] = nc_getbuffer ( ncfile );
if ( status < 0 )
	msg = sprintf ( '%s:  %s: failed when it should have succeeded.\n', mfilename, testid );
	error ( msg );
end

%
% should have 4 fields
f = fieldnames(nb);
n = length(f);
if n ~= 4
	msg = sprintf ( '%s:  %s: output buffer did not have 4 fields.\n', mfilename, testid );
	error ( msg );
end
for j = 1:4
	fname = f{j};
	d = getfield ( nb, fname );
	if ( length(d) ~= 10 )
		msg = sprintf ( '%s:  %s: length of field %s in the output buffer was not 10.\n', mfilename, testid );
		error ( msg );
	end
end
fprintf ( 1, '%s:  passed.\n', testid );





%
% restrict variables
testid = 'Test 10';
fprintf ( 1, '%s.\n', testid );

[nb, status] = nc_getbuffer ( ncfile, {'t1', 't2'} );
if ( status < 0 )
	msg = sprintf ( '%s:  %s: failed when it should have succeeded.\n', mfilename, testid );
	error ( msg );
end

%
% should have 2 fields
f = fieldnames(nb);
n = length(f);
if n ~= 2
	msg = sprintf ( '%s:  %s: output buffer did not have 2 fields.\n', mfilename, testid );
	error ( msg );
end
for j = 1:2
	fname = f{j};
	d = getfield ( nb, fname );
	if ( length(d) ~= 10 )
		msg = sprintf ( '%s:  %s: length of field %s in the output buffer was not 10.\n', mfilename, testid );
		error ( msg );
	end
end
fprintf ( 1, '%s:  passed.\n', testid );






%
% restrict range
testid = 'Test 11';
fprintf ( 1, '%s.\n', testid );

[nb, status] = nc_getbuffer ( ncfile, 5, 3 );
if ( status < 0 )
	msg = sprintf ( '%s:  %s: failed when it should have succeeded.\n', mfilename, testid );
	error ( msg );
end

%
% should have 4 fields
f = fieldnames(nb);
n = length(f);
if n ~= 4
	msg = sprintf ( '%s:  %s: output buffer did not have 4 fields.\n', mfilename, testid );
	error ( msg );
end
for j = 1:n
	fname = f{j};
	d = getfield ( nb, fname );
	if ( length(d) ~= 3 )
		msg = sprintf ( '%s:  %s: length of field %s in the output buffer was not 10.\n', mfilename, testid );
		error ( msg );
	end
end

%
% t1 should be [5 6 7]
if any ( nb.t1 - [5 6 7]' )
	msg = sprintf ( '%s:  %s: t1 was not what we thought it should be.\n', mfilename, testid );
	error ( msg );
end
fprintf ( 1, '%s:  passed.\n', testid );







%
% start is negative
testid = 'Test 12';
fprintf ( 1, '%s.\n', testid );

[nb, status] = nc_getbuffer ( ncfile, -1, 3 );
if ( status < 0 )
	msg = sprintf ( '%s:  %s: failed when it should have succeeded.\n', mfilename, testid );
	error ( msg );
end

%
% should have 4 fields
f = fieldnames(nb);
n = length(f);
if n ~= 4
	msg = sprintf ( '%s:  %s: output buffer did not have 4 fields.\n', mfilename, testid );
	error ( msg );
end
for j = 1:n
	fname = f{j};
	d = getfield ( nb, fname );
	if ( length(d) ~= 3 )
		msg = sprintf ( '%s:  %s: length of field %s in the output buffer was not 10.\n', mfilename, testid );
		error ( msg );
	end
end

%
% t1 should be [7 8 9]
if any ( nb.t1 - [7 8 9]' )
	msg = sprintf ( '%s:  %s: t1 was not what we thought it should be.\n', mfilename, testid );
	error ( msg );
end
fprintf ( 1, '%s:  passed.\n', testid );







%
% count is negative
testid = 'Test 13';
fprintf ( 1, '%s.\n', testid );

[nb, status] = nc_getbuffer ( ncfile, 5, -1 );
if ( status < 0 )
	msg = sprintf ( '%s:  %s: failed when it should have succeeded.\n', mfilename, testid );
	error ( msg );
end

%
% should have 4 fields
f = fieldnames(nb);
n = length(f);
if n ~= 4
	msg = sprintf ( '%s:  %s: output buffer did not have 4 fields.\n', mfilename, testid );
	error ( msg );
end
for j = 1:n
	fname = f{j};
	d = getfield ( nb, fname );
	if ( length(d) ~= 5 )
		msg = sprintf ( '%s:  %s: length of field %s in the output buffer was not 10.\n', mfilename, testid );
		error ( msg );
	end
end

%
% t1 should be [5 6 7 8 9]
if any ( nb.t1 - [5 6 7 8 9]' )
	msg = sprintf ( '%s:  %s: t1 was not what we thought it should be.\n', mfilename, testid );
	error ( msg );
end
fprintf ( 1, '%s:  passed.\n', testid );







%
% count is negative
testid = 'Test 14';
fprintf ( 1, '%s.\n', testid );

[nb, status] = nc_getbuffer ( ncfile, {'t1', 't2' }, 5, -1 );
if ( status < 0 )
	msg = sprintf ( '%s:  %s: failed when it should have succeeded.\n', mfilename, testid );
	error ( msg );
end

%
% should have 2 fields
f = fieldnames(nb);
n = length(f);
if n ~= 2
	msg = sprintf ( '%s:  %s: output buffer did not have 2 fields.\n', mfilename, testid );
	error ( msg );
end
for j = 1:n
	fname = f{j};
	d = getfield ( nb, fname );
	if ( length(d) ~= 5 )
		msg = sprintf ( '%s:  %s: length of field %s in the output buffer was not 10.\n', mfilename, testid );
		error ( msg );
	end
end

%
% t1 should be [5 6 7 8 9]
if any ( nb.t1 - [5 6 7 8 9]' )
	msg = sprintf ( '%s:  %s: t1 was not what we thought it should be.\n', mfilename, testid );
	error ( msg );
end
fprintf ( 1, '%s:  passed.\n', testid );







fprintf ( 1, '%s:  all tests succeeded...\n', upper ( mfilename ) );
return




