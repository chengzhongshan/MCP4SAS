/* New workflow V6268; invented deterministic fixtures, not research results. */
options notes merror serror;
data v6268i;
length gene $80;
gene='allele01';ref=28;alt=3;output;
gene='allele02';ref=3;alt=27;output;
gene='allele03';ref=31;alt=11;output;
gene='allele04';ref=10;alt=34;output;
run;
%n26_calculate_binomial_P(dsdin=v6268i,dsdout=v6268o,Allele1_var=ref,Allele2_var=alt,TotReadCutoff=10);
data v6268m(keep=metric value);set v6268o;length metric $120;array measured[*] tot_reads binomial_P logP Ref_Frq A1A2log2Ratio;do _measure=1 to dim(measured);metric=catx(':',strip(gene),vname(measured[_measure]));value=measured[_measure];output;end;run;

data v6268m;set v6268m;format value best32.;run;
proc export data=v6268m outfile="%sysfunc(pathname(work))/V6268.csv" dbms=csv replace;run;
%put NEW_WORKFLOW_DONE=V6268;
%put NEW_WORKFLOW_OUT=%sysfunc(pathname(work));
proc datasets library=work nolist;delete v6268:;quit;
