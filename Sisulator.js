// helper functions
function alert(str) {
    WScript.Echo(str);
}
function exit(code) {
    WScript.Quit(code);
}

// global variables 
ERROR = 42;
VALID = 0;

var MAP = {
    Anchor: {
        description: 'models from Anchor Modeling, http://www.anchormodeling.com',
        // name of the root element and resulting JSON object
        root: 'schema',
        // define 'keys' for elements that may occur more than once
        // on the same level in the XML document
        key: {
            knot: function(xml, fragment) {
                return fragment.getAttribute('mnemonic');
            },
            anchor: function(xml, fragment) {
                return fragment.getAttribute('mnemonic');
            },
            attribute: function(xml, fragment) {
                return fragment.getAttribute('mnemonic');
            },
            tie: function(xml, fragment) {
                var roles = fragment.selectNodes('*[@role]');
                var key = '', role;
                for(var i = 0; i < roles.length; i++) {
                    role = roles.item(i);
                    key += role.getAttribute('type') + '_' + role.getAttribute('role');
                    if(i < roles.length - 1) key += '_';
                }
                return key;
            },
            anchorRole: function(xml, fragment) {
                return fragment.getAttribute('type') + '_' + fragment.getAttribute('role');
            },
            knotRole: function(xml, fragment) {
                return fragment.getAttribute('type') + '_' + fragment.getAttribute('role');
            }
        },
        // used to replace certain element names with others
        replacer: function(name) {
            switch(name) {
                case 'anchorRoles':
                    return 'roles';
                case 'knotRoles':
                    return 'roles';
                default:
                    return name;
            }
        }
    },
    Workflow: {
        description: 'workflow for SQL Server Job Agent',
        root: 'workflow',
        key: { 
            job: function(xml, fragment) {
                return fragment.getAttribute('name');
            },
            jobstep: function(xml, fragment) {
                return fragment.getAttribute('name');
            },
            variable: function(xml, fragment) {
                return fragment.getAttribute('name');
            }
        }
    },
    Source: { 
        description: 'source data format description',
        root: 'source',
        key: { 
            part: function(xml, fragment) {
                return fragment.getAttribute('name');
            },
            term: function(xml, fragment) {
                return fragment.getAttribute('name');
            },
            key: function(xml, fragment) {
                return fragment.getAttribute('name');
            },
            component: function(xml, fragment) {
                return fragment.getAttribute('of');
            },            
            calculation: function(xml, fragment) {
                return fragment.getAttribute('name');
            }
        }
    },
    Target: {
        description: 'target loading description',
        root: 'target',
        key: { 
            map: function(xml, fragment) {
                return fragment.getAttribute('source') + '__' + fragment.getAttribute('target');
            },
            condition: function(xml, fragment) {
                return 'singleton'; // there can be only one!
            },
            load: function(xml, fragment) {
                var pass = fragment.getAttribute('pass');
                pass = pass ? '__' + pass : '';
                return fragment.getAttribute('source') + '__' + fragment.getAttribute('target') + pass;
            },
            sql: function(xml, fragment) {
                return fragment.getAttribute('position');
            }
        }
    }
}
 
