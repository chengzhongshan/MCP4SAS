/* New workflow V6396; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6396i;
length gene $80 grp $80 trait $80;
gene='id08';grp='g2';trait='t1';amount=127.07;output;
gene='id05';grp='g2';trait='t2';amount=72.04;output;
gene='id06';grp='g3';trait='t2';amount=.;output;
gene='id01';grp='g1';trait='t1';amount=596.0;output;
gene='id02';grp='g2';trait='t1';amount=451.01;output;
gene='id07';grp='g1';trait='t1';amount=466.06;output;
gene='id04';grp='g1';trait='t2';amount=81.03;output;
gene='id03';grp='g3';trait='t1';amount=435.02;output;
gene='id09';grp='g3';trait='t1';amount=818.08;output;
run;
%n26_AddMissingTag4Grps(dsdin=v6396i,grp_vars=grp,value_var=amount,varname4missingtag=mtag,dsdout=v6396o);
data v6396m(keep=metric value);set v6396o;length metric $120;array measured[*] mtag;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6396m;set v6396m;format value best32.;run;
proc export data=v6396m outfile="%sysfunc(pathname(work))/V6396.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6396;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6396:;quit;
