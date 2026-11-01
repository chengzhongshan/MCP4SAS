package SAS_ODA_Directory_Cleanup;
use strict;
use warnings;

sub sas_literal {
    my ($value)=@_;
    $value =~ s/'/''/g;
    return "'$value'";
}

sub exact_name_patterns {
    my ($names)=@_;
    die "Directory names must be a nonempty array\n" unless ref($names) eq 'ARRAY' && @$names;
    my @patterns;
    for my $name (@$names) {
        die "Directory name must be nonempty\n" unless defined($name) && length($name);
        $name =~ s{/+\z}{};
        die "Directory name must be an immediate child basename\n"
            if !length($name) || $name =~ m{/|[\x00-\x1f%&,'"();\\]};
        die "Refusing protected directory name: $name\n"
            if $name eq '.' || $name eq '..' || $name eq '_DELETE_'
              || $name eq 'Macros' || $name eq '._mcp4sas_directory_cleanup_lock';
        my $quoted=$name;
        $quoted =~ s/([^A-Za-z0-9_-])/\\$1/g;
        push @patterns,"^${quoted}\$";
    }
    return \@patterns;
}

sub build_code {
    my (%args)=@_;
    my $parent=$args{parent}//'~';
    die "Directory parent must be ~, ~/path, or an absolute SAS ODA path\n"
        unless $parent =~ m{\A(?:~(?:/.*)?|/.*)\z};
    die "Unsafe directory parent\n" if $parent =~ m{(?:\A|/)\.\.?(/|\z)|[\x00-\x1f%&,'"();\\]};
    $parent =~ s{/+\z}{};
    die "Cannot scan the filesystem root for recursive deletion\n" unless length $parent;
    die "Provide either directory patterns or exact names, not both\n"
        if exists($args{patterns}) && exists($args{names});
    my $patterns=exists($args{names}) ? exact_name_patterns($args{names}) : $args{patterns};
    die "At least one nonempty directory regex is required\n" unless ref($patterns) eq 'ARRAY' && @$patterns;
    my (@init,@match);
    for my $index (0..$#$patterns) {
        my $pattern=$patterns->[$index];
        die "Directory regex must be nonempty and contain no control characters\n"
            unless defined($pattern) && length($pattern) && $pattern !~ /[\x00-\x1f]/;
        eval { qr/$pattern/ }; die "Invalid directory regex: $@" if $@;
        my ($expression,$backslashes)=('',0);
        for my $char (split //,$pattern) {
            $expression.='\\' if $char eq '/' && $backslashes%2==0;
            $expression.=$char;
            $backslashes=$char eq '\\' ? $backslashes+1 : 0;
        }
        my $literal=sas_literal("/(?:$expression)/");
        push @init,"re[$index+1]=prxparse($literal); if missing(re[$index+1]) then do; put 'ERROR: Invalid directory PRX expression'; call symputx('_mcp_ok',0,'L'); stop; end;";
        push @match,"prxmatch(re[$index+1],trim(name))";
    }
    my $code=<<'SAS';
/* MCP4SAS owned directory cleanup operation. Patterns match child basenames. */
%global _mcp4sas_delete_lock_owned;
%let _mcp4sas_delete_lock_owned=0;
%macro _mcp4sas_cleanup_dirs;
%local _mcp_parent _mcp_macro _mcp_count _mcp_name _mcp_i _mcp_ok _mcp_deleted;
%let _mcp_ok=1;
%let _mcp_count=0;
%let _mcp_deleted=0;
data work._mcp4sas_dirs;
 length parent path macro_path home $4096 name $256;
 parent=__PARENT__;
 home=pathname('HOME');
 if missing(home) then home=sysget('HOME');
 if parent='~' then parent=trim(home);
 else if substr(parent,1,2)='~/' then parent=cats(trim(home),substr(parent,2));
 if missing(parent) or parent='/' then do;
   put 'ERROR: Cannot resolve directory cleanup parent'; call symputx('_mcp_ok',0,'L'); stop;
 end;
 macro_path=cats(trim(home),'/Macros/Del_Dir_Recursive.sas');
 call symputx('_mcp_parent',parent,'L');
 call symputx('_mcp_macro',macro_path,'L');
 array re[__REGEX_COUNT__] _temporary_;
 __REGEX_INIT__
 rc=filename('mcpclpar',trim(parent));
 handle=dopen('mcpclpar');
 if handle=0 then do;
   put 'ERROR: Cannot open directory cleanup parent ' parent;
   call symputx('_mcp_ok',0,'L'); rc=filename('mcpclpar'); stop;
 end;
 count=0;
 do entry=1 to dnum(handle);
   name=dread(handle,entry);
   if __REGEX_MATCH__ then do;
     path=cats(trim(parent),'/',trim(name));
     rc=filename('mcpcldir',trim(path));
     child=dopen('mcpcldir');
     if child>0 then do;
       rc=dclose(child);
       if name in ('.','..','_DELETE_','Macros','._mcp4sas_directory_cleanup_lock') or
          prxmatch('/[\x00-\x1f]/',trim(name)) or
          indexc(trim(name),__UNSAFE_CHARS__)>0 then do;
         put 'ERROR: Refusing protected or macro-unsafe directory name ' path;
         call symputx('_mcp_ok',0,'L');
       end;
       else do;
         count+1; output;
         put 'MCP4SAS_DIRECTORY_MATCH: ' path;
       end;
     end;
     rc=filename('mcpcldir');
   end;
 end;
 rc=dclose(handle); rc=filename('mcpclpar');
 call symputx('_mcp_count',count,'L');
 do idx=1 to dim(re); call prxfree(re[idx]); end;
run;
%if &_mcp_ok ne 1 %then %return;
%if __DRY_RUN__ %then %do;
 %put MCP4SAS_DIRECTORY_SUMMARY: matched=&_mcp_count deleted=0 dry_run=1;
 %return;
%end;
%if &_mcp_count=0 %then %do;
 %put MCP4SAS_DIRECTORY_SUMMARY: matched=0 deleted=0 dry_run=0;
 %return;
%end;
/* The user's macro uses a fixed _DELETE_ staging name. Never reuse it. */
data _null_;
 length lockpath created $4096;
 lockpath=cats(symget('_mcp_parent'),'/._mcp4sas_directory_cleanup_lock');
 if fileexist(trim(lockpath)) then do;
   put 'ERROR: Directory cleanup lock already exists: ' lockpath;
   call symputx('_mcp_ok',0,'L');
 end;
 else do;
   created=dcreate('._mcp4sas_directory_cleanup_lock',symget('_mcp_parent'));
   if missing(created) then do;
     put 'ERROR: Cannot acquire directory cleanup lock'; call symputx('_mcp_ok',0,'L');
   end;
   else call symputx('_mcp4sas_delete_lock_owned',trim(created),'G');
 end;
run;
%if &_mcp_ok ne 1 %then %return;
%if %sysfunc(fileexist(%superq(_mcp_parent)/_DELETE_)) %then %do;
 %put ERROR: Refusing recursive deletion because &_mcp_parent/_DELETE_ already exists;
 %return;
%end;
%if not %sysfunc(fileexist(%superq(_mcp_macro))) %then %do;
 %put ERROR: Required remote macro file is missing: %superq(_mcp_macro);
 %return;
%end;
%include "&_mcp_macro";
%if not %sysmacexist(Del_Dir_Recursive) %then %do;
 %put ERROR: Del_Dir_Recursive was not defined by the remote include;
 %return;
%end;
%do _mcp_i=1 %to &_mcp_count;
 data _null_;
   set work._mcp4sas_dirs(firstobs=&_mcp_i obs=&_mcp_i);
   call symputx('_mcp_name',name,'L');
 run;
 %if %sysfunc(fileexist(%superq(_mcp_parent)/_DELETE_)) %then %do;
   %put ERROR: _DELETE_ staging directory appeared - stopping recursive deletion;
   %return;
 %end;
 %Del_Dir_Recursive(%superq(_mcp_parent),%superq(_mcp_name));
 data _null_;
   length path staging $4096;
   path=cats(symget('_mcp_parent'),'/',symget('_mcp_name'));
   staging=cats(symget('_mcp_parent'),'/_DELETE_');
   if fileexist(trim(path)) or fileexist(trim(staging)) then do;
     put 'ERROR: Recursive directory deletion could not be verified: ' path;
     call symputx('_mcp_ok',0,'L');
   end;
   else put 'MCP4SAS_DIRECTORY_DELETED: ' path;
 run;
 %if &_mcp_ok ne 1 %then %return;
 %let _mcp_deleted=%eval(&_mcp_deleted+1);
%end;
%put MCP4SAS_DIRECTORY_SUMMARY: matched=&_mcp_count deleted=&_mcp_deleted dry_run=0;
%mend;
%_mcp4sas_cleanup_dirs;
/* Also release our lock after an early return from a failed operation. */
data _null_;
 length lockpath $4096;
 lockpath=symget('_mcp4sas_delete_lock_owned');
 if lockpath ne '0' and not missing(lockpath) then do;
   rc=filename('mcpclock',trim(lockpath)); deleted=fdelete('mcpclock'); rc=filename('mcpclock');
   if deleted ne 0 then put 'ERROR: Could not release owned directory cleanup lock ' lockpath;
 end;
run;
%symdel _mcp4sas_delete_lock_owned;
%sysmacdelete _mcp4sas_cleanup_dirs;
SAS
    my %replace=(PARENT=>sas_literal($parent),REGEX_COUNT=>scalar(@$patterns),
        REGEX_INIT=>join("\n ",@init),REGEX_MATCH=>join(' or ',@match),DRY_RUN=>$args{dry_run}?1:0,
        UNSAFE_CHARS=>sas_literal(q{%&,'"();/}.'\\'));
    $code =~ s/__([A-Z_]+)__/$replace{$1}/ge;
    # A preview must not even trigger dependency loading of the delete macro.
    $code =~ s{/\* The user's macro uses.*?%mend;}{%mend;}s if $args{dry_run};
    return $code;
}
1;
