/* New workflow V6173; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6173i;
length gene $80;
gene='gene01';raw_c1=-12.87;raw_c2=-26.8;raw_c3=-25.73;raw_c4=5.34;raw_c5=55.410000000000004;output;
gene='gene02';raw_c1=8.26;raw_c2=40.33;raw_c3=42.4;raw_c4=16.470000000000002;raw_c5=-15.46;output;
gene='gene03';raw_c1=47.39;raw_c2=-4.54;raw_c3=-11.469999999999999;raw_c4=1.6;raw_c5=41.67;output;
gene='gene04';raw_c1=65.52;raw_c2=65.58999999999999;raw_c3=-23.34;raw_c4=-6.2700000000000005;raw_c5=63.800000000000004;output;
gene='gene05';raw_c1=47.65;raw_c2=12.72;raw_c3=69.79;raw_c4=-18.14;raw_c5=52.93;output;
gene='gene06';raw_c1=-23.22;raw_c2=-24.15;raw_c3=-6.08;raw_c4=-26.009999999999998;raw_c5=-20.939999999999998;output;
gene='gene07';raw_c1=40.91;raw_c2=16.98;raw_c3=33.05;raw_c4=18.12;raw_c5=54.19;output;
gene='gene08';raw_c1=60.04;raw_c2=1.11;raw_c3=34.18;raw_c4=49.25;raw_c5=4.32;output;
gene='gene09';raw_c1=44.17;raw_c2=-9.76;raw_c3=-13.69;raw_c4=32.38;raw_c5=30.450000000000003;output;
run;
%n26_Rename_Del_Rgx4All_Vars(indsd=work.v6173i,Rgx=raw_);
data v6173m(keep=metric value);set v6173i;length metric $120;array measured[*] c1 c2 c3 c4 c5;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6173i out=v6173s(keep=name type) noprint;run;data v6173s(keep=metric value);set v6173s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6173m data=v6173s;run;

data v6173m;set v6173m;format value best32.;run;
proc export data=v6173m outfile="%sysfunc(pathname(work))/V6173.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6173;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6173:;quit;
