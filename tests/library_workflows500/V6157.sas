/* New workflow V6157; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6157i;
length gene $80;
gene='gene01';c1=34.13;c2=-4.8;c3=-4.73;c4=46.34;output;
gene='gene02';c1=18.26;c2=5.33;c3=-5.6000000000000005;c4=20.470000000000002;output;
gene='gene03';c1=48.39;c2=-21.54;c3=50.53;c4=63.6;output;
gene='gene04';c1=19.52;c2=37.59;c3=51.660000000000004;c4=16.73;output;
gene='gene05';c1=37.65;c2=68.72;c3=9.790000000000001;c4=21.86;output;
gene='gene06';c1=-26.22;c2=-16.15;c3=6.92;c4=42.99;output;
run;
%n26_KeepColNotMatchingRgx(indsd=work.v6157i,Rgx=^(c2|c4)[[:space:]]*$,outdsd=v6157o);
data v6157m(keep=metric value);set v6157o;length metric $120;array measured[*] c1 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6157o out=v6157s(keep=name type) noprint;run;data v6157s(keep=metric value);set v6157s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6157m data=v6157s;run;

data v6157m;set v6157m;format value best32.;run;
proc export data=v6157m outfile="%sysfunc(pathname(work))/V6157.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6157;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6157:;quit;
