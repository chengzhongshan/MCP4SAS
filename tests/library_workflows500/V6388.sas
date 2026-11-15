/* New workflow V6388; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6388i;
length gene $80 grp $80 trait $80;
gene='id03';grp='g3';trait='t1';amount=.;output;
gene='id06';grp='g3';trait='t2';amount=958.05;output;
gene='id02';grp='g2';trait='t1';amount=593.01;output;
gene='id05';grp='g2';trait='t2';amount=280.04;output;
gene='id07';grp='g1';trait='t1';amount=668.06;output;
gene='id01';grp='g1';trait='t1';amount=480.0;output;
gene='id04';grp='g1';trait='t2';amount=99.03;output;
gene='id08';grp='g2';trait='t1';amount=63.07;output;
run;
%n26_AddMissingTag4Grps(dsdin=v6388i,grp_vars=grp,value_var=amount,varname4missingtag=mtag,dsdout=v6388o);
data v6388m(keep=metric value);set v6388o;length metric $120;array measured[*] mtag;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6388m;set v6388m;format value best32.;run;
proc export data=v6388m outfile="%sysfunc(pathname(work))/V6388.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6388;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6388:;quit;
