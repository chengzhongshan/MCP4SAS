/* New workflow V6174; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6174i;
length gene $80;
gene='gene01';raw_c1=-24.87;raw_c2=-3.8000000000000003;raw_c3=-24.73;raw_c4=-22.66;raw_c5=68.41;raw_c6=50.480000000000004;output;
gene='gene02';raw_c1=19.26;raw_c2=25.330000000000002;raw_c3=-12.6;raw_c4=-2.5300000000000002;raw_c5=38.54;raw_c6=30.610000000000003;output;
gene='gene03';raw_c1=60.39;raw_c2=15.46;raw_c3=-15.469999999999999;raw_c4=16.6;raw_c5=39.67;raw_c6=61.74;output;
run;
%n26_Rename_Del_Rgx4All_Vars(indsd=work.v6174i,Rgx=raw_);
data v6174m(keep=metric value);set v6174i;length metric $120;array measured[*] c1 c2 c3 c4 c5 c6;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6174i out=v6174s(keep=name type) noprint;run;data v6174s(keep=metric value);set v6174s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6174m data=v6174s;run;

data v6174m;set v6174m;format value best32.;run;
proc export data=v6174m outfile="%sysfunc(pathname(work))/V6174.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6174;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6174:;quit;
