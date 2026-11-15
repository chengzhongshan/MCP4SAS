/* New workflow V6166; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6166i;
length gene $80;
gene='gene01';raw_c1=57.13;raw_c2=-19.8;raw_c3=-28.73;output;
gene='gene02';raw_c1=19.26;raw_c2=-23.669999999999998;raw_c3=-5.6000000000000005;output;
gene='gene03';raw_c1=1.3900000000000001;raw_c2=4.46;raw_c3=12.530000000000001;output;
gene='gene04';raw_c1=-8.48;raw_c2=42.59;raw_c3=-21.34;output;
gene='gene05';raw_c1=4.65;raw_c2=60.72;raw_c3=3.79;output;
gene='gene06';raw_c1=-9.22;raw_c2=66.85;raw_c3=60.92;output;
gene='gene07';raw_c1=61.91;raw_c2=54.98;raw_c3=42.05;output;
gene='gene08';raw_c1=-4.96;raw_c2=-26.89;raw_c3=-26.82;output;
gene='gene09';raw_c1=-28.83;raw_c2=70.24;raw_c3=63.31;output;
run;
%n26_Rename_Del_Rgx4All_Vars(indsd=work.v6166i,Rgx=raw_);
data v6166m(keep=metric value);set v6166i;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6166i out=v6166s(keep=name type) noprint;run;data v6166s(keep=metric value);set v6166s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6166m data=v6166s;run;

data v6166m;set v6166m;format value best32.;run;
proc export data=v6166m outfile="%sysfunc(pathname(work))/V6166.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6166;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6166:;quit;
