/* New workflow V6385; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6385i;
length gene $80 grp $80 trait $80;
gene='id06';grp='g3';trait='t2';amount=.;output;
gene='id10';grp='g1';trait='t2';amount=247.09;output;
gene='id12';grp='g3';trait='t2';amount=127.11;output;
gene='id08';grp='g2';trait='t1';amount=222.07;output;
gene='id01';grp='g1';trait='t1';amount=489.0;output;
gene='id03';grp='g3';trait='t1';amount=552.02;output;
gene='id04';grp='g1';trait='t2';amount=405.03;output;
gene='id11';grp='g2';trait='t2';amount=353.1;output;
gene='id02';grp='g2';trait='t1';amount=364.01;output;
gene='id05';grp='g2';trait='t2';amount=652.04;output;
gene='id07';grp='g1';trait='t1';amount=577.06;output;
gene='id09';grp='g3';trait='t1';amount=496.08;output;
run;
%n26_AddMissingTag4Grps(dsdin=v6385i,grp_vars=grp,value_var=amount,varname4missingtag=mtag,dsdout=v6385o);
data v6385m(keep=metric value);set v6385o;length metric $120;array measured[*] mtag;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6385m;set v6385m;format value best32.;run;
proc export data=v6385m outfile="%sysfunc(pathname(work))/V6385.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6385;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6385:;quit;
