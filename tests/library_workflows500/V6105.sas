/* New workflow V6105; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6105i;
length gene $80 label1 $80;
gene='gene01';c1=34.13;c2=-28.8;label1='text0';output;
gene='gene02';c1=-17.74;c2=13.33;label1='text0';output;
gene='gene03';c1=-28.61;c2=14.46;label1='text0';output;
gene='gene04';c1=-17.48;c2=24.59;label1='text0';output;
gene='gene05';c1=-29.35;c2=17.72;label1='text0';output;
gene='gene06';c1=-15.22;c2=4.8500000000000005;label1='text0';output;
gene='gene07';c1=-11.09;c2=-0.019999999999999962;label1='text0';output;
gene='gene08';c1=62.04;c2=11.11;label1='text0';output;
run;
%n26_get_num_or_char_vars4dsd(indsd=work.v6105i,outdsd=v6105o,numeric=1);
data v6105m(keep=metric value);set v6105o;length metric $120;metric=cats("column:",upcase(name));value=(type="num");run;

data v6105m;set v6105m;format value best32.;run;
proc export data=v6105m outfile="%sysfunc(pathname(work))/V6105.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6105;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6105:;quit;
