/* New workflow V6113; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6113i;
length gene $80 label1 $80 label2 $80 label3 $80 label4 $80;
gene='gene01';c1=-19.87;c2=0.2;c3=11.270000000000001;c4=24.34;c5=37.410000000000004;label1='text0';label2='text1';label3='text2';label4='text3';output;
gene='gene02';c1=55.26;c2=64.33;c3=-10.6;c4=45.47;c5=52.54;label1='text0';label2='text1';label3='text2';label4='text3';output;
gene='gene03';c1=-16.61;c2=24.46;c3=12.530000000000001;c4=59.6;c5=53.67;label1='text0';label2='text1';label3='text2';label4='text3';output;
gene='gene04';c1=3.52;c2=47.59;c3=9.66;c4=3.73;c5=51.800000000000004;label1='text0';label2='text1';label3='text2';label4='text3';output;
gene='gene05';c1=-18.35;c2=-26.28;c3=30.79;c4=-28.14;c5=-9.07;label1='text0';label2='text1';label3='text2';label4='text3';output;
gene='gene06';c1=54.78;c2=6.8500000000000005;c3=62.92;c4=-1.01;c5=48.06;label1='text0';label2='text1';label3='text2';label4='text3';output;
gene='gene07';c1=12.91;c2=50.98;c3=-6.95;c4=6.12;c5=62.19;label1='text0';label2='text1';label3='text2';label4='text3';output;
gene='gene08';c1=62.04;c2=-2.89;c3=52.18;c4=60.25;c5=-12.680000000000001;label1='text0';label2='text1';label3='text2';label4='text3';output;
gene='gene09';c1=23.17;c2=-2.7600000000000002;c3=71.31;c4=29.380000000000003;c5=-18.549999999999997;label1='text0';label2='text1';label3='text2';label4='text3';output;
run;
%n26_get_num_or_char_vars4dsd(indsd=work.v6113i,outdsd=v6113o,numeric=1);
data v6113m(keep=metric value);set v6113o;length metric $120;metric=cats("column:",upcase(name));value=(type="num");run;

data v6113m;set v6113m;format value best32.;run;
proc export data=v6113m outfile="%sysfunc(pathname(work))/V6113.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6113;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6113:;quit;
