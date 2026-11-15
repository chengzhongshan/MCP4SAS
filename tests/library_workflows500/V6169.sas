/* New workflow V6169; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6169i;
length gene $80;
gene='gene01';raw_c1=14.13;raw_c2=5.2;raw_c3=-26.73;raw_c4=23.34;raw_c5=35.410000000000004;raw_c6=32.480000000000004;output;
gene='gene02';raw_c1=17.26;raw_c2=53.33;raw_c3=39.4;raw_c4=59.47;raw_c5=-27.459999999999997;raw_c6=37.61;output;
gene='gene03';raw_c1=-23.61;raw_c2=29.46;raw_c3=25.53;raw_c4=5.6;raw_c5=65.67;raw_c6=-22.259999999999998;output;
gene='gene04';raw_c1=54.52;raw_c2=46.59;raw_c3=-9.34;raw_c4=61.730000000000004;raw_c5=67.8;raw_c6=36.870000000000005;output;
gene='gene05';raw_c1=69.65;raw_c2=66.72;raw_c3=-14.209999999999999;raw_c4=30.86;raw_c5=45.93;raw_c6=27.0;output;
run;
%n26_Rename_Del_Rgx4All_Vars(indsd=work.v6169i,Rgx=raw_);
data v6169m(keep=metric value);set v6169i;length metric $120;array measured[*] c1 c2 c3 c4 c5 c6;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6169i out=v6169s(keep=name type) noprint;run;data v6169s(keep=metric value);set v6169s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6169m data=v6169s;run;

data v6169m;set v6169m;format value best32.;run;
proc export data=v6169m outfile="%sysfunc(pathname(work))/V6169.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6169;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6169:;quit;
