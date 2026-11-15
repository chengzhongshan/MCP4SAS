/* New workflow V6241; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6241i;
length gene $80 grp $80 trait $80;
gene='id08';grp='g2';trait='t1';amount=546.07;output;
gene='id07';grp='g1';trait='t1';amount=330.06;output;
gene='id04';grp='g1';trait='t2';amount=502.03;output;
gene='id06';grp='g3';trait='t2';amount=251.05;output;
gene='id02';grp='g2';trait='t1';amount=536.01;output;
gene='id03';grp='g3';trait='t1';amount=190.02;output;
gene='id01';grp='g1';trait='t1';amount=691.0;output;
gene='id05';grp='g2';trait='t2';amount=302.04;output;
run;
%n26_char_grp_to_num_grp4dups(dsdin=v6241i,grp_vars4sort=grp trait,descending_or_not=0,dsdout=v6241o,num_grp_output_name=code);
data v6241m(keep=metric value);set v6241o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6241m;set v6241m;format value best32.;run;
proc export data=v6241m outfile="%sysfunc(pathname(work))/V6241.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6241;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6241:;quit;
