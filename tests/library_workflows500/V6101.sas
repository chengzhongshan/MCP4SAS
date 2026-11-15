/* New workflow V6101; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6101i;
length gene $80 label1 $80 label2 $80;
gene='gene01';c1=21.13;c2=64.19999999999999;c3=-0.73;label1='text0';label2='text1';output;
gene='gene02';c1=51.26;c2=13.33;c3=34.4;label1='text0';label2='text1';output;
gene='gene03';c1=59.39;c2=40.46;c3=28.53;label1='text0';label2='text1';output;
gene='gene04';c1=15.52;c2=50.59;c3=28.66;label1='text0';label2='text1';output;
run;
%n26_get_num_or_char_vars4dsd(indsd=work.v6101i,outdsd=v6101o,numeric=1);
data v6101m(keep=metric value);set v6101o;length metric $120;metric=cats("column:",upcase(name));value=(type="num");run;

data v6101m;set v6101m;format value best32.;run;
proc export data=v6101m outfile="%sysfunc(pathname(work))/V6101.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6101;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6101:;quit;
