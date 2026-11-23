/* Portable repair of Zhongshan Cheng's macroparas utility.
   Read macro source, without including/executing the inspected programs.
   Existing keyword parameters are retained; path is an additional output column.
   dir= accepts one unquoted existing directory or quoted space-separated paths.
   Blank dir uses MCP4SAS_MACRO_DIR (macro variable/environment) when set, then
   the SAS autocall directory containing macroparas.sas, otherwise
   HOME/Macros. Automatic discovery skips UNC paths; pass an explicit dir to use
   a network share intentionally. No personal/network locations are hard-coded.
*/
%macro macroparas(macrorgx=.,dir=,verbose=0,IsSASOnDemand=0,
                  numlines2print=10000,output_macropara_dsd=Macro_paras,print_outdsd=0);
%local _mpid _mpfiles _mppreview _mpvalid _mpregex _mpcount;
%let _mpid=%substr(%sysfunc(compress(%sysfunc(uuidgen()),-)),1,12);
%let _mpfiles=_mp&_mpid.f;
%let _mppreview=_mp&_mpid.p;
%let _mpvalid=0;
%let _mpregex=0;
%let _mpcount=0;

/* Validate the output name before using it as generated SAS syntax. */
data _null_;
 length target $100;
 target=symget('output_macropara_dsd');
 valid=prxmatch('/^([A-Za-z_][A-Za-z0-9_]{0,7}\.)?[A-Za-z_][A-Za-z0-9_]{0,31}$/',strip(target))>0;
 call symputx('_mpvalid',valid,'L');
 if not valid then put 'ERROR: MACROPARAS_INVALID_OUTPUT: use a V7 one- or two-level dataset name.';
run;
%if not &_mpvalid %then %return;

/* Replace an old result immediately, including for empty/error searches. */
data &output_macropara_dsd;
 length macro $500 macro_paras $32767 path $4096;
 call missing(macro,macro_paras,path);
 stop;
run;

data work.&_mpfiles(keep=path);
 length directories raw expanded physical rawentry directory firstdir path home $4096 entry $256
        dirref fileref $8 expression $32767;
 call missing(of _character_);
 directories=symget('dir');
 if missing(directories) and symexist('MCP4SAS_MACRO_DIR') then directories=symget('MCP4SAS_MACRO_DIR');
 if missing(directories) and sysexist('MCP4SAS_MACRO_DIR') then directories=sysget('MCP4SAS_MACRO_DIR');
 if missing(directories) then do;
   /* SASAUTOS reflects the caller's configured macro library, not another PC. */
   raw=strip(getoption('sasautos'));
   if substr(raw,1,1)='(' then raw=substr(raw,2,max(1,lengthn(raw)-2));
   /* SASAUTOS can name a fileref containing a concatenated path list, rather
      than a literal directory. Expand it before looking for macroparas.sas. */
   expanded='';
   do token=1 to countw(raw,' ','q');
     rawentry=scan(raw,token,' ','q');
     directory=dequote(rawentry);
     physical='';
     if lengthn(directory)<=8 and nvalid(directory,'V7') then do;
       if fileref(directory)=0 then physical=strip(pathname(directory));
     end;
     if not missing(physical) then do;
       if substr(physical,1,1)='(' then physical=substr(physical,2,max(1,lengthn(physical)-2));
       /* A single physical path may contain spaces without enclosing quotes. */
       else if substr(physical,1,1) not in ("'",'"') then physical=quote(trim(physical));
       expanded=catx(' ',expanded,physical);
     end;
     else expanded=catx(' ',expanded,rawentry);
   end;
   raw=expanded;
   do token=1 to countw(raw,' ','q');
     directory=dequote(scan(raw,token,' ','q'));
     if missing(directory) or substr(directory,1,2)='\\' or substr(directory,1,2)='//' then continue;
     rc=filename(dirref,strip(directory));
     if rc ne 0 then continue;
     handle=dopen(dirref);
     if handle>0 then do;
       if missing(firstdir) then firstdir=directory;
       rc=filename(fileref,cats(directory,'/macroparas.sas'));
       found=(rc=0 and fexist(fileref));
       if not missing(fileref) then rc=filename(fileref);
       rc=dclose(handle);
       if found then directories=directory;
     end;
     if not missing(dirref) then rc=filename(dirref);
     if not missing(directories) then leave;
   end;
   if missing(directories) then do;
     home=pathname('HOME');
     if substr(home,1,2) ne '\\' and substr(home,1,2) ne '//' then directories=cats(home,'/Macros');
     else directories=firstdir;
   end;
 end;
 if missing(directories) then do;
   put 'NOTE: MACROPARAS_NO_DIRECTORY: supply dir= for the library to inspect.';
   stop;
 end;
 expression=cats('/',tranwrd(symget('macrorgx'),'/','\/'),'/i');
 regex=prxparse(expression);
 if missing(regex) then do;
   put 'ERROR: MACROPARAS_INVALID_REGEX: invalid macrorgx.';
   stop;
 end;
 call symputx('_mpregex',1,'L');
 /* A whole existing path containing spaces is one directory. Quoted lists
    remain supported for callers who intentionally inspect several libraries. */
 whole=0; rc=1;
 if substr(strip(directories),1,1) not in ("'",'"') then rc=filename(dirref,strip(directories));
 if rc=0 then do;
   handle=dopen(dirref);
   if handle>0 then do; whole=1; rc=dclose(handle); end;
 end;
 if not missing(dirref) then rc=filename(dirref);
 do token=1 to ifn(whole,1,countw(directories,' ','q'));
   if whole then directory=directories;
   else directory=dequote(scan(directories,token,' ','q'));
   rc=filename(dirref,strip(directory));
   if rc ne 0 then continue;
   handle=dopen(dirref);
   if handle<=0 then do;
     put 'NOTE: MACROPARAS_DIRECTORY_SKIPPED: ' directory;
     rc=filename(dirref);
     continue;
   end;
   do member=1 to dnum(handle);
     entry=dread(handle,member);
     if not prxmatch('/\.sas$/i',strip(entry)) or not prxmatch(regex,strip(entry)) then continue;
     path=cats(directory,'/',entry);
     rc=filename(fileref,strip(path));
     child=0;
     if rc=0 then child=dopen(fileref);
     if child>0 then rc=dclose(child);
     else if rc=0 and fexist(fileref) then output;
     if not missing(fileref) then rc=filename(fileref);
   end;
   rc=dclose(handle);
   rc=filename(dirref);
 end;
 call prxfree(regex);
