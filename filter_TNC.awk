# get from https://stackoverflow.com/questions/59485015/comparison-of-two-files-using-awk-and-print-non-matched-records
# slightly edited
BEGIN{              ##Starting BEGIN section of this program from here.
  FS="|"            ##Setting FS as pipe here as per Input_file(s).
}                   ##Closing BEGIN block for this awk code here.
FNR==NR{            ##Checking condition FNR==NR which will be TRUE when 1st Input_file named file1 is being read.
  a[$1,$3]          ##Creating an array named a with index os $1,$3 of current line.
  next              ##next will skip all further statements.
}
!(($1,$3) in a)   ##Checking condition #1 if $1,$3 are NOT present in array a then print that line from Input_file2.

# here as one liner for windows :(
#gawk "BEGIN{FS=""^|""""}FNR==NR{a[$1,$3];next}^!(($1,$3) in a);((""TNC^:\\\\"""") in a)" "%_TARGET%CURRENT.LST" "%_TARGET%MASCHINE.LST" >"%_TARGET%DIFF.LST"

