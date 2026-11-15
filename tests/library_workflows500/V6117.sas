/* New workflow V6117; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6117i;
length gene $80 label1 $80 label2 $80 label3 $80;
gene='gene01';c1=30.13;c2=-9.799999999999999;c3=24.27;c4=-5.66;label1='text0';label2='text1';label3='text2';output;
gene='gene02';c1=0.26;c2=1.33;c3=62.4;c4=-28.529999999999998;label1='text0';label2='text1';label3='text2';output;
gene='gene03';c1=-22.61;c2=66.46;c3=-6.470000000000001;c4=9.600000000000001;label1='text0';label2='text1';label3='text2';output;
gene='gene04';c1=1.52;c2=46.59;c3=50.660000000000004;c4=58.730000000000004;label1='text0';label2='text1';label3='text2';output;
gene='gene05';c1=-18.35;c2=34.72;c3=44.79;c4=11.860000000000001;label1='text0';label2='text1';label3='text2';output;
gene='gene06';c1=-20.22;c2=64.85;c3=-11.08;c4=52.99;label1='text0';label2='text1';label3='text2';output;
run;
%n26_get_num_or_char_vars4dsd(indsd=work.v6117i,outdsd=v6117o,numeric=1);
data v6117m(keep=metric value);set v6117o;length metric $120;metric=cats("column:",upcase(name));value=(type="num");run;

data v6117m;set v6117m;format value best32.;run;
proc export data=v6117m outfile="%sysfunc(pathname(work))/V6117.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6117;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6117:;quit;