run;

%if not &_mpregex %then %goto finish;
proc sort data=work.&_mpfiles nodupkey; by path; run;

data &output_macropara_dsd(keep=macro macro_paras path)
     work.&_mppreview(keep=path line_no Macro_Info);
 set work.&_mpfiles;
 length macro $500 macro_paras header line clean Macro_Info $32767
        expected $256 ref $8 ch next quote hquote $1;
 expected=scan(scan(path,-1,'/\'),1,'.');
 rc=filename(ref,strip(path));
 if rc ne 0 then do; put 'ERROR: MACROPARAS_UNREADABLE_SOURCE: ' path; delete; end;
 fid=fopen(ref,'I',32767,'V');
 if fid<=0 then do;
   put 'ERROR: MACROPARAS_UNREADABLE_SOURCE: ' path;
   rc=filename(ref); delete;
 end;
 active=0; found=0; block=0; statement_comment=0; quote=''; hquote='';
 header=''; hlen=0; depth=0; line_no=0; failed=0;
 declaration=prxparse('/^\s*%macro\s+([A-Za-z_][A-Za-z0-9_]*)\b/i');
 do while(fread(fid)=0);
   line=''; rc=fget(fid,line,32767); line_no+1;
   if line_no<=input(symget('numlines2print'),best32.) then do;
     Macro_Info=line;
     /* ODS replaces an empty character cell with NBSP, which SAS does not
        accept as a blank program line when pasted. A tab is real SAS
        whitespace and keeps an empty source line visually empty. */
     if missing(Macro_Info) then Macro_Info='09'x;
     output work.&_mppreview;
   end;
   if found then do;
     if line_no>=input(symget('numlines2print'),best32.) then leave;
     continue;
   end;
   clean=''; clen=0;
   /* Remove comments before deciding where a declaration ends. Semicolons and
      parentheses in explanatory comments must not truncate its parameters. */
   do col=1 to lengthn(line);
     ch=char(line,col); next=char(line,col+1);
     if block then do;
       if ch='*' and next='/' then do; block=0; col+1; end;
       continue;
     end;
     if statement_comment then do;
       if ch=';' then statement_comment=0;
       continue;
     end;
     if quote ne '' then do;
       clen+1; substr(clean,clen,1)=ch;
       if ch=quote then do;
         if next=quote then do; clen+1; substr(clean,clen,1)=next; col+1; end;
         else quote='';
       end;
       continue;
     end;
     if ch='/' and next='*' then do; block=1; col+1; continue; end;
     if ch='%' and next='*' then do; statement_comment=1; col+1; continue; end;
     if not active and missing(clean) and ch='*' then do; statement_comment=1; continue; end;
     if ch in ("'",'"') then quote=ch;
     /* Preserve spaces in both SAS keywords and quoted default values. */
     clen+1; substr(clean,clen,1)=ch;
   end;
   clean=strip(clean);
   if not active then do;
     if not prxmatch(declaration,clean) then continue;
     call prxposn(declaration,1,start,size);
     macro=substr(clean,start,size);
     if upcase(macro) ne upcase(expected) then continue;
     active=1;
   end;
   /* Balanced parentheses and quoted text protect nested defaults such as
      where=%str(x in ('A','B')); a bare %macro name; is also supported. */
   do col=1 to lengthn(clean);
     ch=char(clean,col); next=char(clean,col+1);
     if hquote ne '' then do;
       if ch=hquote then do;
         if next=hquote then do; hlen+1; substr(header,hlen,1)=ch; hlen+1; substr(header,hlen,1)=next; col+1; continue; end;
         else hquote='';
       end;
     end;
     else do;
       if ch in ("'",'"') then hquote=ch;
       else if ch='(' then depth+1;
       else if ch=')' then depth+-1;
     end;
     if hlen>=32765 then do;
       put 'ERROR: MACROPARAS_HEADER_TOO_LONG: ' path; failed=1; leave;
     end;
     hlen+1; substr(header,hlen,1)=ch;
     if ch=';' and depth=0 and hquote='' then do;
       macro_paras=prxchange('s/^\s*%macro\s+//i',1,strip(header));
       output &output_macropara_dsd;
       found=1; leave;
     end;
   end;
   if failed then leave;
   if not found then do; hlen+1; substr(header,hlen,1)=' '; end;
   if found and line_no>=input(symget('numlines2print'),best32.) then leave;
 end;
 if not found then put 'WARNING: MACROPARAS_SIGNATURE_NOT_FOUND: ' path;
 rc=fclose(fid); rc=filename(ref); call prxfree(declaration);
run;
proc sql noprint;
 select count(*) into :_mpcount trimmed from &output_macropara_dsd;
quit;
%put MACROPARAS_MATCH_COUNT=&_mpcount;
%if &numlines2print>0 %then %do;
 /* Keep the original dark-blue source on a light-blue background. A single
    source column is copyable without stripping paths or line numbers. Hidden
    ordering columns retain every source line, including duplicates and demos. */
 proc report data=work.&_mppreview nowd missing noheader nocenter
   style(report)=[just=left frame=box rules=none cellspacing=0 cellpadding=3];
   column path line_no Macro_Info;
   define path / order order=data noprint;
   define line_no / order order=internal noprint;
   define Macro_Info / display
     /* ASIS=ON rewrites ordinary spaces as NBSP, including inside quoted SAS
        values. Match the original's left alignment and keep normal spaces. */
     style(column)=[just=left asis=off htmlstyle="white-space: pre" protectspecialchars=on
       font_face=arial font_weight=bold foreground=darkblue
       background=cxedf2f9 font_size=10pt];
   compute before path / style=[just=left foreground=darkblue
       background=white font_face=arial font_weight=bold font_size=10pt];
     line path $4096.;
   endcomp;
 run;
%end;
%if &print_outdsd=1 %then %do;
 proc print data=&output_macropara_dsd noobs; var macro macro_paras; run;
%end;
%finish:
proc datasets library=work nolist;
 delete &_mpfiles;
 %if %sysfunc(exist(work.&_mppreview)) %then %do;
 delete &_mppreview;
 %end;
quit;
/* PROC PRINT without DATA= must read the requested result, not a deleted
   temporary preview table. _LAST_= is a documented SAS system option. */
options _last_=&output_macropara_dsd;
%mend macroparas;
