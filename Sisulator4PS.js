// Sisulator.js - V5 (Correct Final Version)
console.log('Starting up the sisulator...');

function getAttribute(fragment, attribute) {
    var attr = fragment.Attributes.GetNamedItem(attribute);
    return attr ? attr.Value : null;
}

var MAP = {
    Anchor: {
        description: 'models from Anchor Modeling, http://www.anchormodeling.com',
        root: 'schema',
        key: {
            // CORRECTED: Use .NET property access: .Attributes.GetNamedItem(...).Value
            knot: function(xml, fragment) { return getAttribute(fragment, 'mnemonic'); },
            anchor: function(xml, fragment) { return getAttribute(fragment, 'mnemonic'); },
            attribute: function(xml, fragment) { return getAttribute(fragment, 'mnemonic'); },
            tie: function(xml, fragment) {
                // CORRECTED: .SelectNodes is the .NET way to query
                var roles = fragment.SelectNodes(".//*[@role]");
                var key = '', role;
                for(var i = 0; i < roles.Count; i++) {
                    role = roles.Item(i);
                    key += getAttribute(role, 'type') + '_' + getAttribute(role, 'role');
                    if(i < roles.Count - 1) key += '_';
                }
                return key;
            },
            anchorRole: function(xml, fragment) { return getAttribute(fragment, 'type') + '_' + getAttribute(fragment, 'role'); },
            knotRole: function(xml, fragment) { return getAttribute(fragment, 'type') + '_' + getAttribute(fragment, 'role'); }
        },
        replacer: function(name) {
            switch(name) {
                case 'anchorRoles': return 'roles';
                case 'knotRoles': return 'roles';
                default: return name;
            }
        }
    },
    Workflow: { description: 'workflow for SQL Server Job Agent', root: 'workflow', key: { 
        job: function(xml, fragment) { return getAttribute(fragment, 'name'); }, 
        jobstep: function(xml, fragment) { return getAttribute(fragment, 'name'); }, 
        variable: function(xml, fragment) { return getAttribute(fragment, 'name'); }
    }},
    Source: { description: 'source data format description', root: 'source', key: { 
        part: function(xml, fragment) { return getAttribute(fragment, 'name'); }, 
        term: function(xml, fragment) { return getAttribute(fragment, 'name'); }, 
        key: function(xml, fragment) { return getAttribute(fragment, 'name'); }, 
        component: function(xml, fragment) { return getAttribute(fragment, 'of'); }, 
        calculation: function(xml, fragment) { return getAttribute(fragment, 'name'); }
    }},
    Target: { description: 'target loading description', root: 'target', key: { 
        map: function(xml, fragment) { return getAttribute(fragment, 'source') + '__' + getAttribute(fragment, 'target'); }, 
        condition: function(xml, fragment) { return 'singleton'; }, 
        load: function(xml, fragment) { var pass = getAttribute(fragment, 'pass'); pass = pass ? '__' + pass : ''; return getAttribute(fragment, 'source') + '__' + getAttribute(fragment, 'target') + pass; }, 
        sql: function(xml, fragment) { return getAttribute(fragment, 'position'); }
    }}
};

