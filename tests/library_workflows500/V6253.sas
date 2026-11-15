/* New workflow V6253; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6253i;
length gene $80 grp $80 trait $80;
gene='id06';grp='g3';trait='t2';amount=599.05;output;
gene='id12';grp='g3';trait='t2';amount=474.11;output;
gene='id07';grp='g1';trait='t1';amount=970.06;output;
gene='id11';grp='g2';trait='t2';amount=327.1;output;
gene='id10';grp='g1';trait='t2';amount=231.09;output;
gene='id08';grp='g2';trait='t1';amount=996.07;output;
gene='id13';grp='g1';trait='t1';amount=63.12;output;
gene='id09';grp='g3';trait='t1';amount=18.08;output;
gene='id05';grp='g2';trait='t2';amount=578.04;output;
gene='id01';grp='g1';trait='t1';amount=469.0;output;
gene='id04';grp='g1';trait='t2';amount=504.03;output;
gene='id03';grp='g3';trait='t1';amount=917.02;output;
gene='id02';grp='g2';trait='t1';amount=560.01;output;
run;
%n26_char_grp_to_num_grp4dups(dsdin=v6253i,grp_vars4sort=grp trait,descending_or_not=0,dsdout=v6253o,num_grp_output_name=code);
data v6253m(keep=metric value);set v6253o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6253m;set v6253m;format value best32.;run;
proc export data=v6253m outfile="%sysfunc(pathname(work))/V6253.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6253;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6253:;quit;
