/* New workflow V6116; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6116i;
length gene $80 label1 $80 label2 $80;
gene='gene01';c1=69.13;c2=-13.799999999999999;c3=54.27;label1='text0';label2='text1';output;
gene='gene02';c1=-29.74;c2=11.33;c3=-5.6000000000000005;label1='text0';label2='text1';output;
gene='gene03';c1=14.39;c2=55.46;c3=-12.469999999999999;label1='text0';label2='text1';output;
gene='gene04';c1=56.52;c2=-5.41;c3=50.660000000000004;label1='text0';label2='text1';output;
gene='gene05';c1=64.65;c2=-3.2800000000000002;c3=-22.21;label1='text0';label2='text1';output;
run;
%n26_get_num_or_char_vars4dsd(indsd=work.v6116i,outdsd=v6116o,numeric=0);
data v6116m(keep=metric value);set v6116o;length metric $120;metric=cats("column:",upcase(name));value=(type="num");run;

data v6116m;set v6116m;format value best32.;run;
proc export data=v6116m outfile="%sysfunc(pathname(work))/V6116.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6116;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6116:;quit;
