/* New workflow W6582; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6582i;
length grp $80;
grp='g1';eff=0.2643499524853101;veff=0.1346703515809626;output;
grp='g2';eff=-0.13240769982599698;veff=0.04420200427888642;output;
grp='g3';eff=0.8608686944087263;veff=0.20649393684023554;output;
grp='g1';eff=-0.6632285463643997;veff=0.022916447926949492;output;
grp='g2';eff=0.3366744474605279;veff=0.16651025064849878;output;
grp='g3';eff=-0.5566594917945751;veff=0.16449057014058427;output;
grp='g1';eff=0.6742061257339247;veff=0.3129298395454277;output;
grp='g2';eff=0.6243499424957564;veff=0.12486181881613789;output;
grp='g3';eff=-0.7427318892789087;veff=0.23890768102989396;output;
run;
%let varlist=grp;
%n26_wavgeff(w6582i,w6582o,0.95);run;
data w6582m(keep=metric value);set w6582o;length metric $120;array measured[*] estimate variance lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6582m;set w6582m;format value best32.;run;
proc export data=w6582m outfile="%sysfunc(pathname(work))/W6582.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6582;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6582:;quit;
