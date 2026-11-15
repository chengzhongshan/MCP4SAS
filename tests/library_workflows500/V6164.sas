/* New workflow V6164; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6164i;
length gene $80;
gene='gene01';raw_c1=-2.87;raw_c2=-4.8;raw_c3=47.27;raw_c4=49.34;raw_c5=-3.59;raw_c6=-18.52;output;
gene='gene02';raw_c1=46.26;raw_c2=-22.669999999999998;raw_c3=64.4;raw_c4=55.47;raw_c5=-18.459999999999997;raw_c6=50.61;output;
gene='gene03';raw_c1=7.39;raw_c2=-5.54;raw_c3=-29.47;raw_c4=31.6;raw_c5=70.67;raw_c6=28.740000000000002;output;
gene='gene04';raw_c1=27.52;raw_c2=55.59;raw_c3=-24.34;raw_c4=-15.27;raw_c5=-12.200000000000001;raw_c6=40.870000000000005;output;
gene='gene05';raw_c1=70.65;raw_c2=-20.28;raw_c3=-19.21;raw_c4=19.86;raw_c5=17.93;raw_c6=4.0;output;
gene='gene06';raw_c1=-24.22;raw_c2=43.85;raw_c3=20.92;raw_c4=30.990000000000002;raw_c5=-25.939999999999998;raw_c6=58.13;output;
gene='gene07';raw_c1=-9.09;raw_c2=62.98;raw_c3=56.05;raw_c4=2.12;raw_c5=3.1900000000000004;raw_c6=69.25999999999999;output;
run;
%n26_Rename_Del_Rgx4All_Vars(indsd=work.v6164i,Rgx=raw_);
data v6164m(keep=metric value);set v6164i;length metric $120;array measured[*] c1 c2 c3 c4 c5 c6;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6164i out=v6164s(keep=name type) noprint;run;data v6164s(keep=metric value);set v6164s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6164m data=v6164s;run;

data v6164m;set v6164m;format value best32.;run;
proc export data=v6164m outfile="%sysfunc(pathname(work))/V6164.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6164;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6164:;quit;
