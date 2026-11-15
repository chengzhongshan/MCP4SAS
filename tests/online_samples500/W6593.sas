/* New workflow W6593; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6593i;
length grp $80;
grp='g1';eff=0.7253606391423582;veff=0.3930747866477347;output;
grp='g2';eff=-0.7016400745238625;veff=0.10106462681771616;output;
grp='g3';eff=-0.2456884485385732;veff=0.03750858334687843;output;
grp='g1';eff=0.13780086799463487;veff=0.07308390085452265;output;
grp='g2';eff=0.62612376115546;veff=0.269477636404291;output;
grp='g3';eff=-0.7041390218987704;veff=0.160768577311633;output;
grp='g1';eff=0.1893389511880661;veff=0.22641986280951823;output;
grp='g2';eff=-0.4254832606102135;veff=0.1818891292327682;output;
grp='g3';eff=0.7395482195118668;veff=0.11573532360114222;output;
grp='g1';eff=-0.1313096408414821;veff=0.18425245547854674;output;
grp='g2';eff=-0.4411629879878616;veff=0.21451291703003766;output;
grp='g3';eff=-0.4500805569002327;veff=0.36635289919458747;output;
grp='g1';eff=0.6783912236465213;veff=0.0972558737524825;output;
run;
%let varlist=grp;
%n26_wavgeff(w6593i,w6593o,0.9);run;
data w6593m(keep=metric value);set w6593o;length metric $120;array measured[*] estimate variance lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6593m;set w6593m;format value best32.;run;
proc export data=w6593m outfile="%sysfunc(pathname(work))/W6593.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6593;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6593:;quit;
