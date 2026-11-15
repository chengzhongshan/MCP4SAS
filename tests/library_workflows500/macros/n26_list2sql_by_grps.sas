/* Test-only namespaced definition from list2sql_by_grps.sas; original SHA256 933a08012cadfcdcbef35e19341d1c041693ef80d6698ed6b7ba69158a563dbe. */
%macro n26_list2sql_by_grps(
list=A B C /*Replace blank spaces with comma using %str or %nrstr or %nrbquote*/
);

%sysfunc(prxchange(s/ +/%str(,)/,-1,&list))

%mend;
