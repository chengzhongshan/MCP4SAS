/* New workflow V6400; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6400i;
length gene $80 grp $80 trait $80;
gene='id03';grp='g3';trait='t1';amount=635.02;output;
gene='id04';grp='g1';trait='t2';amount=.;output;
gene='id07';grp='g1';trait='t1';amount=619.06;output;
gene='id09';grp='g3';trait='t1';amount=544.08;output;
gene='id02';grp='g2';trait='t1';amount=424.01;output;
gene='id12';grp='g3';trait='t2';amount=891.11;output;
gene='id06';grp='g3';trait='t2';amount=407.05;output;
gene='id13';grp='g1';trait='t1';amount=774.12;output;
gene='id01';grp='g1';trait='t1';amount=39.0;output;
gene='id11';grp='g2';trait='t2';amount=386.1;output;
gene='id08';grp='g2';trait='t1';amount=175.07;output;
gene='id05';grp='g2';trait='t2';amount=861.04;output;
gene='id10';grp='g1';trait='t2';amount=264.09;output;
run;
%n26_AddMissingTag4Grps(dsdin=v6400i,grp_vars=grp,value_var=amount,varname4missingtag=mtag,dsdout=v6400o);
data v6400m(keep=metric value);set v6400o;length metric $120;array measured[*] mtag;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6400m;set v6400m;format value best32.;run;
proc export data=v6400m outfile="%sysfunc(pathname(work))/V6400.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6400;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6400:;quit;
