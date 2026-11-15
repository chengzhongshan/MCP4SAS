/* New workflow V6219; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6219i;
length gene $80 grp $80 trait $80;
gene='id05';grp='g2';trait='t2';amount=504.04;output;
gene='id04';grp='g1';trait='t2';amount=936.03;output;
gene='id10';grp='g1';trait='t2';amount=335.09;output;
gene='id07';grp='g1';trait='t1';amount=807.06;output;
gene='id12';grp='g3';trait='t2';amount=951.11;output;
gene='id03';grp='g3';trait='t1';amount=278.02;output;
gene='id01';grp='g1';trait='t1';amount=91.0;output;
gene='id11';grp='g2';trait='t2';amount=64.1;output;
gene='id08';grp='g2';trait='t1';amount=872.07;output;
gene='id06';grp='g3';trait='t2';amount=326.05;output;
gene='id02';grp='g2';trait='t1';amount=395.01;output;
gene='id09';grp='g3';trait='t1';amount=862.08;output;
run;
%n26_char_grp_to_num_grp(dsdin=v6219i,grp_vars4sort=grp,descending_or_not=0,dsdout=v6219o,num_grp_output_name=code,keep_uniq_rows_by_grp=0);
data v6219m(keep=metric value);set v6219o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6219m;set v6219m;format value best32.;run;
proc export data=v6219m outfile="%sysfunc(pathname(work))/V6219.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6219;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6219:;quit;
