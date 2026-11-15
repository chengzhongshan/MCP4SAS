/* New workflow V6148; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6148i;
length gene $80;
gene='gene01';c1=36.13;c2=-3.8000000000000003;c3=40.27;c4=32.34;c5=48.410000000000004;output;
gene='gene02';c1=7.26;c2=-28.669999999999998;c3=-22.599999999999998;c4=16.470000000000002;c5=42.54;output;
gene='gene03';c1=22.39;c2=62.46;c3=51.53;c4=21.6;c5=-20.33;output;
gene='gene04';c1=23.52;c2=30.59;c3=-12.34;c4=44.730000000000004;c5=0.8;output;
run;
%n26_KeepColNotMatchingRgx(indsd=work.v6148i,Rgx=^(c1|c3|c5)[[:space:]]*$,outdsd=v6148o);
data v6148m(keep=metric value);set v6148o;length metric $120;array measured[*] c2 c4;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6148o out=v6148s(keep=name type) noprint;run;data v6148s(keep=metric value);set v6148s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6148m data=v6148s;run;

data v6148m;set v6148m;format value best32.;run;
proc export data=v6148m outfile="%sysfunc(pathname(work))/V6148.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6148;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6148:;quit;
