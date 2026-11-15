/* New workflow V6407; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6407i;
length gene $80;
gene='v01';pos=19;output;
gene='v02';pos=20;output;
gene='v03';pos=54;output;
run;
%n26_adjust_close_positions(indsd=v6407i,outdsd=v6407o,pos_var=pos,new_pos_var=display_pos,make_even_pos=1,dist_pct_to_cluster_pos=1,fixed_min_pos=0,fixed_max_pos=1070);
data v6407m(keep=metric value);set v6407o;length metric $120;array measured[*] display_pos;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6407m;set v6407m;format value best32.;run;
proc export data=v6407m outfile="%sysfunc(pathname(work))/V6407.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6407;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6407:;quit;
