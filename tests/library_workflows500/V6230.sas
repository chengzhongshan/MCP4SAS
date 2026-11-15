/* New workflow V6230; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6230i;
length gene $80 grp $80 trait $80;
gene='id08';grp='g2';trait='t1';amount=614.07;output;
gene='id07';grp='g1';trait='t1';amount=946.06;output;
gene='id06';grp='g3';trait='t2';amount=965.05;output;
gene='id01';grp='g1';trait='t1';amount=112.0;output;
gene='id05';grp='g2';trait='t2';amount=693.04;output;
gene='id03';grp='g3';trait='t1';amount=81.02;output;
gene='id10';grp='g1';trait='t2';amount=632.09;output;
gene='id04';grp='g1';trait='t2';amount=434.03;output;
gene='id09';grp='g3';trait='t1';amount=903.08;output;
gene='id02';grp='g2';trait='t1';amount=299.01;output;
run;
%n26_char_grp_to_num_grp(dsdin=v6230i,grp_vars4sort=grp,descending_or_not=1,dsdout=v6230o,num_grp_output_name=code,keep_uniq_rows_by_grp=1);
data v6230m(keep=metric value);set v6230o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6230m;set v6230m;format value best32.;run;
proc export data=v6230m outfile="%sysfunc(pathname(work))/V6230.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6230;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6230:;quit;
