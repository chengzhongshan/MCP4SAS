/* New workflow V6412; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6412i;
length gene $80;
gene='v01';pos=28;output;
gene='v02';pos=59;output;
gene='v03';pos=65;output;
gene='v04';pos=81;output;
gene='v05';pos=90;output;
gene='v06';pos=129;output;
gene='v07';pos=162;output;
gene='v08';pos=222;output;
run;
%n26_adjust_close_positions(indsd=v6412i,outdsd=v6412o,pos_var=pos,new_pos_var=display_pos,make_even_pos=1,dist_pct_to_cluster_pos=1,fixed_min_pos=0,fixed_max_pos=1120);
data v6412m(keep=metric value);set v6412o;length metric $120;array measured[*] display_pos;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6412m;set v6412m;format value best32.;run;
proc export data=v6412m outfile="%sysfunc(pathname(work))/V6412.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6412;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6412:;quit;
