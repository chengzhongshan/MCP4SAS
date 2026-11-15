/* New workflow V6168; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6168i;
length gene $80;
gene='gene01';raw_c1=-20.87;raw_c2=15.200000000000001;raw_c3=38.27;raw_c4=7.34;raw_c5=-28.59;output;
gene='gene02';raw_c1=52.26;raw_c2=58.33;raw_c3=23.400000000000002;raw_c4=-5.53;raw_c5=-14.46;output;
gene='gene03';raw_c1=69.39;raw_c2=3.46;raw_c3=27.53;raw_c4=12.600000000000001;raw_c5=20.67;output;
gene='gene04';raw_c1=51.52;raw_c2=22.59;raw_c3=-12.34;raw_c4=-7.2700000000000005;raw_c5=-11.200000000000001;output;
run;
%n26_Rename_Del_Rgx4All_Vars(indsd=work.v6168i,Rgx=raw_);
data v6168m(keep=metric value);set v6168i;length metric $120;array measured[*] c1 c2 c3 c4 c5;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6168i out=v6168s(keep=name type) noprint;run;data v6168s(keep=metric value);set v6168s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6168m data=v6168s;run;

data v6168m;set v6168m;format value best32.;run;
proc export data=v6168m outfile="%sysfunc(pathname(work))/V6168.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6168;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6168:;quit;
