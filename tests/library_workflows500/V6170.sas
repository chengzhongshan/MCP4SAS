/* New workflow V6170; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6170i;
length gene $80;
gene='gene01';raw_c1=45.13;raw_c2=37.2;output;
gene='gene02';raw_c1=-7.74;raw_c2=11.33;output;
gene='gene03';raw_c1=17.39;raw_c2=-17.54;output;
gene='gene04';raw_c1=-10.48;raw_c2=43.59;output;
gene='gene05';raw_c1=25.65;raw_c2=20.72;output;
gene='gene06';raw_c1=33.78;raw_c2=-18.15;output;
run;
%n26_Rename_Del_Rgx4All_Vars(indsd=work.v6170i,Rgx=raw_);
data v6170m(keep=metric value);set v6170i;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6170i out=v6170s(keep=name type) noprint;run;data v6170s(keep=metric value);set v6170s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6170m data=v6170s;run;

data v6170m;set v6170m;format value best32.;run;
proc export data=v6170m outfile="%sysfunc(pathname(work))/V6170.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6170;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6170:;quit;
