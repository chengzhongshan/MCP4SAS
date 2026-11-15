/* New workflow V6384; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6384i;
length gene $80 grp $80 trait $80;
gene='id06';grp='g3';trait='t2';amount=.;output;
gene='id10';grp='g1';trait='t2';amount=93.09;output;
gene='id05';grp='g2';trait='t2';amount=932.04;output;
gene='id01';grp='g1';trait='t1';amount=395.0;output;
gene='id09';grp='g3';trait='t1';amount=74.08;output;
gene='id08';grp='g2';trait='t1';amount=353.07;output;
gene='id04';grp='g1';trait='t2';amount=897.03;output;
gene='id02';grp='g2';trait='t1';amount=477.01;output;
gene='id03';grp='g3';trait='t1';amount=966.02;output;
gene='id11';grp='g2';trait='t2';amount=640.1;output;
gene='id07';grp='g1';trait='t1';amount=498.06;output;
run;
%n26_AddMissingTag4Grps(dsdin=v6384i,grp_vars=grp,value_var=amount,varname4missingtag=mtag,dsdout=v6384o);
data v6384m(keep=metric value);set v6384o;length metric $120;array measured[*] mtag;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6384m;set v6384m;format value best32.;run;
proc export data=v6384m outfile="%sysfunc(pathname(work))/V6384.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6384;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6384:;quit;
