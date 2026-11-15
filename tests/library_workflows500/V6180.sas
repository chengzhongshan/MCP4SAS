/* New workflow V6180; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6180i;
length gene $80;
gene='gene01';raw_c1=61.13;raw_c2=30.2;output;
gene='gene02';raw_c1=60.26;raw_c2=-28.669999999999998;output;
gene='gene03';raw_c1=70.39;raw_c2=-0.54;output;
gene='gene04';raw_c1=-25.48;raw_c2=-2.41;output;
gene='gene05';raw_c1=-16.35;raw_c2=30.72;output;
gene='gene06';raw_c1=46.78;raw_c2=37.85;output;
gene='gene07';raw_c1=29.91;raw_c2=-20.02;output;
gene='gene08';raw_c1=37.04;raw_c2=-19.89;output;
gene='gene09';raw_c1=46.17;raw_c2=-16.759999999999998;output;
run;
%n26_Rename_Del_Rgx4All_Vars(indsd=work.v6180i,Rgx=raw_);
data v6180m(keep=metric value);set v6180i;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6180i out=v6180s(keep=name type) noprint;run;data v6180s(keep=metric value);set v6180s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6180m data=v6180s;run;

data v6180m;set v6180m;format value best32.;run;
proc export data=v6180m outfile="%sysfunc(pathname(work))/V6180.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6180;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6180:;quit;
