/* New workflow V6300; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6300i;
length id $80;
id='s01';c1=1;c2=0;output;
id='s02';c1=.;c2=99;output;
id='s03';c1=.;c2=1;output;
id='s04';c1=0;c2=.;output;
id='s05';c1=1;c2=.;output;
id='s06';c1=.;c2=0;output;
id='s07';c1=0;c2=.;output;
id='s08';c1=99;c2=0;output;
id='s09';c1=0;c2=1;output;
run;
%n26_additive_geno2alleles(indsd=v6300i,snp_varnames=c1 c2,sample_id=id,outdsd=v6300o);
data v6300m(keep=metric value);set v6300o;length metric $120;array a[*] $ m1 m2 m3 m4;do j=1 to dim(a);metric=catx(":",id,vname(a[j]));value=input(a[j],??best32.);output;end;run;

data v6300m;set v6300m;format value best32.;run;
proc export data=v6300m outfile="%sysfunc(pathname(work))/V6300.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6300;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6300:;quit;
