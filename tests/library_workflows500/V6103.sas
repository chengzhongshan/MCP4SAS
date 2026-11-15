/* New workflow V6103; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6103i;
length gene $80 label1 $80 label2 $80 label3 $80 label4 $80;
gene='gene01';c1=5.13;c2=-4.8;c3=29.27;c4=5.34;c5=3.41;label1='text0';label2='text1';label3='text2';label4='text3';output;
gene='gene02';c1=-2.74;c2=0.33;c3=-15.6;c4=54.47;c5=2.54;label1='text0';label2='text1';label3='text2';label4='text3';output;
gene='gene03';c1=48.39;c2=5.46;c3=13.530000000000001;c4=-9.399999999999999;c5=70.67;label1='text0';label2='text1';label3='text2';label4='text3';output;
gene='gene04';c1=28.52;c2=39.59;c3=52.660000000000004;c4=-18.27;c5=68.8;label1='text0';label2='text1';label3='text2';label4='text3';output;
gene='gene05';c1=45.65;c2=18.72;c3=70.79;c4=59.86;c5=2.9299999999999997;label1='text0';label2='text1';label3='text2';label4='text3';output;
gene='gene06';c1=-14.22;c2=12.85;c3=34.92;c4=-1.01;c5=-10.940000000000001;label1='text0';label2='text1';label3='text2';label4='text3';output;
run;
%n26_get_num_or_char_vars4dsd(indsd=work.v6103i,outdsd=v6103o,numeric=1);
data v6103m(keep=metric value);set v6103o;length metric $120;metric=cats("column:",upcase(name));value=(type="num");run;

data v6103m;set v6103m;format value best32.;run;
proc export data=v6103m outfile="%sysfunc(pathname(work))/V6103.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6103;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6103:;quit;
