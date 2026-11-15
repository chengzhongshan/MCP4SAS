/* New workflow W6597; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6597i;
length grp $80;
grp='g1';eff=-0.5000340398699676;veff=0.27276676698241586;output;
grp='g2';eff=0.35181332022295386;veff=0.38426395833212473;output;
grp='g3';eff=0.18565160459182728;veff=0.34282670520130615;output;
grp='g1';eff=0.8353570804963331;veff=0.39384625184860844;output;
grp='g2';eff=0.568403028118158;veff=0.09781049922717543;output;
grp='g3';eff=0.7671512269637069;veff=0.1293895146304183;output;
grp='g1';eff=-0.40357057928541423;veff=0.31806595625439615;output;
grp='g2';eff=0.13961536744749703;veff=0.3912854054648821;output;
grp='g3';eff=0.8114312528751841;veff=0.23999829040251452;output;
grp='g1';eff=-0.26359688529566583;veff=0.1812530135324867;output;
run;
%let varlist=grp;
%n26_wavgeff(w6597i,w6597o,0.9);run;
data w6597m(keep=metric value);set w6597o;length metric $120;array measured[*] estimate variance lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6597m;set w6597m;format value best32.;run;
proc export data=w6597m outfile="%sysfunc(pathname(work))/W6597.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6597;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6597:;quit;
