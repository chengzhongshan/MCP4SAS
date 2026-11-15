/* New workflow V6260; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6260i;
length gene $80 grp $80 trait $80;
gene='id05';grp='g2';trait='t2';amount=307.04;output;
gene='id10';grp='g1';trait='t2';amount=130.09;output;
gene='id07';grp='g1';trait='t1';amount=28.06;output;
gene='id06';grp='g3';trait='t2';amount=653.05;output;
gene='id01';grp='g1';trait='t1';amount=508.0;output;
gene='id02';grp='g2';trait='t1';amount=615.01;output;
gene='id04';grp='g1';trait='t2';amount=622.03;output;
gene='id12';grp='g3';trait='t2';amount=336.11;output;
gene='id09';grp='g3';trait='t1';amount=414.08;output;
gene='id03';grp='g3';trait='t1';amount=169.02;output;
gene='id11';grp='g2';trait='t2';amount=540.1;output;
gene='id13';grp='g1';trait='t1';amount=830.12;output;
gene='id08';grp='g2';trait='t1';amount=609.07;output;
run;
%n26_char_grp_to_num_grp4dups(dsdin=v6260i,grp_vars4sort=grp trait,descending_or_not=0,dsdout=v6260o,num_grp_output_name=code);
data v6260m(keep=metric value);set v6260o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6260m;set v6260m;format value best32.;run;
proc export data=v6260m outfile="%sysfunc(pathname(work))/V6260.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6260;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6260:;quit;
