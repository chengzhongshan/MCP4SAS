/* New workflow V6257; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6257i;
length gene $80 grp $80 trait $80;
gene='id06';grp='g3';trait='t2';amount=145.05;output;
gene='id10';grp='g1';trait='t2';amount=680.09;output;
gene='id07';grp='g1';trait='t1';amount=772.06;output;
gene='id02';grp='g2';trait='t1';amount=77.01;output;
gene='id04';grp='g1';trait='t2';amount=295.03;output;
gene='id01';grp='g1';trait='t1';amount=211.0;output;
gene='id09';grp='g3';trait='t1';amount=412.08;output;
gene='id08';grp='g2';trait='t1';amount=151.07;output;
gene='id03';grp='g3';trait='t1';amount=410.02;output;
gene='id05';grp='g2';trait='t2';amount=767.04;output;
run;
%n26_char_grp_to_num_grp4dups(dsdin=v6257i,grp_vars4sort=grp trait,descending_or_not=0,dsdout=v6257o,num_grp_output_name=code);
data v6257m(keep=metric value);set v6257o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6257m;set v6257m;format value best32.;run;
proc export data=v6257m outfile="%sysfunc(pathname(work))/V6257.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6257;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6257:;quit;
