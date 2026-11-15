/* New workflow V6122; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6122i;
length gene $80;
gene='gene01';c1=64.13;c2=63.2;c3=28.27;c4=58.34;output;
gene='gene02';c1=-0.74;c2=-29.669999999999998;c3=14.4;c4=-18.529999999999998;output;
gene='gene03';c1=33.39;c2=-0.54;c3=37.53;c4=-11.399999999999999;output;
gene='gene04';c1=-16.48;c2=-7.41;c3=58.660000000000004;c4=-7.2700000000000005;output;
gene='gene05';c1=-5.35;c2=-6.279999999999999;c3=4.79;c4=57.86;output;
run;
%n26_KeepColMatchingRgx(indsd=work.v6122i,Rgx=^(gene|c1|c3)[[:space:]]*$,outdsd=v6122o,insensitive=1);
data v6122m(keep=metric value);set v6122o;length metric $120;array measured[*] c1 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6122o out=v6122s(keep=name type) noprint;run;data v6122s(keep=metric value);set v6122s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6122m data=v6122s;run;

data v6122m;set v6122m;format value best32.;run;
proc export data=v6122m outfile="%sysfunc(pathname(work))/V6122.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6122;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6122:;quit;
