/* New workflow V6172; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6172i;
length gene $80;
gene='gene01';raw_c1=18.13;raw_c2=-3.8000000000000003;raw_c3=68.27;raw_c4=14.340000000000002;output;
gene='gene02';raw_c1=30.26;raw_c2=13.33;raw_c3=29.400000000000002;raw_c4=25.470000000000002;output;
gene='gene03';raw_c1=70.39;raw_c2=-24.54;raw_c3=41.53;raw_c4=54.6;output;
gene='gene04';raw_c1=66.52;raw_c2=-18.41;raw_c3=-8.34;raw_c4=-3.27;output;
gene='gene05';raw_c1=63.65;raw_c2=-7.279999999999999;raw_c3=34.79;raw_c4=-25.14;output;
gene='gene06';raw_c1=-9.22;raw_c2=-9.15;raw_c3=17.92;raw_c4=30.990000000000002;output;
gene='gene07';raw_c1=59.91;raw_c2=43.98;raw_c3=25.05;raw_c4=11.120000000000001;output;
gene='gene08';raw_c1=13.04;raw_c2=61.11;raw_c3=0.18000000000000005;raw_c4=1.25;output;
run;
%n26_Rename_Del_Rgx4All_Vars(indsd=work.v6172i,Rgx=raw_);
data v6172m(keep=metric value);set v6172i;length metric $120;array measured[*] c1 c2 c3 c4;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;
proc contents data=v6172i out=v6172s(keep=name type) noprint;run;data v6172s(keep=metric value);set v6172s;length metric $120;metric=cats("schema:",upcase(name));value=type;run;proc append base=v6172m data=v6172s;run;

data v6172m;set v6172m;format value best32.;run;
proc export data=v6172m outfile="%sysfunc(pathname(work))/V6172.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6172;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6172:;quit;
