/* New workflow W6993; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6993i;
length gene $80;
gene='v01';x=0.0;y=0.43278851396304674;output;
gene='v02';x=0.3333333333333333;y=-0.30546468732242865;output;
gene='v03';x=0.6666666666666666;y=1.3867426514664598;output;
gene='v04';x=1.0;y=0.12081425802131729;output;
gene='v05';x=1.3333333333333333;y=1.5964144684725505;output;
gene='v06';x=1.6666666666666667;y=3.9378531507623595;output;
gene='v07';x=2.0;y=1.3615371652211217;output;
gene='v08';x=2.3333333333333335;y=4.586366129360497;output;
gene='v09';x=2.6666666666666665;y=2.7299525443646258;output;
gene='v10';x=3.0;y=3.1322172252410123;output;
gene='v11';x=3.3333333333333335;y=2.524988970107766;output;
gene='v12';x=3.6666666666666665;y=5.156175677956965;output;
gene='v13';x=4.0;y=6.044825763733579;output;
gene='v14';x=4.333333333333333;y=4.1990175756777965;output;
gene='v15';x=4.666666666666667;y=5.092420249929721;output;
run;
ods listing gpath="%sysfunc(pathname(work))";ods graphics /reset=index imagename="W6993" outputfmt=svg width=540px height=380px;title "W6993: synthetic SAS regression fixture";proc sgplot data=w6993i;scatter x=x y=y/markerattrs=(size=7);run;title;ods listing close;
data w6993m(keep=metric value);set w6993i;length metric $120;array measured[*] x y;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6993m;set w6993m;format value best32.;run;
proc export data=w6993m outfile="%sysfunc(pathname(work))/W6993.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6993;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6993:;quit;