var Sisulator = {
    objectify: function(xml, map) {
        var listSuffix = 's';

        function objectifier(xmlNode, map, object) {
            if (!xmlNode) { return; }

            // Get the actual NodeType object.
            var nodeType = xmlNode.NodeType; 
            var nodeName = (xmlNode.Name || '').toLowerCase();

            // CORRECTED: Compare directly against the injected enum constants.
            if (nodeType == XmlNodeType.Element) { // Readable and robust!
                if (!object[nodeName]) { object[nodeName] = {}; }
                var partialObject = object[nodeName];

                if (typeof map.key[nodeName] === 'function') {
                    var key = map.key[nodeName](xml, xmlNode);
                    if (key) {
                        partialObject = partialObject[key] = { id: key };
                        var listName = map.replacer ? map.replacer(nodeName + listSuffix) : nodeName + listSuffix;
                        if (!object[listName]) { object[listName] = []; }
                        object[listName].push(key);
                    }
                }

                if (xmlNode.Attributes) {
                    for (var i = 0; i < xmlNode.Attributes.Count; i++) {
                        var attr = xmlNode.Attributes.Item(i);
                        partialObject[attr.Name.toLowerCase()] = attr.Value;
                    }
                }

                if (xmlNode.HasChildNodes) {
                    for (var j = 0; j < xmlNode.ChildNodes.Count; j++) {
                        objectifier(xmlNode.ChildNodes.Item(j), map, partialObject);
                    }
                }
            } else if (nodeType == XmlNodeType.Text) { // Readable and robust!
                var parentNodeName = (xmlNode.ParentNode.Name || '').toLowerCase();
                if (xmlNode.Value && xmlNode.Value.trim()) {
                    object['_' + parentNodeName] = xmlNode.Value.trim();
                }
            }
        }
        
        var result = {};
        objectifier(xml.DocumentElement, map, result);
        return result;
    },
    sisulate: function() {
        // console.log('Mapping type: ' + mappingType);
        // console.log('XML document: ' + xmlDoc);

        // It reads its dependencies from the global scope, where PowerShell set them.
        var map = MAP[mappingType];
        var xml = xmlDoc;

        var jsonObject = Sisulator.objectify(xml, map);

        if (jsonObject[map.root]) {
            var rawXmlString = xml.DocumentElement.OuterXml;
            jsonObject[map.root]._xml = rawXmlString.replace(/(\r\n|\n|\r)/g, '\n').replace(/<!--[\s\S]*?-->/g, ''); 
        }

        // 1. Create a NEW object for the execution context.
        var executionContext = {};

        // 2. Manually create a shallow copy of the global VARIABLES.
        var VARIABLES = {};
        var enumerator = variablesHashtable.GetEnumerator();
        while (enumerator.MoveNext()) {
            var key = enumerator.Current.Key;
            var value = enumerator.Current.Value;            
            VARIABLES[key] = value;
        }
        
        // 3. Add the objectified XML root to the new context.
        executionContext[map.root] = jsonObject[map.root];

        var functionBody = "var _sisula_ = '';\n";
        var sisulets = directiveContent.split(/\/\*~|~\*\//g);

        // Explicitly process BOTH pure code (even indices) and templates (odd indices)
        for (var i = 0; i < sisulets.length; i++) {
            var scriptPart = sisulets[i];
            if (!scriptPart) continue; // Skip empty parts

            if (i % 2 === 0) {
                // This is PURE JAVASCRIPT (like Helpers.js). Append it directly.
                functionBody += scriptPart;
            } else {
                // This is a TEMPLATE block. Transform it into string-building code.
                scriptPart = scriptPart.replace(/[$]{2}/g, '§DOLLAR§').replace(/["]{2}/g, '§DOUBLE§').replace(/["]{1}/g, '§SINGLE§');
                scriptPart = scriptPart.replace(/[$]{([\S\s]*?)}[$]/g, '" + ' + '$1' + ' + "');
                scriptPart = scriptPart.replace(/[$]\(([\S\s]*?)\)\?[^\S\n]*([^:\n]*)[:]?[^\S\n]*(.*)/g, '" + (' + '$1' + ' ? "' + '$2' + '" : "' + '$3' + '") + "');
                scriptPart = scriptPart.replace(/[\$]([\w.]*?)(?:([\$])|([^\w.]|$))/g, '" + (' + '$1' + ' ? ' + '$1' + ' : "") + "' + '$3');
                
                // Escape newlines and wrap the entire block in quotes
                scriptPart = '"' + scriptPart.replace(/(\r\n|\n|\r)/g, '\\n') + '"';

                // Add it to the output variable _sisula_
                functionBody += '_sisula_ += ' + scriptPart + ';\n';
            }
        }
        
        functionBody += "return _sisula_;\n";

        var argNames = Object.keys(executionContext);
        var argValues = argNames.map(function(name) { return executionContext[name]; });        

        try {
            var sandboxedFunction = new (Function.prototype.bind.apply(Function, [null].concat(argNames, functionBody)));
            var output = sandboxedFunction.apply(null, argValues);
            output = output.replace(/§DOLLAR§/g, '$').replace(/§SINGLE§/g, '\"').replace(/§QUOTED§/g, '"');
            output = output.replace(/^\s*[\r\n]/gm, '').replace(/(\S+[^\S\n])(?:[^\S\n]+)/gm, '$1');
            return output;
        } catch(e) {
            throw new Error(
                "Template Execution Error: " + e.message + 
                "\nFunction Body (first 500 chars):\n" + functionBody.substring(0, 500)
            );
        }
    }
};

