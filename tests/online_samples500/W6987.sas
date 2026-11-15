/* New workflow W6987; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6987i;
length gene $80;
gene='v01';x=0.0;y=2.721572952708314;output;
gene='v02';x=0.3333333333333333;y=1.0586625194166792;output;
gene='v03';x=0.6666666666666666;y=0.8027251696581429;output;
gene='v04';x=1.0;y=-0.25721118594456194;output;
gene='v05';x=1.3333333333333333;y=2.267047630340641;output;
gene='v06';x=1.6666666666666667;y=4.580343451919907;output;
gene='v07';x=2.0;y=3.6031641641830277;output;
gene='v08';x=2.3333333333333335;y=4.629149730167475;output;
gene='v09';x=2.6666666666666665;y=-0.16150271978408548;output;
run;
ods listing gpath="%sysfunc(pathname(work))";ods graphics /reset=index imagename="W6987" outputfmt=svg width=620px height=380px;title "W6987: synthetic SAS regression fixture";proc sgplot data=w6987i;scatter x=x y=y/markerattrs=(size=6);run;title;ods listing close;
data w6987m(keep=metric value);set w6987i;length metric $120;array measured[*] x y;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6987m;set w6987m;format value best32.;run;
proc export data=w6987m outfile="%sysfunc(pathname(work))/W6987.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6987;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6987:;quit;
