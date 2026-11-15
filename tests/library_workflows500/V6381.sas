/* New workflow V6381; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6381i;
length gene $80 grp $80 trait $80;
gene='id05';grp='g2';trait='t2';amount=679.04;output;
gene='id01';grp='g1';trait='t1';amount=.;output;
gene='id03';grp='g3';trait='t1';amount=156.02;output;
gene='id08';grp='g2';trait='t1';amount=832.07;output;
gene='id06';grp='g3';trait='t2';amount=666.05;output;
gene='id02';grp='g2';trait='t1';amount=328.01;output;
gene='id07';grp='g1';trait='t1';amount=360.06;output;
gene='id04';grp='g1';trait='t2';amount=538.03;output;
run;
%n26_AddMissingTag4Grps(dsdin=v6381i,grp_vars=grp,value_var=amount,varname4missingtag=mtag,dsdout=v6381o);
data v6381m(keep=metric value);set v6381o;length metric $120;array measured[*] mtag;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6381m;set v6381m;format value best32.;run;
proc export data=v6381m outfile="%sysfunc(pathname(work))/V6381.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6381;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6381:;quit;
