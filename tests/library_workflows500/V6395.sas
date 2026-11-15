/* New workflow V6395; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6395i;
length gene $80 grp $80 trait $80;
gene='id03';grp='g3';trait='t1';amount=889.02;output;
gene='id04';grp='g1';trait='t2';amount=890.03;output;
gene='id06';grp='g3';trait='t2';amount=417.05;output;
gene='id02';grp='g2';trait='t1';amount=.;output;
gene='id08';grp='g2';trait='t1';amount=948.07;output;
gene='id01';grp='g1';trait='t1';amount=3.0;output;
gene='id07';grp='g1';trait='t1';amount=200.06;output;
gene='id05';grp='g2';trait='t2';amount=114.04;output;
run;
%n26_AddMissingTag4Grps(dsdin=v6395i,grp_vars=grp,value_var=amount,varname4missingtag=mtag,dsdout=v6395o);
data v6395m(keep=metric value);set v6395o;length metric $120;array measured[*] mtag;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6395m;set v6395m;format value best32.;run;
proc export data=v6395m outfile="%sysfunc(pathname(work))/V6395.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6395;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6395:;quit;
