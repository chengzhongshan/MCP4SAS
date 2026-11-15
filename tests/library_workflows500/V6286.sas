/* New workflow V6286; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6286i;
length id $80;
id='s01';c1=.;c2=.;c3=.;output;
id='s02';c1=1;c2=0;c3=2;output;
id='s03';c1=0;c2=0;c3=99;output;
id='s04';c1=.;c2=1;c3=.;output;
id='s05';c1=2;c2=2;c3=2;output;
id='s06';c1=1;c2=2;c3=2;output;
id='s07';c1=2;c2=0;c3=.;output;
id='s08';c1=99;c2=0;c3=.;output;
id='s09';c1=0;c2=.;c3=2;output;
run;
%n26_additive_geno2alleles(indsd=v6286i,snp_varnames=c1 c2 c3,sample_id=id,outdsd=v6286o);
data v6286m(keep=metric value);set v6286o;length metric $120;array a[*] $ m1 m2 m3 m4 m5 m6;do j=1 to dim(a);metric=catx(":",id,vname(a[j]));value=input(a[j],??best32.);output;end;run;

data v6286m;set v6286m;format value best32.;run;
proc export data=v6286m outfile="%sysfunc(pathname(work))/V6286.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6286;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6286:;quit;
