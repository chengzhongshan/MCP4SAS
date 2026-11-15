/* New workflow V6192; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6192i;
length gene $80 grp $80 trait $80;
gene='id08';grp='g2';trait='t1';amount=412.07;output;
gene='id07';grp='g1';trait='t1';amount=359.06;output;
gene='id04';grp='g1';trait='t2';amount=406.03;output;
gene='id09';grp='g3';trait='t1';amount=195.08;output;
gene='id03';grp='g3';trait='t1';amount=671.02;output;
gene='id06';grp='g3';trait='t2';amount=577.05;output;
gene='id10';grp='g1';trait='t2';amount=438.09;output;
gene='id11';grp='g2';trait='t2';amount=619.1;output;
gene='id05';grp='g2';trait='t2';amount=303.04;output;
gene='id02';grp='g2';trait='t1';amount=865.01;output;
gene='id01';grp='g1';trait='t1';amount=138.0;output;
gene='id12';grp='g3';trait='t2';amount=683.11;output;
run;
%n26_number_rows_by_grp(dsdin=v6192i,grp_var=grp,num_var4sort=amount,descending_or_not=0,dsdout=v6192o);
data v6192m(keep=metric value);set v6192o;length metric $120;array measured[*] ord;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6192m;set v6192m;format value best32.;run;
proc export data=v6192m outfile="%sysfunc(pathname(work))/V6192.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6192;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6192:;quit;
