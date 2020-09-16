

ORACLE_PASSWWORD=password
csv=test_table.csv
touch $csv
row=200

seq 1 $row | xargs -n 1 names > $csv

cat << END > test_table.ctl
LOAD DATA
INFILE $csv
APPEND
INTO TABLE test_table
FIELDS TERMINATED BY ' '
TRAILING NULLCOLS
(
  first_name
  ,second_name
)
END

sqlldr system/$ORACLE_PASSWWORD control=test_table.ctl
