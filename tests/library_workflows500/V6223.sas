/* New workflow V6223; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6223i;
length gene $80 grp $80 trait $80;
gene='id01';grp='g1';trait='t1';amount=447.0;output;
gene='id07';grp='g1';trait='t1';amount=289.06;output;
gene='id06';grp='g3';trait='t2';amount=864.05;output;
gene='id02';grp='g2';trait='t1';amount=766.01;output;
gene='id09';grp='g3';trait='t1';amount=386.08;output;
gene='id03';grp='g3';trait='t1';amount=409.02;output;
gene='id10';grp='g1';trait='t2';amount=242.09;output;
gene='id08';grp='g2';trait='t1';amount=538.07;output;
gene='id05';grp='g2';trait='t2';amount=819.04;output;
gene='id04';grp='g1';trait='t2';amount=329.03;output;
run;
%n26_char_grp_to_num_grp(dsdin=v6223i,grp_vars4sort=grp,descending_or_not=1,dsdout=v6223o,num_grp_output_name=code,keep_uniq_rows_by_grp=1);
data v6223m(keep=metric value);set v6223o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6223m;set v6223m;format value best32.;run;
proc export data=v6223m outfile="%sysfunc(pathname(work))/V6223.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6223;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6223:;quit;
