/* New workflow V6130; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6130i;
length gene $80;
gene='gene01';c1=39.13;c2=-14.799999999999999;output;
gene='gene02';c1=60.26;c2=-12.67;output;
gene='gene03';c1=2.39;c2=10.46;output;
gene='gene04';c1=-19.48;c2=46.59;output;
gene='gene05';c1=-18.35;c2=-27.28;output;
gene='gene06';c1=38.78;c2=-28.15;output;
run;
%n26_KeepColMatchingRgx(indsd=work.v6130i,Rgx=^(gene|c1)[[:space:]]*$,outdsd=v6130o,insensitive=1);
data v6130m(keep=metric value);set v6130o;length metric $120;array measured[*] c1;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6130o out=v6130s(keep=name type) noprint;run;data v6130s(keep=metric value);set v6130s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6130m data=v6130s;run;

data v6130m;set v6130m;format value best32.;run;
proc export data=v6130m outfile="%sysfunc(pathname(work))/V6130.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6130;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6130:;quit;
