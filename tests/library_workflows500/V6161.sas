/* New workflow V6161; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6161i;
length gene $80;
gene='gene01';raw_c1=-11.87;raw_c2=-22.8;raw_c3=62.27;output;
gene='gene02';raw_c1=60.26;raw_c2=12.33;raw_c3=61.4;output;
gene='gene03';raw_c1=-27.61;raw_c2=65.46;raw_c3=47.53;output;
gene='gene04';raw_c1=22.52;raw_c2=-20.41;raw_c3=-17.34;output;
run;
%n26_Rename_Del_Rgx4All_Vars(indsd=work.v6161i,Rgx=raw_);
data v6161m(keep=metric value);set v6161i;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6161i out=v6161s(keep=name type) noprint;run;data v6161s(keep=metric value);set v6161s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6161m data=v6161s;run;

data v6161m;set v6161m;format value best32.;run;
proc export data=v6161m outfile="%sysfunc(pathname(work))/V6161.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6161;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6161:;quit;
