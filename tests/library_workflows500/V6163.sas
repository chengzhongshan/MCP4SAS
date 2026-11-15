/* New workflow V6163; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6163i;
length gene $80;
gene='gene01';raw_c1=30.13;raw_c2=33.2;raw_c3=45.27;raw_c4=66.33999999999999;raw_c5=19.41;output;
gene='gene02';raw_c1=8.26;raw_c2=15.33;raw_c3=-25.599999999999998;raw_c4=28.470000000000002;raw_c5=-11.46;output;
gene='gene03';raw_c1=-19.61;raw_c2=67.46;raw_c3=51.53;raw_c4=15.600000000000001;raw_c5=-14.33;output;
gene='gene04';raw_c1=67.52;raw_c2=-3.41;raw_c3=62.660000000000004;raw_c4=40.730000000000004;raw_c5=0.8;output;
gene='gene05';raw_c1=62.65;raw_c2=-17.28;raw_c3=70.79;raw_c4=34.86;raw_c5=-18.07;output;
gene='gene06';raw_c1=-20.22;raw_c2=43.85;raw_c3=66.92;raw_c4=58.99;raw_c5=48.06;output;
run;
%n26_Rename_Del_Rgx4All_Vars(indsd=work.v6163i,Rgx=raw_);
data v6163m(keep=metric value);set v6163i;length metric $120;array measured[*] c1 c2 c3 c4 c5;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6163i out=v6163s(keep=name type) noprint;run;data v6163s(keep=metric value);set v6163s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6163m data=v6163s;run;

data v6163m;set v6163m;format value best32.;run;
proc export data=v6163m outfile="%sysfunc(pathname(work))/V6163.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6163;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6163:;quit;
