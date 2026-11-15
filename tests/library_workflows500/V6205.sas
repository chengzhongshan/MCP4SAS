/* New workflow V6205; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6205i;
length gene $80 grp $80 trait $80;
gene='id07';grp='g1';trait='t1';amount=311.06;output;
gene='id12';grp='g3';trait='t2';amount=569.11;output;
gene='id05';grp='g2';trait='t2';amount=482.04;output;
gene='id11';grp='g2';trait='t2';amount=882.1;output;
gene='id02';grp='g2';trait='t1';amount=105.01;output;
gene='id06';grp='g3';trait='t2';amount=574.05;output;
gene='id10';grp='g1';trait='t2';amount=960.09;output;
gene='id03';grp='g3';trait='t1';amount=956.02;output;
gene='id08';grp='g2';trait='t1';amount=989.07;output;
gene='id01';grp='g1';trait='t1';amount=439.0;output;
gene='id09';grp='g3';trait='t1';amount=141.08;output;
gene='id04';grp='g1';trait='t2';amount=73.03;output;
run;
%n26_char_grp_to_num_grp(dsdin=v6205i,grp_vars4sort=grp,descending_or_not=0,dsdout=v6205o,num_grp_output_name=code,keep_uniq_rows_by_grp=0);
data v6205m(keep=metric value);set v6205o;length metric $120;array measured[*] code;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6205m;set v6205m;format value best32.;run;
proc export data=v6205m outfile="%sysfunc(pathname(work))/V6205.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6205;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6205:;quit;
