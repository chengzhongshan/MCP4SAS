/* New workflow V6386; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6386i;
length gene $80 grp $80 trait $80;
gene='id07';grp='g1';trait='t1';amount=44.06;output;
gene='id11';grp='g2';trait='t2';amount=945.1;output;
gene='id01';grp='g1';trait='t1';amount=683.0;output;
gene='id06';grp='g3';trait='t2';amount=.;output;
gene='id08';grp='g2';trait='t1';amount=905.07;output;
gene='id04';grp='g1';trait='t2';amount=61.03;output;
gene='id12';grp='g3';trait='t2';amount=32.11;output;
gene='id10';grp='g1';trait='t2';amount=680.09;output;
gene='id13';grp='g1';trait='t1';amount=644.12;output;
gene='id09';grp='g3';trait='t1';amount=324.08;output;
gene='id05';grp='g2';trait='t2';amount=130.04;output;
gene='id03';grp='g3';trait='t1';amount=91.02;output;
gene='id02';grp='g2';trait='t1';amount=143.01;output;
run;
%n26_AddMissingTag4Grps(dsdin=v6386i,grp_vars=grp,value_var=amount,varname4missingtag=mtag,dsdout=v6386o);
data v6386m(keep=metric value);set v6386o;length metric $120;array measured[*] mtag;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6386m;set v6386m;format value best32.;run;
proc export data=v6386m outfile="%sysfunc(pathname(work))/V6386.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6386;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6386:;quit;
