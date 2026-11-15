/* New workflow V6152; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6152i;
length gene $80;
gene='gene01';c1=63.13;c2=19.2;c3=-1.73;c4=12.340000000000002;output;
gene='gene02';c1=57.26;c2=43.33;c3=-26.599999999999998;c4=69.47;output;
gene='gene03';c1=16.39;c2=-25.54;c3=-28.47;c4=-28.4;output;
gene='gene04';c1=-22.48;c2=39.59;c3=-5.340000000000001;c4=-4.2700000000000005;output;
gene='gene05';c1=28.65;c2=16.72;c3=-28.21;c4=-21.14;output;
gene='gene06';c1=17.78;c2=0.8500000000000001;c3=-8.08;c4=-21.009999999999998;output;
gene='gene07';c1=32.91;c2=3.98;c3=68.05;c4=-5.88;output;
gene='gene08';c1=-3.96;c2=26.11;c3=-7.82;c4=-25.75;output;
run;
%n26_KeepColNotMatchingRgx(indsd=work.v6152i,Rgx=^(c1|c3)[[:space:]]*$,outdsd=v6152o);
data v6152m(keep=metric value);set v6152o;length metric $120;array measured[*] c2 c4;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6152o out=v6152s(keep=name type) noprint;run;data v6152s(keep=metric value);set v6152s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6152m data=v6152s;run;

data v6152m;set v6152m;format value best32.;run;
proc export data=v6152m outfile="%sysfunc(pathname(work))/V6152.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6152;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6152:;quit;
