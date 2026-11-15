/* New workflow V6240; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6240i;
length gene $80 grp $80 trait $80;
gene='id07';grp='g1';trait='t1';amount=781.06;output;
gene='id06';grp='g3';trait='t2';amount=724.05;output;
gene='id05';grp='g2';trait='t2';amount=556.04;output;
gene='id10';grp='g1';trait='t2';amount=493.09;output;
gene='id12';grp='g3';trait='t2';amount=388.11;output;
gene='id02';grp='g2';trait='t1';amount=774.01;output;
gene='id03';grp='g3';trait='t1';amount=31.02;output;
gene='id13';grp='g1';trait='t1';amount=531.12;output;
gene='id11';grp='g2';trait='t2';amount=46.1;output;
gene='id09';grp='g3';trait='t1';amount=93.08;output;
gene='id01';grp='g1';trait='t1';amount=361.0;output;
gene='id08';grp='g2';trait='t1';amount=573.07;output;
gene='id04';grp='g1';trait='t2';amount=861.03;output;
run;
%n26_char_grp_to_num_grp(dsdin=v6240i,grp_vars4sort=grp,descending_or_not=1,dsdout=v6240o,num_grp_output_name=code,keep_uniq_rows_by_grp=1);
data v6240m(keep=metric value);set v6240o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6240m;set v6240m;format value best32.;run;
proc export data=v6240m outfile="%sysfunc(pathname(work))/V6240.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6240;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6240:;quit;
