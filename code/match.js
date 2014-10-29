if(WScript.Arguments.Length > 0) {
    var match, regex = new RegExp(WScript.Arguments.Item(0));
    while (!WScript.StdIn.AtEndOfStream) {
        if(match = WScript.StdIn.ReadLine().match(regex)) {
            for(var i = 1; i < match.length ; i++) {
                WScript.StdOut.WriteLine(match[i]); 
            }
        }
    }
}