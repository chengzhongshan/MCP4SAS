/* New workflow V6134; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6134i;
length gene $80;
gene='gene01';c1=61.13;c2=1.2;c3=66.27;c4=-1.6600000000000001;c5=-23.59;c6=52.480000000000004;output;
gene='gene02';c1=4.26;c2=26.330000000000002;c3=53.4;c4=51.47;c5=29.540000000000003;c6=-0.38999999999999996;output;
gene='gene03';c1=49.39;c2=19.46;c3=15.530000000000001;c4=-28.4;c5=60.67;c6=-20.259999999999998;output;
run;
%n26_KeepColMatchingRgx(indsd=work.v6134i,Rgx=^(gene|c1|c3|c5)[[:space:]]*$,outdsd=v6134o,insensitive=1);
data v6134m(keep=metric value);set v6134o;length metric $120;array measured[*] c1 c3 c5;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6134o out=v6134s(keep=name type) noprint;run;data v6134s(keep=metric value);set v6134s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6134m data=v6134s;run;

data v6134m;set v6134m;format value best32.;run;
proc export data=v6134m outfile="%sysfunc(pathname(work))/V6134.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6134;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6134:;quit;
