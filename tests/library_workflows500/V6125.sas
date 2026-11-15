/* New workflow V6125; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6125i;
length gene $80;
gene='gene01';c1=58.13;c2=38.2;output;
gene='gene02';c1=66.26;c2=61.33;output;
gene='gene03';c1=19.39;c2=47.46;output;
gene='gene04';c1=0.52;c2=55.59;output;
gene='gene05';c1=56.65;c2=5.720000000000001;output;
gene='gene06';c1=56.78;c2=53.85;output;
gene='gene07';c1=-25.09;c2=-3.02;output;
gene='gene08';c1=1.04;c2=-1.89;output;
run;
%n26_KeepColMatchingRgx(indsd=work.v6125i,Rgx=^(gene|c2)[[:space:]]*$,outdsd=v6125o,insensitive=1);
data v6125m(keep=metric value);set v6125o;length metric $120;array measured[*] c2;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6125o out=v6125s(keep=name type) noprint;run;data v6125s(keep=metric value);set v6125s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6125m data=v6125s;run;

data v6125m;set v6125m;format value best32.;run;
proc export data=v6125m outfile="%sysfunc(pathname(work))/V6125.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6125;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6125:;quit;
