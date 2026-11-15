/* New workflow V6143; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6143i;
length gene $80;
gene='gene01';c1=5.13;c2=42.2;c3=12.270000000000001;c4=3.34;c5=28.41;output;
gene='gene02';c1=-17.74;c2=39.33;c3=17.400000000000002;c4=13.47;c5=21.540000000000003;output;
gene='gene03';c1=-17.61;c2=5.46;c3=52.53;c4=60.6;c5=64.67;output;
gene='gene04';c1=-5.48;c2=4.59;c3=-21.34;c4=69.72999999999999;c5=-7.2;output;
gene='gene05';c1=15.65;c2=20.72;c3=36.79;c4=45.86;c5=-19.07;output;
gene='gene06';c1=45.78;c2=1.85;c3=61.92;c4=55.99;c5=71.06;output;
run;
%n26_KeepColNotMatchingRgx(indsd=work.v6143i,Rgx=^(c2|c4)[[:space:]]*$,outdsd=v6143o);
data v6143m(keep=metric value);set v6143o;length metric $120;array measured[*] c1 c3 c5;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6143o out=v6143s(keep=name type) noprint;run;data v6143s(keep=metric value);set v6143s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6143m data=v6143s;run;

data v6143m;set v6143m;format value best32.;run;
proc export data=v6143m outfile="%sysfunc(pathname(work))/V6143.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6143;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6143:;quit;
