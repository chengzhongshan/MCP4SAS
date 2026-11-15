/* New workflow V6108; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6108i;
length gene $80 label1 $80 label2 $80 label3 $80 label4 $80;
gene='gene01';c1=66.13;c2=-2.8000000000000003;c3=49.27;c4=-29.66;c5=17.41;label1='text0';label2='text1';label3='text2';label4='text3';output;
gene='gene02';c1=63.26;c2=-25.669999999999998;c3=38.4;c4=68.47;c5=17.540000000000003;label1='text0';label2='text1';label3='text2';label4='text3';output;
gene='gene03';c1=3.39;c2=41.46;c3=-13.469999999999999;c4=-7.4;c5=-11.33;label1='text0';label2='text1';label3='text2';label4='text3';output;
gene='gene04';c1=8.52;c2=50.59;c3=69.66;c4=62.730000000000004;c5=30.8;label1='text0';label2='text1';label3='text2';label4='text3';output;
run;
%n26_get_num_or_char_vars4dsd(indsd=work.v6108i,outdsd=v6108o,numeric=0);
data v6108m(keep=metric value);set v6108o;length metric $120;metric=cats("column:",upcase(name));value=(type="num");run;

data v6108m;set v6108m;format value best32.;run;
proc export data=v6108m outfile="%sysfunc(pathname(work))/V6108.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6108;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6108:;quit;
