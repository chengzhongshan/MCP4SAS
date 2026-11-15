/* New workflow V6136; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6136i;
length gene $80;
gene='gene01';c1=57.13;c2=-28.8;c3=31.27;output;
gene='gene02';c1=61.26;c2=-19.669999999999998;c3=53.4;output;
gene='gene03';c1=56.39;c2=-25.54;c3=69.53;output;
gene='gene04';c1=27.52;c2=9.59;c3=6.659999999999999;output;
gene='gene05';c1=14.65;c2=-12.28;c3=1.79;output;
run;
%n26_KeepColMatchingRgx(indsd=work.v6136i,Rgx=^(gene|c1|c3)[[:space:]]*$,outdsd=v6136o,insensitive=1);
data v6136m(keep=metric value);set v6136o;length metric $120;array measured[*] c1 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6136o out=v6136s(keep=name type) noprint;run;data v6136s(keep=metric value);set v6136s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6136m data=v6136s;run;

data v6136m;set v6136m;format value best32.;run;
proc export data=v6136m outfile="%sysfunc(pathname(work))/V6136.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6136;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6136:;quit;
