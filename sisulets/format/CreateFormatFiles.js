var part, term, xsiFieldType;
var xsiColumnType = 'SQLVARYCHAR';
var xsiPrefix = '';
if(source.datafiletype == 'widechar') {
    xsiPrefix = 'N';
    xsiColumnType = 'SQLNVARCHAR';
}

// only one part is allowed when 'bulk' is specified
var part = source.nextPart();

/*~
<?xml version="1.0"?>
<BCPFORMAT
xmlns="http://schemas.microsoft.com/sqlserver/2004/bulkload/format"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
   <RECORD>
~*/
var EOL, delimiter, qoute; 
while(term = part.nextTerm()) {
    EOL = part.hasMoreTerms() ? '' : source.fieldterminator;
    if(term.size) {
        xsiFieldType = xsiPrefix + 'CharFixed';
/*~
      <FIELD xsi:type="$xsiFieldType" ID="$term.name" LENGTH="$term.size" />
~*/
    }
    else {
        xsiFieldType = xsiPrefix + 'CharTerm';
        delimiter = (term.delimiter ? term.delimiter : '') + EOL;
        quote = delimiter.match(/"/) ? "'" : '"';
        delimiter = quote + delimiter + quote;
/*~
      <FIELD xsi:type="$xsiFieldType" ID="$term.name" TERMINATOR=$delimiter />
~*/
    }
}
/*~
   </RECORD>
   <ROW>
~*/
while(term = part.nextTerm()) {
/*~
      <COLUMN SOURCE="$term.name" NAME="$term.name" xsi:type="$xsiColumnType" />
~*/
}
/*~
   </ROW>
</BCPFORMAT>
~*/

