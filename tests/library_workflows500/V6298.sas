/* New workflow V6298; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6298i;
length id $80;
id='s01';c1=2;c2=.;c3=1;c4=99;c5=1;output;
id='s02';c1=.;c2=99;c3=0;c4=0;c5=1;output;
id='s03';c1=1;c2=2;c3=99;c4=1;c5=99;output;
id='s04';c1=0;c2=0;c3=2;c4=.;c5=0;output;
id='s05';c1=99;c2=2;c3=2;c4=1;c5=.;output;
id='s06';c1=0;c2=99;c3=99;c4=99;c5=0;output;
id='s07';c1=1;c2=1;c3=0;c4=2;c5=.;output;
run;
%n26_additive_geno2alleles(indsd=v6298i,snp_varnames=c1 c2 c3 c4 c5,sample_id=id,outdsd=v6298o);
data v6298m(keep=metric value);set v6298o;length metric $120;array a[*] $ m1 m2 m3 m4 m5 m6 m7 m8 m9 m10;do j=1 to dim(a);metric=catx(":",id,vname(a[j]));value=input(a[j],??best32.);output;end;run;

data v6298m;set v6298m;format value best32.;run;
proc export data=v6298m outfile="%sysfunc(pathname(work))/V6298.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6298;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6298:;quit;
