/* New workflow V6126; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6126i;
length gene $80;
gene='gene01';c1=54.13;c2=56.2;c3=18.27;output;
gene='gene02';c1=14.26;c2=13.33;c3=-17.599999999999998;output;
gene='gene03';c1=51.39;c2=33.46;c3=58.53;output;
gene='gene04';c1=44.52;c2=16.59;c3=66.66;output;
gene='gene05';c1=48.65;c2=48.72;c3=-8.209999999999999;output;
gene='gene06';c1=26.78;c2=-2.15;c3=15.92;output;
gene='gene07';c1=-4.09;c2=68.97999999999999;c3=47.05;output;
gene='gene08';c1=23.04;c2=15.11;c3=61.18;output;
gene='gene09';c1=12.17;c2=38.24;c3=49.31;output;
run;
%n26_KeepColMatchingRgx(indsd=work.v6126i,Rgx=^(gene|c1|c3)[[:space:]]*$,outdsd=v6126o,insensitive=1);
data v6126m(keep=metric value);set v6126o;length metric $120;array measured[*] c1 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6126o out=v6126s(keep=name type) noprint;run;data v6126s(keep=metric value);set v6126s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6126m data=v6126s;run;

data v6126m;set v6126m;format value best32.;run;
proc export data=v6126m outfile="%sysfunc(pathname(work))/V6126.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6126;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6126:;quit;
