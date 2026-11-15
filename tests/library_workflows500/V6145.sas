/* New workflow V6145; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6145i;
length gene $80;
gene='gene01';c1=27.13;c2=-27.8;output;
gene='gene02';c1=58.26;c2=65.33;output;
gene='gene03';c1=40.39;c2=6.46;output;
gene='gene04';c1=7.52;c2=22.59;output;
gene='gene05';c1=36.65;c2=61.72;output;
gene='gene06';c1=-2.2199999999999998;c2=14.85;output;
gene='gene07';c1=-10.09;c2=62.98;output;
gene='gene08';c1=51.04;c2=3.11;output;
run;
%n26_KeepColNotMatchingRgx(indsd=work.v6145i,Rgx=^(c2)[[:space:]]*$,outdsd=v6145o);
data v6145m(keep=metric value);set v6145o;length metric $120;array measured[*] c1;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6145o out=v6145s(keep=name type) noprint;run;data v6145s(keep=metric value);set v6145s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6145m data=v6145s;run;

data v6145m;set v6145m;format value best32.;run;
proc export data=v6145m outfile="%sysfunc(pathname(work))/V6145.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6145;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6145:;quit;
