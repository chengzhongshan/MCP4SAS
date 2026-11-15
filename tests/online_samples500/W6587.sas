/* New workflow W6587; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6587i;
length grp $80;
grp='g1';eff=0.3660282051440542;veff=0.043634293899848686;output;
grp='g2';eff=0.5339322904831878;veff=0.08094190269214419;output;
grp='g3';eff=0.04263606910972817;veff=0.2569216316643034;output;
grp='g1';eff=-0.2574910267630265;veff=0.28495014048412476;output;
grp='g2';eff=0.11923815438501939;veff=0.3740225097716914;output;
grp='g3';eff=0.35936552431839974;veff=0.1811227906034738;output;
grp='g1';eff=0.5812048546369823;veff=0.17290818210711906;output;
run;
%let varlist=grp;
%n26_wavgeff(w6587i,w6587o,0.99);run;
data w6587m(keep=metric value);set w6587o;length metric $120;array measured[*] estimate variance lower upper level;do _measure=1 to dim(measured);metric=catx(':',strip(grp),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6587m;set w6587m;format value best32.;run;
proc export data=w6587m outfile="%sysfunc(pathname(work))/W6587.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6587;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6587:;quit;
