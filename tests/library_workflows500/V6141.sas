/* New workflow V6141; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6141i;
length gene $80;
gene='gene01';c1=49.13;c2=36.2;c3=50.27;output;
gene='gene02';c1=-29.74;c2=23.330000000000002;c3=13.4;output;
gene='gene03';c1=27.39;c2=11.46;c3=45.53;output;
gene='gene04';c1=-26.48;c2=51.59;c3=16.66;output;
run;
%n26_KeepColNotMatchingRgx(indsd=work.v6141i,Rgx=^(c2)[[:space:]]*$,outdsd=v6141o);
data v6141m(keep=metric value);set v6141o;length metric $120;array measured[*] c1 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6141o out=v6141s(keep=name type) noprint;run;data v6141s(keep=metric value);set v6141s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6141m data=v6141s;run;

data v6141m;set v6141m;format value best32.;run;
proc export data=v6141m outfile="%sysfunc(pathname(work))/V6141.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6141;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6141:;quit;
