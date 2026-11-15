/* New workflow V6403; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6403i;
length gene $80;
gene='v01';pos=16;output;
gene='v02';pos=44;output;
gene='v03';pos=45;output;
gene='v04';pos=55;output;
gene='v05';pos=141;output;
gene='v06';pos=205;output;
run;
%n26_adjust_close_positions(indsd=v6403i,outdsd=v6403o,pos_var=pos,new_pos_var=display_pos,make_even_pos=1,dist_pct_to_cluster_pos=1,fixed_min_pos=0,fixed_max_pos=1030);
data v6403m(keep=metric value);set v6403o;length metric $120;array measured[*] display_pos;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6403m;set v6403m;format value best32.;run;
proc export data=v6403m outfile="%sysfunc(pathname(work))/V6403.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6403;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6403:;quit;
