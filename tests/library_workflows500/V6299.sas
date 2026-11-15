/* New workflow V6299; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6299i;
length id $80;
id='s01';c1=2;c2=.;c3=1;c4=2;c5=0;c6=0;output;
id='s02';c1=.;c2=.;c3=0;c4=1;c5=0;c6=.;output;
id='s03';c1=99;c2=0;c3=2;c4=99;c5=.;c6=0;output;
id='s04';c1=0;c2=0;c3=.;c4=2;c5=0;c6=0;output;
id='s05';c1=0;c2=0;c3=0;c4=1;c5=99;c6=.;output;
id='s06';c1=0;c2=0;c3=99;c4=0;c5=0;c6=99;output;
id='s07';c1=0;c2=.;c3=1;c4=0;c5=0;c6=0;output;
id='s08';c1=0;c2=2;c3=.;c4=2;c5=1;c6=.;output;
run;
%n26_additive_geno2alleles(indsd=v6299i,snp_varnames=c1 c2 c3 c4 c5 c6,sample_id=id,outdsd=v6299o);
data v6299m(keep=metric value);set v6299o;length metric $120;array a[*] $ m1 m2 m3 m4 m5 m6 m7 m8 m9 m10 m11 m12;do j=1 to dim(a);metric=catx(":",id,vname(a[j]));value=input(a[j],??best32.);output;end;run;

data v6299m;set v6299m;format value best32.;run;
proc export data=v6299m outfile="%sysfunc(pathname(work))/V6299.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6299;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6299:;quit;
