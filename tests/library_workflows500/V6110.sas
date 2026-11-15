/* New workflow V6110; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6110i;
length gene $80 label1 $80;
gene='gene01';c1=69.13;c2=8.200000000000001;label1='text0';output;
gene='gene02';c1=-3.74;c2=26.330000000000002;label1='text0';output;
gene='gene03';c1=60.39;c2=-27.54;label1='text0';output;
gene='gene04';c1=56.52;c2=10.59;label1='text0';output;
gene='gene05';c1=53.65;c2=49.72;label1='text0';output;
gene='gene06';c1=15.78;c2=64.85;label1='text0';output;
run;
%n26_get_num_or_char_vars4dsd(indsd=work.v6110i,outdsd=v6110o,numeric=0);
data v6110m(keep=metric value);set v6110o;length metric $120;metric=cats("column:",upcase(name));value=(type="num");run;

data v6110m;set v6110m;format value best32.;run;
proc export data=v6110m outfile="%sysfunc(pathname(work))/V6110.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6110;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6110:;quit;
