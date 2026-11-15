/* New workflow V6128; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6128i;
length gene $80;
gene='gene01';c1=36.13;c2=21.2;c3=-1.73;c4=31.34;c5=16.41;output;
gene='gene02';c1=43.26;c2=27.330000000000002;c3=57.4;c4=-0.53;c5=26.540000000000003;output;
gene='gene03';c1=26.39;c2=-18.54;c3=-4.470000000000001;c4=29.6;c5=24.67;output;
gene='gene04';c1=-16.48;c2=-26.41;c3=31.66;c4=56.730000000000004;c5=50.800000000000004;output;
run;
%n26_KeepColMatchingRgx(indsd=work.v6128i,Rgx=^(gene|c1|c3|c5)[[:space:]]*$,outdsd=v6128o,insensitive=1);
data v6128m(keep=metric value);set v6128o;length metric $120;array measured[*] c1 c3 c5;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6128o out=v6128s(keep=name type) noprint;run;data v6128s(keep=metric value);set v6128s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6128m data=v6128s;run;

data v6128m;set v6128m;format value best32.;run;
proc export data=v6128m outfile="%sysfunc(pathname(work))/V6128.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6128;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6128:;quit;
