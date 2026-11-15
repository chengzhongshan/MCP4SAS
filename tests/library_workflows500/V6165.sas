/* New workflow V6165; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6165i;
length gene $80;
gene='gene01';raw_c1=9.13;raw_c2=5.2;output;
gene='gene02';raw_c1=16.26;raw_c2=36.33;output;
gene='gene03';raw_c1=43.39;raw_c2=50.46;output;
gene='gene04';raw_c1=22.52;raw_c2=63.59;output;
gene='gene05';raw_c1=44.65;raw_c2=-12.28;output;
gene='gene06';raw_c1=-16.22;raw_c2=19.85;output;
gene='gene07';raw_c1=-4.09;raw_c2=8.98;output;
gene='gene08';raw_c1=19.04;raw_c2=-25.89;output;
run;
%n26_Rename_Del_Rgx4All_Vars(indsd=work.v6165i,Rgx=raw_);
data v6165m(keep=metric value);set v6165i;length metric $120;array measured[*] c1 c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6165i out=v6165s(keep=name type) noprint;run;data v6165s(keep=metric value);set v6165s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6165m data=v6165s;run;

data v6165m;set v6165m;format value best32.;run;
proc export data=v6165m outfile="%sysfunc(pathname(work))/V6165.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6165;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6165:;quit;
