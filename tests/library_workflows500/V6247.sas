/* New workflow V6247; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6247i;
length gene $80 grp $80 trait $80;
gene='id02';grp='g2';trait='t1';amount=995.01;output;
gene='id07';grp='g1';trait='t1';amount=415.06;output;
gene='id05';grp='g2';trait='t2';amount=960.04;output;
gene='id06';grp='g3';trait='t2';amount=541.05;output;
gene='id01';grp='g1';trait='t1';amount=691.0;output;
gene='id04';grp='g1';trait='t2';amount=440.03;output;
gene='id03';grp='g3';trait='t1';amount=320.02;output;
run;
%n26_char_grp_to_num_grp4dups(dsdin=v6247i,grp_vars4sort=grp trait,descending_or_not=0,dsdout=v6247o,num_grp_output_name=code);
data v6247m(keep=metric value);set v6247o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6247m;set v6247m;format value best32.;run;
proc export data=v6247m outfile="%sysfunc(pathname(work))/V6247.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6247;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6247:;quit;
