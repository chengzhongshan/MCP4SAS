/* New workflow V6177; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6177i;
length gene $80;
gene='gene01';raw_c1=28.13;raw_c2=66.19999999999999;raw_c3=38.27;raw_c4=51.34;output;
gene='gene02';raw_c1=-27.74;raw_c2=59.33;raw_c3=20.400000000000002;raw_c4=70.47;output;
gene='gene03';raw_c1=-16.61;raw_c2=63.46;raw_c3=19.53;raw_c4=61.6;output;
gene='gene04';raw_c1=60.52;raw_c2=54.59;raw_c3=-22.34;raw_c4=17.73;output;
gene='gene05';raw_c1=-3.35;raw_c2=35.72;raw_c3=65.79;raw_c4=31.86;output;
gene='gene06';raw_c1=-0.21999999999999997;raw_c2=-15.15;raw_c3=-11.08;raw_c4=45.99;output;
run;
%n26_Rename_Del_Rgx4All_Vars(indsd=work.v6177i,Rgx=raw_);
data v6177m(keep=metric value);set v6177i;length metric $120;array measured[*] c1 c2 c3 c4;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6177i out=v6177s(keep=name type) noprint;run;data v6177s(keep=metric value);set v6177s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6177m data=v6177s;run;

data v6177m;set v6177m;format value best32.;run;
proc export data=v6177m outfile="%sysfunc(pathname(work))/V6177.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6177;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6177:;quit;
