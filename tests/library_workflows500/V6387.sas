/* New workflow V6387; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6387i;
length gene $80 grp $80 trait $80;
gene='id06';grp='g3';trait='t2';amount=.;output;
gene='id05';grp='g2';trait='t2';amount=606.04;output;
gene='id01';grp='g1';trait='t1';amount=251.0;output;
gene='id03';grp='g3';trait='t1';amount=307.02;output;
gene='id04';grp='g1';trait='t2';amount=104.03;output;
gene='id07';grp='g1';trait='t1';amount=238.06;output;
gene='id02';grp='g2';trait='t1';amount=240.01;output;
run;
%n26_AddMissingTag4Grps(dsdin=v6387i,grp_vars=grp,value_var=amount,varname4missingtag=mtag,dsdout=v6387o);
data v6387m(keep=metric value);set v6387o;length metric $120;array measured[*] mtag;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6387m;set v6387m;format value best32.;run;
proc export data=v6387m outfile="%sysfunc(pathname(work))/V6387.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6387;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6387:;quit;
