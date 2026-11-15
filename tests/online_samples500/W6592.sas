/* New workflow W6592; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6592i;
length grp $80;
grp='g1';eff=-0.41305764559207003;veff=0.1690774789554798;output;
grp='g2';eff=-0.5973266045141333;veff=0.023950770258129;output;
grp='g3';eff=-0.2120585833053733;veff=0.06440709640510502;output;
grp='g1';eff=0.42735454642802995;veff=0.14460461013772954;output;
grp='g2';eff=0.7893158134484146;veff=0.33267449585896347;output;
grp='g3';eff=0.1598967293329816;veff=0.20367099790298035;output;
grp='g1';eff=0.7926148063708838;veff=0.06782215360611801;output;
grp='g2';eff=-0.10026529484398505;veff=0.314163985011938;output;
grp='g3';eff=-0.011961207844424337;veff=0.10535113336430733;output;
grp='g1';eff=0.08377669397050769;veff=0.09511457331177091;output;
grp='g2';eff=0.562639067349874;veff=0.34641225237783685;output;
grp='g3';eff=-0.7159501289014668;veff=0.14312606363848462;output;
run;
%let varlist=grp;
%n26_wavgeff(w6592i,w6592o,0.8);run;
data w6592m(keep=metric value);set w6592o;length metric $120;array measured[*] estimate variance lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6592m;set w6592m;format value best32.;run;
proc export data=w6592m outfile="%sysfunc(pathname(work))/W6592.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6592;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6592:;quit;
