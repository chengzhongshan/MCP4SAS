/* New workflow V6151; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6151i;
length gene $80;
gene='gene01';c1=17.13;c2=65.19999999999999;c3=29.27;output;
gene='gene02';c1=70.26;c2=31.330000000000002;c3=9.4;output;
gene='gene03';c1=56.39;c2=48.46;c3=35.53;output;
gene='gene04';c1=-13.48;c2=9.59;c3=-18.34;output;
gene='gene05';c1=19.65;c2=15.72;c3=-21.21;output;
gene='gene06';c1=25.78;c2=-9.15;c3=-5.08;output;
gene='gene07';c1=65.91;c2=46.98;c3=-1.9499999999999997;output;
run;
%n26_KeepColNotMatchingRgx(indsd=work.v6151i,Rgx=^(c2)[[:space:]]*$,outdsd=v6151o);
data v6151m(keep=metric value);set v6151o;length metric $120;array measured[*] c1 c3;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6151o out=v6151s(keep=name type) noprint;run;data v6151s(keep=metric value);set v6151s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6151m data=v6151s;run;

data v6151m;set v6151m;format value best32.;run;
proc export data=v6151m outfile="%sysfunc(pathname(work))/V6151.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6151;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6151:;quit;
