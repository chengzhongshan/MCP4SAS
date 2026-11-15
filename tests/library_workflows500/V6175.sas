/* New workflow V6175; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6175i;
length gene $80;
gene='gene01';raw_c1=60.13;raw_c2=-13.799999999999999;output;
gene='gene02';raw_c1=7.26;raw_c2=-22.669999999999998;output;
gene='gene03';raw_c1=-14.61;raw_c2=35.46;output;
gene='gene04';raw_c1=-21.48;raw_c2=43.59;output;
run;
%n26_Rename_Del_Rgx4All_Vars(indsd=work.v6175i,Rgx=raw_);
data v6175m(keep=metric value);set v6175i;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6175i out=v6175s(keep=name type) noprint;run;data v6175s(keep=metric value);set v6175s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6175m data=v6175s;run;

data v6175m;set v6175m;format value best32.;run;
proc export data=v6175m outfile="%sysfunc(pathname(work))/V6175.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6175;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6175:;quit;
