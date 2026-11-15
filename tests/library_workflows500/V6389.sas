/* New workflow V6389; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6389i;
length gene $80 grp $80 trait $80;
gene='id09';grp='g3';trait='t1';amount=.;output;
gene='id06';grp='g3';trait='t2';amount=835.05;output;
gene='id04';grp='g1';trait='t2';amount=712.03;output;
gene='id07';grp='g1';trait='t1';amount=968.06;output;
gene='id08';grp='g2';trait='t1';amount=540.07;output;
gene='id01';grp='g1';trait='t1';amount=926.0;output;
gene='id03';grp='g3';trait='t1';amount=988.02;output;
gene='id05';grp='g2';trait='t2';amount=164.04;output;
gene='id02';grp='g2';trait='t1';amount=64.01;output;
run;
%n26_AddMissingTag4Grps(dsdin=v6389i,grp_vars=grp,value_var=amount,varname4missingtag=mtag,dsdout=v6389o);
data v6389m(keep=metric value);set v6389o;length metric $120;array measured[*] mtag;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6389m;set v6389m;format value best32.;run;
proc export data=v6389m outfile="%sysfunc(pathname(work))/V6389.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6389;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6389:;quit;
