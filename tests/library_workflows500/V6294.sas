/* New workflow V6294; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6294i;
length id $80;
id='s01';c1=2;c2=2;c3=0;c4=1;c5=0;c6=99;output;
id='s02';c1=0;c2=99;c3=1;c4=0;c5=0;c6=.;output;
id='s03';c1=2;c2=.;c3=1;c4=2;c5=0;c6=99;output;
run;
%n26_additive_geno2alleles(indsd=v6294i,snp_varnames=c1 c2 c3 c4 c5 c6,sample_id=id,outdsd=v6294o);
data v6294m(keep=metric value);set v6294o;length metric $120;array a[*] $ m1 m2 m3 m4 m5 m6 m7 m8 m9 m10 m11 m12;do j=1 to dim(a);metric=catx(":",id,vname(a[j]));value=input(a[j],??best32.);output;end;run;

data v6294m;set v6294m;format value best32.;run;
proc export data=v6294m outfile="%sysfunc(pathname(work))/V6294.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6294;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6294:;quit;
