/* New workflow W6585; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6585i;
length grp $80;
grp='g1';eff=0.4529127733412541;veff=0.2934665946382577;output;
grp='g2';eff=0.4690275335716396;veff=0.34893809031036294;output;
grp='g3';eff=-0.7271723384305565;veff=0.12613433003163013;output;
grp='g1';eff=0.13969071728774352;veff=0.046270815886031394;output;
grp='g2';eff=-0.6512029346272584;veff=0.257624524538396;output;
grp='g3';eff=0.6390015567033427;veff=0.08522912541253115;output;
grp='g1';eff=-0.5980564524606011;veff=0.3251482818575288;output;
grp='g2';eff=-0.6781332548324694;veff=0.031225633133685655;output;
grp='g3';eff=0.3531054472535533;veff=0.17284226745042156;output;
grp='g1';eff=0.8417398303362231;veff=0.22229930917281066;output;
grp='g2';eff=0.4794579318606418;veff=0.25077184133958824;output;
grp='g3';eff=-0.45858213174815393;veff=0.15668592261745393;output;
run;
%let varlist=grp;
%n26_wavgeff(w6585i,w6585o,0.9);run;
data w6585m(keep=metric value);set w6585o;length metric $120;array measured[*] estimate variance lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6585m;set w6585m;format value best32.;run;
proc export data=w6585m outfile="%sysfunc(pathname(work))/W6585.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6585;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6585:;quit;
