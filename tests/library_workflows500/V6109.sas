/* New workflow V6109; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6109i;
length gene $80 label1 $80 label2 $80 label3 $80 label4 $80 label5 $80;
gene='gene01';c1=33.13;c2=68.19999999999999;c3=-22.73;c4=-3.66;c5=-1.59;c6=-13.52;label1='text0';label2='text1';label3='text2';label4='text3';label5='text4';output;
gene='gene02';c1=9.26;c2=52.33;c3=70.4;c4=0.47000000000000003;c5=68.54;c6=-11.39;label1='text0';label2='text1';label3='text2';label4='text3';label5='text4';output;
gene='gene03';c1=52.39;c2=-28.54;c3=-17.47;c4=-14.399999999999999;c5=37.67;c6=48.74;label1='text0';label2='text1';label3='text2';label4='text3';label5='text4';output;
gene='gene04';c1=41.52;c2=70.58999999999999;c3=6.659999999999999;c4=17.73;c5=-14.200000000000001;c6=44.870000000000005;label1='text0';label2='text1';label3='text2';label4='text3';label5='text4';output;
gene='gene05';c1=-9.35;c2=2.7199999999999998;c3=-7.21;c4=57.86;c5=35.93;c6=19.0;label1='text0';label2='text1';label3='text2';label4='text3';label5='text4';output;
run;
%n26_get_num_or_char_vars4dsd(indsd=work.v6109i,outdsd=v6109o,numeric=1);
data v6109m(keep=metric value);set v6109o;length metric $120;metric=cats("column:",upcase(name));value=(type="num");run;

data v6109m;set v6109m;format value best32.;run;
proc export data=v6109m outfile="%sysfunc(pathname(work))/V6109.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6109;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6109:;quit;
