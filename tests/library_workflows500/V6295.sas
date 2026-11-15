/* New workflow V6295; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6295i;
length id $80;
id='s01';c1=2;c2=0;output;
id='s02';c1=0;c2=.;output;
id='s03';c1=1;c2=.;output;
id='s04';c1=0;c2=2;output;
run;
%n26_additive_geno2alleles(indsd=v6295i,snp_varnames=c1 c2,sample_id=id,outdsd=v6295o);
data v6295m(keep=metric value);set v6295o;length metric $120;array a[*] $ m1 m2 m3 m4;do j=1 to dim(a);metric=catx(":",id,vname(a[j]));value=input(a[j],??best32.);output;end;run;

data v6295m;set v6295m;format value best32.;run;
proc export data=v6295m outfile="%sysfunc(pathname(work))/V6295.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6295;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6295:;quit;
