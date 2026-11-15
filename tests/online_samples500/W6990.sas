/* New workflow W6990; invented deterministic fixtures, not research results. */
options notes merror serror;
data w6990i;
length gene $80;
gene='v01';x=0.0;y=1.2415418669865446;output;
gene='v02';x=0.3333333333333333;y=0.9583945420937681;output;
gene='v03';x=0.6666666666666666;y=3.3971129610911484;output;
gene='v04';x=1.0;y=2.5807468988368614;output;
gene='v05';x=1.3333333333333333;y=3.8052557045364583;output;
gene='v06';x=1.6666666666666667;y=2.37904050738502;output;
gene='v07';x=2.0;y=3.0692079669356787;output;
gene='v08';x=2.3333333333333335;y=0.39898929273416917;output;
gene='v09';x=2.6666666666666665;y=0.7384449578643686;output;
gene='v10';x=3.0;y=1.3350245704873043;output;
gene='v11';x=3.3333333333333335;y=5.11049259393232;output;
gene='v12';x=3.6666666666666665;y=3.3373729946037294;output;
run;
ods listing gpath="%sysfunc(pathname(work))";ods graphics /reset=index imagename="W6990" outputfmt=svg width=580px height=380px;title "W6990: synthetic SAS regression fixture";proc sgplot data=w6990i;scatter x=x y=y/markerattrs=(size=4);run;title;ods listing close;
data w6990m(keep=metric value);set w6990i;length metric $120;array measured[*] x y;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data w6990m;set w6990m;format value best32.;run;
proc export data=w6990m outfile="%sysfunc(pathname(work))/W6990.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=W6990;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete w6990:;quit;
