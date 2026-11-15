/* New workflow V6411; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6411i;
length gene $80;
gene='v01';pos=5;output;
gene='v02';pos=19;output;
gene='v03';pos=31;output;
gene='v04';pos=82;output;
gene='v05';pos=84;output;
gene='v06';pos=105;output;
gene='v07';pos=170;output;
run;
%n26_adjust_close_positions(indsd=v6411i,outdsd=v6411o,pos_var=pos,new_pos_var=display_pos,make_even_pos=1,dist_pct_to_cluster_pos=1,fixed_min_pos=0,fixed_max_pos=1110);
data v6411m(keep=metric value);set v6411o;length metric $120;array measured[*] display_pos;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6411m;set v6411m;format value best32.;run;
proc export data=v6411m outfile="%sysfunc(pathname(work))/V6411.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6411;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6411:;quit;
