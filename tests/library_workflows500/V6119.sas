/* New workflow V6119; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6119i;
length gene $80 label1 $80 label2 $80 label3 $80 label4 $80 label5 $80;
gene='gene01';c1=-6.87;c2=60.2;c3=38.27;c4=52.34;c5=46.410000000000004;c6=47.480000000000004;label1='text0';label2='text1';label3='text2';label4='text3';label5='text4';output;
gene='gene02';c1=-23.74;c2=-20.669999999999998;c3=27.400000000000002;c4=48.47;c5=31.540000000000003;c6=64.61;label1='text0';label2='text1';label3='text2';label4='text3';label5='text4';output;
gene='gene03';c1=-26.61;c2=67.46;c3=7.529999999999999;c4=25.6;c5=58.67;c6=-12.26;label1='text0';label2='text1';label3='text2';label4='text3';label5='text4';output;
gene='gene04';c1=11.52;c2=16.59;c3=32.660000000000004;c4=-9.27;c5=9.799999999999999;c6=68.86999999999999;label1='text0';label2='text1';label3='text2';label4='text3';label5='text4';output;
gene='gene05';c1=30.65;c2=-17.28;c3=-12.209999999999999;c4=-19.14;c5=52.93;c6=69.0;label1='text0';label2='text1';label3='text2';label4='text3';label5='text4';output;
gene='gene06';c1=9.78;c2=-29.15;c3=3.9200000000000004;c4=0.99;c5=39.06;c6=-16.869999999999997;label1='text0';label2='text1';label3='text2';label4='text3';label5='text4';output;
gene='gene07';c1=-27.09;c2=50.98;c3=-12.95;c4=24.12;c5=-6.81;c6=-7.74;label1='text0';label2='text1';label3='text2';label4='text3';label5='text4';output;
gene='gene08';c1=66.04;c2=66.11;c3=3.18;c4=0.25000000000000006;c5=53.32;c6=54.39;label1='text0';label2='text1';label3='text2';label4='text3';label5='text4';output;
run;
%n26_get_num_or_char_vars4dsd(indsd=work.v6119i,outdsd=v6119o,numeric=1);
data v6119m(keep=metric value);set v6119o;length metric $120;metric=cats("column:",upcase(name));value=(type="num");run;

data v6119m;set v6119m;format value best32.;run;
proc export data=v6119m outfile="%sysfunc(pathname(work))/V6119.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6119;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6119:;quit;
