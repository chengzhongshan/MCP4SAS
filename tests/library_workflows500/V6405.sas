/* New workflow V6405; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6405i;
length gene $80;
gene='v01';pos=57;output;
gene='v02';pos=93;output;
gene='v03';pos=96;output;
gene='v04';pos=115;output;
gene='v05';pos=158;output;
gene='v06';pos=169;output;
gene='v07';pos=188;output;
gene='v08';pos=207;output;
run;
%n26_adjust_close_positions(indsd=v6405i,outdsd=v6405o,pos_var=pos,new_pos_var=display_pos,make_even_pos=1,dist_pct_to_cluster_pos=1,fixed_min_pos=0,fixed_max_pos=1050);
data v6405m(keep=metric value);set v6405o;length metric $120;array measured[*] display_pos;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6405m;set v6405m;format value best32.;run;
proc export data=v6405m outfile="%sysfunc(pathname(work))/V6405.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6405;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6405:;quit;
