/* New workflow V6409; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6409i;
length gene $80;
gene='v01';pos=30;output;
gene='v02';pos=113;output;
gene='v03';pos=129;output;
gene='v04';pos=162;output;
gene='v05';pos=201;output;
run;
%n26_adjust_close_positions(indsd=v6409i,outdsd=v6409o,pos_var=pos,new_pos_var=display_pos,make_even_pos=1,dist_pct_to_cluster_pos=1,fixed_min_pos=0,fixed_max_pos=1090);
data v6409m(keep=metric value);set v6409o;length metric $120;array measured[*] display_pos;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6409m;set v6409m;format value best32.;run;
proc export data=v6409m outfile="%sysfunc(pathname(work))/V6409.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6409;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6409:;quit;
