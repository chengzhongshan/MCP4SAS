/* New workflow V6390; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6390i;
length gene $80 grp $80 trait $80;
gene='id09';grp='g3';trait='t1';amount=.;output;
gene='id05';grp='g2';trait='t2';amount=83.04;output;
gene='id02';grp='g2';trait='t1';amount=906.01;output;
gene='id07';grp='g1';trait='t1';amount=319.06;output;
gene='id06';grp='g3';trait='t2';amount=201.05;output;
gene='id10';grp='g1';trait='t2';amount=3.09;output;
gene='id01';grp='g1';trait='t1';amount=183.0;output;
gene='id08';grp='g2';trait='t1';amount=636.07;output;
gene='id03';grp='g3';trait='t1';amount=948.02;output;
gene='id04';grp='g1';trait='t2';amount=786.03;output;
run;
%n26_AddMissingTag4Grps(dsdin=v6390i,grp_vars=grp,value_var=amount,varname4missingtag=mtag,dsdout=v6390o);
data v6390m(keep=metric value);set v6390o;length metric $120;array measured[*] mtag;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6390m;set v6390m;format value best32.;run;
proc export data=v6390m outfile="%sysfunc(pathname(work))/V6390.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6390;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6390:;quit;
