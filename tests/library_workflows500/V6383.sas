/* New workflow V6383; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6383i;
length gene $80 grp $80 trait $80;
gene='id05';grp='g2';trait='t2';amount=.;output;
gene='id07';grp='g1';trait='t1';amount=89.06;output;
gene='id04';grp='g1';trait='t2';amount=84.03;output;
gene='id02';grp='g2';trait='t1';amount=842.01;output;
gene='id03';grp='g3';trait='t1';amount=38.02;output;
gene='id09';grp='g3';trait='t1';amount=157.08;output;
gene='id01';grp='g1';trait='t1';amount=92.0;output;
gene='id10';grp='g1';trait='t2';amount=215.09;output;
gene='id06';grp='g3';trait='t2';amount=304.05;output;
gene='id08';grp='g2';trait='t1';amount=779.07;output;
run;
%n26_AddMissingTag4Grps(dsdin=v6383i,grp_vars=grp,value_var=amount,varname4missingtag=mtag,dsdout=v6383o);
data v6383m(keep=metric value);set v6383o;length metric $120;array measured[*] mtag;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6383m;set v6383m;format value best32.;run;
proc export data=v6383m outfile="%sysfunc(pathname(work))/V6383.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6383;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6383:;quit;
