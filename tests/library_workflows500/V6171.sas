/* New workflow V6171; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6171i;
length gene $80;
gene='gene01';raw_c1=-6.87;raw_c2=36.2;raw_c3=-8.729999999999999;output;
gene='gene02';raw_c1=34.26;raw_c2=51.33;raw_c3=8.4;output;
gene='gene03';raw_c1=1.3900000000000001;raw_c2=16.46;raw_c3=54.53;output;
gene='gene04';raw_c1=70.52;raw_c2=-10.41;raw_c3=-23.34;output;
gene='gene05';raw_c1=-4.35;raw_c2=-21.28;raw_c3=7.79;output;
gene='gene06';raw_c1=49.78;raw_c2=63.85;raw_c3=-24.08;output;
gene='gene07';raw_c1=7.91;raw_c2=1.9800000000000002;raw_c3=57.05;output;
run;
%n26_Rename_Del_Rgx4All_Vars(indsd=work.v6171i,Rgx=raw_);
data v6171m(keep=metric value);set v6171i;length metric $120;array measured[*] c1 c2 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6171i out=v6171s(keep=name type) noprint;run;data v6171s(keep=metric value);set v6171s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6171m data=v6171s;run;

data v6171m;set v6171m;format value best32.;run;
proc export data=v6171m outfile="%sysfunc(pathname(work))/V6171.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6171;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6171:;quit;
