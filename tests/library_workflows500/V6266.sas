/* New workflow V6266; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6266i;
length gene $80;
gene='allele01';ref=6;alt=34;output;
gene='allele02';ref=9;alt=26;output;
gene='allele03';ref=1;alt=16;output;
gene='allele04';ref=19;alt=18;output;
gene='allele05';ref=24;alt=11;output;
gene='allele06';ref=28;alt=31;output;
gene='allele07';ref=0;alt=18;output;
gene='allele08';ref=30;alt=29;output;
gene='allele09';ref=13;alt=11;output;
run;
%n26_calculate_binomial_P(dsdin=v6266i,dsdout=v6266o,Allele1_var=ref,Allele2_var=alt,TotReadCutoff=8);
data v6266m(keep=metric value);set v6266o;length metric $120;array measured[*] tot_reads binomial_P logP Ref_Frq A1A2log2Ratio;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6266m;set v6266m;format value best32.;run;
proc export data=v6266m outfile="%sysfunc(pathname(work))/V6266.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6266;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6266:;quit;
