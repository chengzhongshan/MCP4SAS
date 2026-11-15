/* New workflow V6162; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6162i;
length gene $80;
gene='gene01';raw_c1=43.13;raw_c2=-21.8;raw_c3=2.27;raw_c4=-26.66;output;
gene='gene02';raw_c1=-24.74;raw_c2=-6.67;raw_c3=27.400000000000002;raw_c4=-9.53;output;
gene='gene03';raw_c1=-8.61;raw_c2=54.46;raw_c3=67.53;raw_c4=55.6;output;
gene='gene04';raw_c1=-18.48;raw_c2=-0.41;raw_c3=36.660000000000004;raw_c4=67.72999999999999;output;
gene='gene05';raw_c1=2.65;raw_c2=-9.28;raw_c3=18.79;raw_c4=24.86;output;
run;
%n26_Rename_Del_Rgx4All_Vars(indsd=work.v6162i,Rgx=raw_);
data v6162m(keep=metric value);set v6162i;length metric $120;array measured[*] c1 c2 c3 c4;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6162i out=v6162s(keep=name type) noprint;run;data v6162s(keep=metric value);set v6162s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6162m data=v6162s;run;

data v6162m;set v6162m;format value best32.;run;
proc export data=v6162m outfile="%sysfunc(pathname(work))/V6162.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6162;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6162:;quit;
