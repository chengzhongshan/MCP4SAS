/* New workflow V6392; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6392i;
length gene $80 grp $80 trait $80;
gene='id04';grp='g1';trait='t2';amount=.;output;
gene='id06';grp='g3';trait='t2';amount=722.05;output;
gene='id12';grp='g3';trait='t2';amount=123.11;output;
gene='id05';grp='g2';trait='t2';amount=934.04;output;
gene='id10';grp='g1';trait='t2';amount=820.09;output;
gene='id08';grp='g2';trait='t1';amount=634.07;output;
gene='id09';grp='g3';trait='t1';amount=330.08;output;
gene='id02';grp='g2';trait='t1';amount=904.01;output;
gene='id01';grp='g1';trait='t1';amount=643.0;output;
gene='id07';grp='g1';trait='t1';amount=165.06;output;
gene='id03';grp='g3';trait='t1';amount=505.02;output;
gene='id11';grp='g2';trait='t2';amount=100.1;output;
run;
%n26_AddMissingTag4Grps(dsdin=v6392i,grp_vars=grp,value_var=amount,varname4missingtag=mtag,dsdout=v6392o);
data v6392m(keep=metric value);set v6392o;length metric $120;array measured[*] mtag;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6392m;set v6392m;format value best32.;run;
proc export data=v6392m outfile="%sysfunc(pathname(work))/V6392.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6392;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6392:;quit;
