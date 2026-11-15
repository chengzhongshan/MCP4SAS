/* New workflow W7000; invented deterministic fixtures, not research results. */
options notes merror serror;
data w7000i;
length gene $80;
gene='v01';x=0.0;y=3.4250799689440568;output;
gene='v02';x=0.3333333333333333;y=-1.5001711074870383;output;
gene='v03';x=0.6666666666666666;y=0.9851600206919843;output;
gene='v04';x=1.0;y=3.5317492590417348;output;
gene='v05';x=1.3333333333333333;y=3.4863152707142833;output;
gene='v06';x=1.6666666666666667;y=1.592021161668229;output;
gene='v07';x=2.0;y=-0.5390166249233035;output;
gene='v08';x=2.3333333333333335;y=1.9212979383627293;output;
gene='v09';x=2.6666666666666665;y=1.3153055338467745;output;
gene='v10';x=3.0;y=4.8474574584714505;output;
gene='v11';x=3.3333333333333335;y=5.614281609093584;output;
gene='v12';x=3.6666666666666665;y=2.0581211490765776;output;
gene='v13';x=4.0;y=4.857478945246632;output;
gene='v14';x=4.333333333333333;y=1.1782687988557428;output;
gene='v15';x=4.666666666666667;y=1.8645607324686753;output;
run;
ods listing gpath="%sysfunc(pathname(work))";ods graphics /reset=index imagename="W7000" outputfmt=svg width=500px height=410px;title "W7000: synthetic SAS regression fixture";proc sgplot data=w7000i;scatter x=x y=y/markerattrs=(size=4);run;title;ods listing close;
data w7000m(keep=metric value);set w7000i;length metric $120;array measured[*] x y;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w7000m;set w7000m;format value best32.;run;
proc export data=w7000m outfile="%sysfunc(pathname(work))/W7000.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W7000;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w7000:;quit;
