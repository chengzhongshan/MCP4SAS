/* New workflow V6258; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6258i;
length gene $80 grp $80 trait $80;
gene='id03';grp='g3';trait='t1';amount=574.02;output;
gene='id08';grp='g2';trait='t1';amount=997.07;output;
gene='id05';grp='g2';trait='t2';amount=159.04;output;
gene='id06';grp='g3';trait='t2';amount=663.05;output;
gene='id01';grp='g1';trait='t1';amount=786.0;output;
gene='id02';grp='g2';trait='t1';amount=138.01;output;
gene='id11';grp='g2';trait='t2';amount=843.1;output;
gene='id09';grp='g3';trait='t1';amount=822.08;output;
gene='id07';grp='g1';trait='t1';amount=441.06;output;
gene='id10';grp='g1';trait='t2';amount=223.09;output;
gene='id04';grp='g1';trait='t2';amount=221.03;output;
run;
%n26_char_grp_to_num_grp4dups(dsdin=v6258i,grp_vars4sort=grp trait,descending_or_not=0,dsdout=v6258o,num_grp_output_name=code);
data v6258m(keep=metric value);set v6258o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6258m;set v6258m;format value best32.;run;
proc export data=v6258m outfile="%sysfunc(pathname(work))/V6258.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6258;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6258:;quit;
