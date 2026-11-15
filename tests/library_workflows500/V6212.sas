/* New workflow V6212; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6212i;
length gene $80 grp $80 trait $80;
gene='id12';grp='g3';trait='t2';amount=205.11;output;
gene='id09';grp='g3';trait='t1';amount=427.08;output;
gene='id04';grp='g1';trait='t2';amount=335.03;output;
gene='id01';grp='g1';trait='t1';amount=566.0;output;
gene='id08';grp='g2';trait='t1';amount=976.07;output;
gene='id10';grp='g1';trait='t2';amount=247.09;output;
gene='id06';grp='g3';trait='t2';amount=704.05;output;
gene='id11';grp='g2';trait='t2';amount=582.1;output;
gene='id05';grp='g2';trait='t2';amount=232.04;output;
gene='id07';grp='g1';trait='t1';amount=877.06;output;
gene='id02';grp='g2';trait='t1';amount=603.01;output;
gene='id03';grp='g3';trait='t1';amount=295.02;output;
run;
%n26_char_grp_to_num_grp(dsdin=v6212i,grp_vars4sort=grp,descending_or_not=0,dsdout=v6212o,num_grp_output_name=code,keep_uniq_rows_by_grp=0);
data v6212m(keep=metric value);set v6212o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6212m;set v6212m;format value best32.;run;
proc export data=v6212m outfile="%sysfunc(pathname(work))/V6212.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6212;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6212:;quit;
