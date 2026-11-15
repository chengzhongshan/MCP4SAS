/* Test-only namespaced definition from Run_7Zip.sas; original SHA256 85758d2b1a93bd4c451a73afc09bd680366a79aae72367cc824271c0887d944e. */
%macro n26_Run_7Zip(Dir=,          /* Windows path of directory to examine*/
                 filename=,      /* Target for 7Z                      */   
                 Zip_Cmd= x,     /* add commands listed belowing, such as x to run with fullpath
																	                   and e to extract with filename without fullpath */
                 Extra_Cmd=-y,    /* add extra commands: assume Yes on all queries
																	                    -so >x.txt output data into a new file */
				outdir4file=			/*output uncompressed file into a new dir under the 1st macro var &Dir*/
                 ) ;
/*
Usage: 7z <command> [<switches>...] <archive_name> [<file_names>...]
       [<@listfiles...>]

<Commands>
  a: Add files to archive
  b: Benchmark
  d: Delete files from archive
  e: Extract files from archive (without using directory names)
  l: List contents of archive
  t: Test integrity of archive
  u: Update files to archive
  x: eXtract files with full paths
<Switches>
  -ai[r[-|0]]{@listfile|!wildcard}: Include archives
  -ax[r[-|0]]{@listfile|!wildcard}: eXclude archives
  -bd: Disable percentage indicator
  -i[r[-|0]]{@listfile|!wildcard}: Include filenames
  -m{Parameters}: set compression Method
  -o{Directory}: set Output directory
  -p{Password}: set Password
  -r[-|0]: Recurse subdirectories
  -scs{UTF-8 | WIN | DOS}: set charset for list files
  -sfx[{name}]: Create SFX archive
  -si[{name}]: read data from stdin
  -slt: show technical information for l (List) command
  -so: write data to stdout
  -ssc[-]: set sensitive case mode
  -ssw: compress shared files
  -t{Type}: Set type of archive
  -u[-][p#][q#][r#][x#][y#][z#][!newArchiveName]: Update options
  -v{Size}[b|k|m|g]: Create volumes
  -w[{path}]: assign Work directory. Empty path means a temporary directory
  -x[r[-|0]]]{@listfile|!wildcard}: eXclude filenames
  -y: assume Yes on all queries
*/

%local fullfilepath;
%let Dir=%sysfunc(prxchange(s/\\/\//,-1,&Dir));

%if %n26_direxist(&_gzdir_) %then %do;
	 %put your input dir is &Dir, which exists;
	%end;
	%else %do;
		%put your input dir is &Dir, but which does not exist;
		%abort 255;
%end;

%n26_chdir(&Dir);
%put output will be in the &Dir;
*Seems that the above code can not change dir successfully;

%let fullfilepath=%bquote(&Dir/&filename);
*%put fullfilepath is &fullfilepath;

%if %n26_direxist(&Dir/&outdir4file) %then %do;
 %put The dir containing uncompressed file is already there: &Dir/&outdir4file;
 %put We will not uncompress the file again;
%end;
%else %do;
options noxwait xsync;
*Note: multiple commands in windows need to be sparated by &;
*For simplicity, these commands can be split into multiple X commands, but sas failed to run;
*Note:  Only double quote but not single quote in windows can be used to escape path containing space;

%*Need to temporarily change the relative path as ".." due to in the following command the script goes into a subdir;
%*when the input does not have the typical Windows path, such as C:\, it is also necessary to update the macro var fullfilepath;
%if (%qsubstr(&fullfilepath,1,1)=. or not %sysfunc(prxmatch(/:\//,&fullfilepath))) %then %let fullfilepath=.&fullfilepath;

%if %length(&outdir4file)>0 %then %do;
*For unknown reason, the md command can not be added with /d in Windows 10;
*Need to force it to exit using & exit;
%put cd /d %str(%")&Dir%str(%") & md &outdir4file & cd /d %str(%")&outdir4file%str(%") & 7z &Zip_cmd %str(%")&fullfilepath%str(%") &Extra_Cmd & exit;
X cd /d %str(%")&Dir%str(%") & md &outdir4file & cd /d %str(%")&outdir4file%str(%") & 7z &Zip_cmd %str(%")&fullfilepath%str(%") &Extra_Cmd & exit;
%end;
%else %do;
X cd /d %str(%")&Dir%str(%") & 7z &Zip_cmd %str(%")&fullfilepath%str(%") &Extra_Cmd & exit;
%end;
%end;
/*%abort 255;*/
%put Uncompress the file finished!;
%mend n26_Run_7Zip ;
