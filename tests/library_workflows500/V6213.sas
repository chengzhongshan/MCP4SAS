/* New workflow V6213; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6213i;
length gene $80 grp $80 trait $80;
gene='id13';grp='g1';trait='t1';amount=506.12;output;
gene='id04';grp='g1';trait='t2';amount=575.03;output;
gene='id11';grp='g2';trait='t2';amount=248.1;output;
gene='id06';grp='g3';trait='t2';amount=356.05;output;
gene='id01';grp='g1';trait='t1';amount=264.0;output;
gene='id10';grp='g1';trait='t2';amount=907.09;output;
gene='id08';grp='g2';trait='t1';amount=605.07;output;
gene='id02';grp='g2';trait='t1';amount=733.01;output;
gene='id03';grp='g3';trait='t1';amount=686.02;output;
gene='id05';grp='g2';trait='t2';amount=40.04;output;
gene='id12';grp='g3';trait='t2';amount=195.11;output;
gene='id07';grp='g1';trait='t1';amount=738.06;output;
gene='id09';grp='g3';trait='t1';amount=64.08;output;
run;
%n26_char_grp_to_num_grp(dsdin=v6213i,grp_vars4sort=grp,descending_or_not=0,dsdout=v6213o,num_grp_output_name=code,keep_uniq_rows_by_grp=0);
data v6213m(keep=metric value);set v6213o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6213m;set v6213m;format value best32.;run;
proc export data=v6213m outfile="%sysfunc(pathname(work))/V6213.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6213;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6213:;quit;
