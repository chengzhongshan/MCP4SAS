/* New workflow V6254; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6254i;
length gene $80 grp $80 trait $80;
gene='id01';grp='g1';trait='t1';amount=909.0;output;
gene='id02';grp='g2';trait='t1';amount=75.01;output;
gene='id06';grp='g3';trait='t2';amount=754.05;output;
gene='id03';grp='g3';trait='t1';amount=502.02;output;
gene='id04';grp='g1';trait='t2';amount=619.03;output;
gene='id05';grp='g2';trait='t2';amount=985.04;output;
gene='id07';grp='g1';trait='t1';amount=935.06;output;
run;
%n26_char_grp_to_num_grp4dups(dsdin=v6254i,grp_vars4sort=grp trait,descending_or_not=0,dsdout=v6254o,num_grp_output_name=code);
data v6254m(keep=metric value);set v6254o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6254m;set v6254m;format value best32.;run;
proc export data=v6254m outfile="%sysfunc(pathname(work))/V6254.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6254;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6254:;quit;