var Sisulator = {
    // this function will recursively traverse the XML document and
    // create a 'hash' object that mimics the structure using the given map
    // to handle siblings using the same tag
    objectify: function(xml, map) {
        var listSuffix = 's';
        function objectifier(xmlFragment, map, object) {
            // element node
            if(xmlFragment.nodeType === 1) {
                // if there are children or attributes we need a container
                if(xmlFragment.attributes.length > 0 || xmlFragment.firstChild) {
                    if(!object[xmlFragment.nodeName])
                        object[xmlFragment.nodeName] = new Object();
                    var partialObject = object[xmlFragment.nodeName];
                    if(typeof map.key[xmlFragment.nodeName] === 'function') {
                        var key = map.key[xmlFragment.nodeName](xml, xmlFragment);
                        if(key) {
                            partialObject = partialObject[key] = new Object();
                            partialObject.id = key;
                            var name = xmlFragment.nodeName + listSuffix;
                            name = map.replacer ? map.replacer(name) : name;
                            // reference the object from the array
                            if(!object[name])
                                object[name] = [];
                            object[name].push(key);
                        }
                    }
                    // process attributes
                    if (xmlFragment.attributes.length > 0) {
                        for (var j = 0; j < xmlFragment.attributes.length; j++) {
                            var attribute = xmlFragment.attributes.item(j);
                            partialObject[attribute.nodeName] = attribute.nodeValue;
                        }
                    }
                    // process children
                    var child = xmlFragment.firstChild;
                    if(child) objectifier(child, map, partialObject);
                }
            }
            // text node
            else if(xmlFragment.nodeType === 3) {
                // add content with underscore naming
                if(xmlFragment.nodeValue)
                    object['_' + xmlFragment.parentNode.nodeName] = xmlFragment.nodeValue;
            }
            // process siblings
            var sibling = xmlFragment.nextSibling;
            if(sibling) objectifier(sibling, map, object);
            return object;
        }
        // just initialize and return the result
        return objectifier(xml.documentElement, map, {});
    },
    sisulate: function(xml, map, directive) {
        // objectify the xml
        var jsonObject = Sisulator.objectify(xml, map);
        // consistent with other line breaks and without comments
        jsonObject[map.root]._xml = xml.xml.replace(/(\r\n|\n|\r)/g, '\n').replace(/<!--[\s\S]*?-->/g, ''); 
        eval("var " + map.root + " = jsonObject." + map.root);
        // this variable holds the result
        var _sisula_ = '';
        // process and evaluate all sisulas in the directive
        var reader = new ActiveXObject("Scripting.FileSystemObject");
        var file = reader.OpenTextFile(directive);
        var scripts = file.ReadAll();
        file.Close();
        scripts = scripts.replace(/\r/g, ''); // unify line breaks
        // only non-empty lines that are not comments (starts with #)
        scripts = scripts.match(/^[^#].+/gm);
        if(scripts) {
            var script;
            var splitter = /\/\*~|~\*\//g; // split JS /*~ sisula template ~*/ JS
            // process every sisula
            for(var scriptIndex = 0; script = scripts[scriptIndex]; scriptIndex++) {
                script = script.replace(/^\s+/,'').replace(/\s+$/,''); // trim
                file = reader.OpenTextFile(script);
                var sisula = file.ReadAll();
                file.Close();
                // make sure everything starts with JavaScript (empty row)
                sisula = '\n' + sisula;
                // split language into JavaScript and SQL template components
                var sisulets = sisula.split(splitter);
                // substitute from SQL template to JavaScript
                for(var i = 1; i < sisulets.length; i+=2) {
                    // honor escaped dollar signs
                    sisulets[i] = sisulets[i].replace(/[$]{2}/g, '§DOLLAR§'); // escaping dollar signs
                    sisulets[i] = sisulets[i].replace(/["]{2}/g, '§DOUBLE§'); // escaping double quotes
                    sisulets[i] = sisulets[i].replace(/["]{1}/g, '§SINGLE§'); // escaping single quotes
                    sisulets[i] = sisulets[i].replace(/[$]{([\S\s]*?)}[$]/g, '" + $1 + "'); // multi-expression
                    sisulets[i] = sisulets[i].replace(/[$]\(([\S\s]*?)\)\?[^\S\n]*([^:\n]*)[:]?[^\S\n]*(.*)/g, '" + ($1 ? "$2" : "$3") + "'); // conditional
                    sisulets[i] = sisulets[i].replace(/[\$]([\w.]*?)(?:([\$])|([^\w.]|$))/g, '" + ($1 ? $1 : "") + "$3'); // single
                    sisulets[i] = sisulets[i].replace(/(\r\n|\n|\r)/g, '\\n" +\n'); // line breaks
                    sisulets[i] = sisulets[i].replace(/^/gm, '"'); // start of line
                    sisulets[i] = '_sisula_+=' + sisulets[i] + '";'; // variable assignment
                }
                // join the parts together again (now all JavaScript)
                sisula = sisulets.join('');
                try {
                    // this eval needs schema and _sisula_ to be defined
                    eval(sisula);
                }
                catch(e) {
                    alert('Error in script: ' + script);
                    alert(sisula); // alert was used for debugging sisula code
                    throw e;
                }
            }
            _sisula_ = _sisula_.replace(/§DOLLAR§/g, '$'); // unescaping dollar signs
            _sisula_ = _sisula_.replace(/§SINGLE§/g, '\"'); // unescaping double quotes
            _sisula_ = _sisula_.replace(/§QUOTED§/g, '"'); // unescaping double quotes
            _sisula_ = _sisula_.replace(/^\s*[\r\n]/gm, ''); // remove empty lines
            _sisula_ = _sisula_.replace(/(\S+[^\S\n])(?:[^\S\n]+)/gm, '$1'); // consume multiple spaces, but not indentation
        }
        return _sisula_;
    }
};
 
 
// This is the main() where we start with parsing the command line
var commandLineOptions = {
    _opts_:         {
                            // option, description, mandatory
        xmlFilename:        ['-x', 'XML file made available as a JSON object in the sisulets.', true],
        mappingType:        ['-m', 'XML to object mapping type.', true], 
        directiveFilename:  ['-d', 'Directive file specifying a list of sisulets that will be processed.', true],
        outputFilename:     ['-o', 'Output file where the result is stored.', false]
    }
};
 
var o, option, description, map, list = 'Command line options:';
// if no arguments were provided then list the options and exit
if(WScript.Arguments.length == 0) {
    for(o in commandLineOptions._opts_) {
        option = commandLineOptions._opts_[o][0];
        description = commandLineOptions._opts_[o][1];
        list += '\n' + option + '\t' + description;
    }
    list += '\n\nAvailable mapping types:'
    for(map in MAP) {
        list += '\n' + map + ', ' + MAP[map].description;
    }
    alert(list);
    exit(ERROR);
}
 
// ergo, we have arguments, so make them a regular array
var i, commandLineArguments = [];
for(i = 0; i < WScript.Arguments.length; i++)
    commandLineArguments.push(WScript.Arguments.Item(i));
 
// parse the given arguments
var pattern, argument, delim = ';';
var joinedArguments = commandLineArguments.join(delim);
for(o in commandLineOptions._opts_) {
    option = commandLineOptions._opts_[o][0];
    if(joinedArguments.indexOf(option) >= 0) {
        pattern = new RegExp(option + delim + '([^' + delim + ']*)');
        argumentMatch = joinedArguments.match(pattern);
        if(argumentMatch) {
            commandLineOptions[o] = argumentMatch[1];
        }
    }
}
 
// check mandatory options and exit if not provided
var mandatory;
for(o in commandLineOptions._opts_) {
    mandatory = commandLineOptions._opts_[o][2];
    if(mandatory) {
        if(!commandLineOptions[o] || commandLineOptions[o].length == 0) {
            option = commandLineOptions._opts_[o][0];
            description = commandLineOptions._opts_[o][1];
            alert("The option " + option + " is mandatory with the description:\n" + description);
            exit(ERROR);
        }
    }
}
// instantiate a DOM object at run time
var xmlObject = new ActiveXObject("msxml2.DOMDocument.6.0");
xmlObject.async = false;
xmlObject.resolveExternals = false;
xmlObject.validateOnParse = false;
// load an XML file into the DOM instance
if(!xmlObject.load(commandLineOptions.xmlFilename)) {
    alert("The XML file: " + commandLineOptions.xmlFilename + " could not be loaded");
    exit(ERROR);
}
 
// objectify the XML and apply the sisulets to get some output text
var sisulaOutput = Sisulator.sisulate(
                        xmlObject, 
                        MAP[commandLineOptions.mappingType], 
                        commandLineOptions.directiveFilename
                   );
 
// save the output
var outputFilename = commandLineOptions.outputFilename || commandLineOptions.directiveFilename + '.output';
var writer = new ActiveXObject("Scripting.FileSystemObject");
var outputFile = writer.CreateTextFile(outputFilename, true);
outputFile.Write(sisulaOutput);
outputFile.Close();
 
// the end
exit(VALID);
