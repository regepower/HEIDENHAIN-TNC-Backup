rem # get from https://stackoverflow.com/questions/6619619/awk-consider-double-quoted-string-as-one-token-and-ignore-space-in-between
rem # slightly edited by Trolle
# Resplit $0 into array B. Spaces between double quotes are not separators.
# Single quotes not handled. No escaping of double quotes.
function resplit(       a, l, i, j, b, k, BNF) # all are local variables
{
  l=split($0, a, "\"")
  BNF=0
  delete B
  for (i=1;i<=l;++i)
  {
    if (i % 2)
    {
      k=split(a[i], b)
      for (j=1;j<=k;++j)
        B[++BNF] = b[j]
    }
    else
    {
      B[++BNF] = "\""a[i]"\""
    }
  }
}

{
  resplit()

  {
    gsub(/\:/, "_", B[1]) # Im Pfad das : durch ein _ ersetzen
    gsub(/\"/, "", B[1]) # Im Pfad das "" entfernen werden bei print() gesetzt
    gsub(/\;/, " ", B[3]) # Im Timestamp das ; durch ein " " ersetzen
  }
 print "--date=""\x22"B[3]"\x22","\x22"B[1]"\x22"
}
