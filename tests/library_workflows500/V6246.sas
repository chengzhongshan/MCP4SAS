/* New workflow V6246; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6246i;
length gene $80 grp $80 trait $80;
gene='id02';grp='g2';trait='t1';amount=302.01;output;
gene='id10';grp='g1';trait='t2';amount=121.09;output;
gene='id13';grp='g1';trait='t1';amount=973.12;output;
gene='id04';grp='g1';trait='t2';amount=913.03;output;
gene='id01';grp='g1';trait='t1';amount=851.0;output;
gene='id03';grp='g3';trait='t1';amount=923.02;output;
gene='id11';grp='g2';trait='t2';amount=629.1;output;
gene='id09';grp='g3';trait='t1';amount=628.08;output;
gene='id06';grp='g3';trait='t2';amount=707.05;output;
gene='id05';grp='g2';trait='t2';amount=266.04;output;
gene='id07';grp='g1';trait='t1';amount=597.06;output;
gene='id12';grp='g3';trait='t2';amount=161.11;output;
gene='id08';grp='g2';trait='t1';amount=577.07;output;
run;
%n26_char_grp_to_num_grp4dups(dsdin=v6246i,grp_vars4sort=grp trait,descending_or_not=0,dsdout=v6246o,num_grp_output_name=code);
data v6246m(keep=metric value);set v6246o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6246m;set v6246m;format value best32.;run;
proc export data=v6246m outfile="%sysfunc(pathname(work))/V6246.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6246;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6246:;quit;
