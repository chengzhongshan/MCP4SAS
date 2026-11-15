/* New workflow V6179; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6179i;
length gene $80;
gene='gene01';raw_c1=-15.87;raw_c2=21.2;raw_c3=39.27;raw_c4=40.34;raw_c5=43.410000000000004;raw_c6=28.48;output;
gene='gene02';raw_c1=-19.74;raw_c2=41.33;raw_c3=49.4;raw_c4=46.47;raw_c5=60.54;raw_c6=13.61;output;
gene='gene03';raw_c1=-20.61;raw_c2=36.46;raw_c3=29.53;raw_c4=14.600000000000001;raw_c5=10.67;raw_c6=22.740000000000002;output;
gene='gene04';raw_c1=20.52;raw_c2=61.59;raw_c3=-25.34;raw_c4=13.73;raw_c5=42.800000000000004;raw_c6=3.87;output;
gene='gene05';raw_c1=4.65;raw_c2=12.72;raw_c3=26.79;raw_c4=-21.14;raw_c5=-3.0700000000000003;raw_c6=-29.0;output;
gene='gene06';raw_c1=42.78;raw_c2=25.85;raw_c3=25.92;raw_c4=42.99;raw_c5=32.06;raw_c6=-6.87;output;
gene='gene07';raw_c1=9.91;raw_c2=8.98;raw_c3=-10.95;raw_c4=39.12;raw_c5=36.19;raw_c6=60.26;output;
gene='gene08';raw_c1=23.04;raw_c2=48.11;raw_c3=1.1800000000000002;raw_c4=3.25;raw_c5=42.32;raw_c6=64.39;output;
run;
%n26_Rename_Del_Rgx4All_Vars(indsd=work.v6179i,Rgx=raw_);
data v6179m(keep=metric value);set v6179i;length metric $120;array measured[*] c1 c2 c3 c4 c5 c6;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6179i out=v6179s(keep=name type) noprint;run;data v6179s(keep=metric value);set v6179s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6179m data=v6179s;run;

data v6179m;set v6179m;format value best32.;run;
proc export data=v6179m outfile="%sysfunc(pathname(work))/V6179.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6179;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6179:;quit;
