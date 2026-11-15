/* New workflow V6391; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6391i;
length gene $80 grp $80 trait $80;
gene='id09';grp='g3';trait='t1';amount=.;output;
gene='id06';grp='g3';trait='t2';amount=39.05;output;
gene='id11';grp='g2';trait='t2';amount=568.1;output;
gene='id01';grp='g1';trait='t1';amount=516.0;output;
gene='id04';grp='g1';trait='t2';amount=120.03;output;
gene='id07';grp='g1';trait='t1';amount=429.06;output;
gene='id10';grp='g1';trait='t2';amount=984.09;output;
gene='id08';grp='g2';trait='t1';amount=760.07;output;
gene='id02';grp='g2';trait='t1';amount=42.01;output;
gene='id03';grp='g3';trait='t1';amount=371.02;output;
gene='id05';grp='g2';trait='t2';amount=795.04;output;
run;
%n26_AddMissingTag4Grps(dsdin=v6391i,grp_vars=grp,value_var=amount,varname4missingtag=mtag,dsdout=v6391o);
data v6391m(keep=metric value);set v6391o;length metric $120;array measured[*] mtag;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6391m;set v6391m;format value best32.;run;
proc export data=v6391m outfile="%sysfunc(pathname(work))/V6391.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6391;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6391:;quit;
