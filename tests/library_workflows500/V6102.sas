/* New workflow V6102; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6102i;
length gene $80 label1 $80 label2 $80 label3 $80;
gene='gene01';c1=37.13;c2=62.2;c3=38.27;c4=9.340000000000002;label1='text0';label2='text1';label3='text2';output;
gene='gene02';c1=-26.74;c2=22.330000000000002;c3=5.3999999999999995;c4=63.47;label1='text0';label2='text1';label3='text2';output;
gene='gene03';c1=55.39;c2=-18.54;c3=3.5300000000000002;c4=49.6;label1='text0';label2='text1';label3='text2';output;
gene='gene04';c1=-20.48;c2=45.59;c3=15.66;c4=63.730000000000004;label1='text0';label2='text1';label3='text2';output;
gene='gene05';c1=8.65;c2=19.72;c3=19.79;c4=-15.139999999999999;label1='text0';label2='text1';label3='text2';output;
run;
%n26_get_num_or_char_vars4dsd(indsd=work.v6102i,outdsd=v6102o,numeric=0);
data v6102m(keep=metric value);set v6102o;length metric $120;metric=cats("column:",upcase(name));value=(type="num");run;

data v6102m;set v6102m;format value best32.;run;
proc export data=v6102m outfile="%sysfunc(pathname(work))/V6102.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6102;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6102:;quit;
