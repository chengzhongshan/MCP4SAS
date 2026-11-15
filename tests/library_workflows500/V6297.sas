/* New workflow V6297; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6297i;
length id $80;
id='s01';c1=99;c2=.;c3=99;c4=0;output;
id='s02';c1=1;c2=0;c3=0;c4=.;output;
id='s03';c1=0;c2=99;c3=0;c4=.;output;
id='s04';c1=.;c2=0;c3=.;c4=.;output;
id='s05';c1=0;c2=0;c3=.;c4=1;output;
id='s06';c1=99;c2=0;c3=.;c4=0;output;
run;
%n26_additive_geno2alleles(indsd=v6297i,snp_varnames=c1 c2 c3 c4,sample_id=id,outdsd=v6297o);
data v6297m(keep=metric value);set v6297o;length metric $120;array a[*] $ m1 m2 m3 m4 m5 m6 m7 m8;do j=1 to dim(a);metric=catx(":",id,vname(a[j]));value=input(a[j],??best32.);output;end;run;

data v6297m;set v6297m;format value best32.;run;
proc export data=v6297m outfile="%sysfunc(pathname(work))/V6297.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6297;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6297:;quit;
