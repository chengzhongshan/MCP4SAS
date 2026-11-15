/* New workflow V6178; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6178i;
length gene $80;
gene='gene01';raw_c1=7.13;raw_c2=-23.8;raw_c3=37.27;raw_c4=62.34;raw_c5=57.410000000000004;output;
gene='gene02';raw_c1=50.26;raw_c2=-25.669999999999998;raw_c3=12.4;raw_c4=63.47;raw_c5=14.54;output;
gene='gene03';raw_c1=-3.61;raw_c2=53.46;raw_c3=36.53;raw_c4=-21.4;raw_c5=-12.33;output;
gene='gene04';raw_c1=48.52;raw_c2=45.59;raw_c3=8.66;raw_c4=13.73;raw_c5=66.8;output;
gene='gene05';raw_c1=57.65;raw_c2=16.72;raw_c3=58.79;raw_c4=-15.139999999999999;raw_c5=37.93;output;
gene='gene06';raw_c1=55.78;raw_c2=26.85;raw_c3=31.92;raw_c4=42.99;raw_c5=-16.939999999999998;output;
gene='gene07';raw_c1=-28.09;raw_c2=16.98;raw_c3=27.05;raw_c4=39.12;raw_c5=-3.8099999999999996;output;
run;
%n26_Rename_Del_Rgx4All_Vars(indsd=work.v6178i,Rgx=raw_);
data v6178m(keep=metric value);set v6178i;length metric $120;array measured[*] c1 c2 c3 c4 c5;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6178i out=v6178s(keep=name type) noprint;run;data v6178s(keep=metric value);set v6178s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6178m data=v6178s;run;

data v6178m;set v6178m;format value best32.;run;
proc export data=v6178m outfile="%sysfunc(pathname(work))/V6178.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6178;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6178:;quit;
