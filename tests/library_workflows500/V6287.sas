/* New workflow V6287; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6287i;
length id $80;
id='s01';c1=.;c2=2;c3=2;c4=0;output;
id='s02';c1=1;c2=99;c3=1;c4=0;output;
id='s03';c1=2;c2=0;c3=2;c4=99;output;
run;
%n26_additive_geno2alleles(indsd=v6287i,snp_varnames=c1 c2 c3 c4,sample_id=id,outdsd=v6287o);
data v6287m(keep=metric value);set v6287o;length metric $120;array a[*] $ m1 m2 m3 m4 m5 m6 m7 m8;do j=1 to dim(a);metric=catx(":",id,vname(a[j]));value=input(a[j],??best32.);output;end;run;

data v6287m;set v6287m;format value best32.;run;
proc export data=v6287m outfile="%sysfunc(pathname(work))/V6287.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6287;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6287:;quit;
