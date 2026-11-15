/* New workflow V6393; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6393i;
length gene $80 grp $80 trait $80;
gene='id13';grp='g1';trait='t1';amount=.;output;
gene='id04';grp='g1';trait='t2';amount=156.03;output;
gene='id07';grp='g1';trait='t1';amount=485.06;output;
gene='id02';grp='g2';trait='t1';amount=914.01;output;
gene='id08';grp='g2';trait='t1';amount=990.07;output;
gene='id01';grp='g1';trait='t1';amount=718.0;output;
gene='id11';grp='g2';trait='t2';amount=465.1;output;
gene='id03';grp='g3';trait='t1';amount=507.02;output;
gene='id10';grp='g1';trait='t2';amount=644.09;output;
gene='id12';grp='g3';trait='t2';amount=987.11;output;
gene='id05';grp='g2';trait='t2';amount=422.04;output;
gene='id06';grp='g3';trait='t2';amount=80.05;output;
gene='id09';grp='g3';trait='t1';amount=702.08;output;
run;
%n26_AddMissingTag4Grps(dsdin=v6393i,grp_vars=grp,value_var=amount,varname4missingtag=mtag,dsdout=v6393o);
data v6393m(keep=metric value);set v6393o;length metric $120;array measured[*] mtag;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6393m;set v6393m;format value best32.;run;
proc export data=v6393m outfile="%sysfunc(pathname(work))/V6393.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6393;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6393:;quit;
