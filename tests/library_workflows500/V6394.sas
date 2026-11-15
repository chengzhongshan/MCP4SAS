/* New workflow V6394; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6394i;
length gene $80 grp $80 trait $80;
gene='id07';grp='g1';trait='t1';amount=.;output;
gene='id06';grp='g3';trait='t2';amount=458.05;output;
gene='id01';grp='g1';trait='t1';amount=10.0;output;
gene='id04';grp='g1';trait='t2';amount=118.03;output;
gene='id05';grp='g2';trait='t2';amount=865.04;output;
gene='id02';grp='g2';trait='t1';amount=813.01;output;
gene='id03';grp='g3';trait='t1';amount=260.02;output;
run;
%n26_AddMissingTag4Grps(dsdin=v6394i,grp_vars=grp,value_var=amount,varname4missingtag=mtag,dsdout=v6394o);
data v6394m(keep=metric value);set v6394o;length metric $120;array measured[*] mtag;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6394m;set v6394m;format value best32.;run;
proc export data=v6394m outfile="%sysfunc(pathname(work))/V6394.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6394;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6394:;quit;
