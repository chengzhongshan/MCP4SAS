/* New workflow V6398; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6398i;
length gene $80 grp $80 trait $80;
gene='id01';grp='g1';trait='t1';amount=.;output;
gene='id07';grp='g1';trait='t1';amount=444.06;output;
gene='id02';grp='g2';trait='t1';amount=691.01;output;
gene='id08';grp='g2';trait='t1';amount=182.07;output;
gene='id09';grp='g3';trait='t1';amount=81.08;output;
gene='id06';grp='g3';trait='t2';amount=386.05;output;
gene='id11';grp='g2';trait='t2';amount=593.1;output;
gene='id04';grp='g1';trait='t2';amount=562.03;output;
gene='id10';grp='g1';trait='t2';amount=561.09;output;
gene='id05';grp='g2';trait='t2';amount=666.04;output;
gene='id03';grp='g3';trait='t1';amount=318.02;output;
run;
%n26_AddMissingTag4Grps(dsdin=v6398i,grp_vars=grp,value_var=amount,varname4missingtag=mtag,dsdout=v6398o);
data v6398m(keep=metric value);set v6398o;length metric $120;array measured[*] mtag;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6398m;set v6398m;format value best32.;run;
proc export data=v6398m outfile="%sysfunc(pathname(work))/V6398.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6398;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6398:;quit;
