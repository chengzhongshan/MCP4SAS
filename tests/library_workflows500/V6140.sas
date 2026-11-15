/* New workflow V6140; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6140i;
length gene $80;
gene='gene01';c1=51.13;c2=57.2;output;
gene='gene02';c1=22.26;c2=33.33;output;
gene='gene03';c1=-28.61;c2=15.46;output;
gene='gene04';c1=12.52;c2=25.59;output;
gene='gene05';c1=-9.35;c2=-26.28;output;
gene='gene06';c1=59.78;c2=45.85;output;
gene='gene07';c1=4.91;c2=33.98;output;
gene='gene08';c1=22.04;c2=66.11;output;
gene='gene09';c1=44.17;c2=5.24;output;
run;
%n26_KeepColMatchingRgx(indsd=work.v6140i,Rgx=^(gene|c1)[[:space:]]*$,outdsd=v6140o,insensitive=1);
data v6140m(keep=metric value);set v6140o;length metric $120;array measured[*] c1;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6140o out=v6140s(keep=name type) noprint;run;data v6140s(keep=metric value);set v6140s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6140m data=v6140s;run;

data v6140m;set v6140m;format value best32.;run;
proc export data=v6140m outfile="%sysfunc(pathname(work))/V6140.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6140;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6140:;quit;
