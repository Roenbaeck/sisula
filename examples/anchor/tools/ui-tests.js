// The tests that ui-check.ps1 runs inside the Anchor Modeler's own page, in headless Edge. They drive the page the way a
// user does (the same functions the menus, the context menu and the keyboard call) and look at what the page then holds:
// the saved XML, the components, the DOM, the undo history. Nothing here depends on how the page is built inside, only on
// what it does, so the same tests must pass before and after the code is moved around.
//
// A test is a function that returns nothing or true when it passes, and a message (or throws) when it does not. What a test
// wants compared with an earlier run it passes to record(key, value); ui-check.ps1 compares those with ui-golden.json.
(function () {
    var tests = [], observed = {};
    function test(name, fn) { tests.push({ name: name, fn: fn }); }
    function record(key, value) { observed[key] = value; }
    function sleep(ms) { return new Promise(function (resolve) { setTimeout(resolve, ms); }); }
    // waits until the layout has settled (the engine stops), as a user would before the next click
    async function settle() { for (var i = 0; i < 30 && DrawingEngine.running; i++) await sleep(50); await sleep(50); }
    function expect(condition, message) { if (!condition) throw new Error(message); }

    // A short fingerprint of the model as it would be saved: without the positions (they come from the physics), without what
    // the root element says about the moment and the version of the program that saved it, and independent of the order of
    // the elements and of the attributes (undo and loading may order them differently).
    function canonical(node) {
        if (node.nodeType === 3) return node.nodeValue.trim() ? node.nodeValue : '';
        if (node.nodeType !== 1 || node.nodeName === 'layout') return '';
        var attributes = Array.prototype.map.call(node.attributes, function (a) { return a.name + '="' + a.value + '"'; });
        if (node.nodeName === 'schema') attributes = [];
        attributes.sort();
        var children = Array.prototype.map.call(node.childNodes, canonical).filter(Boolean).sort();
        return '<' + node.nodeName + (attributes.length ? ' ' + attributes.join(' ') : '') + '>' + children.join('') + '</' + node.nodeName + '>';
    }
    function xmlOf() { return canonical(Model.toXML(false).documentElement); }
    function hash(s) { var h = 2166136261; for (var i = 0; i < s.length; i++) { h ^= s.charCodeAt(i); h = Math.imul(h, 16777619) >>> 0; } return h.toString(16); }
    function counts() {
        var c = {};
        Model.components.forEach(function (x) { var t = NodeType[x.node.type]; c[t] = (c[t] || 0) + 1; });
        return Object.keys(c).sort().map(function (k) { return k + '=' + c[k]; }).join(',');
    }
    function fingerprint() { var x = xmlOf(); return hash(x) + ':' + x.length + ':' + counts(); }
    function ofType(type) { return Model.components.filter(function (x) { return x.node.type === type; }); }

    var originals = {};
    async function load(xmlText) {
        Actions._applyLoadedModel(new DOMParser().parseFromString(xmlText, 'text/xml'), false);
        await sleep(100);
    }
    async function fresh() { Model.setupMinimal(false); EventHandler.clearSelection(); await sleep(100); }
    function press(key, options) {
        var e = new KeyboardEvent('keydown', Object.assign({ key: key, bubbles: true, cancelable: true }, options || {}));
        window.dispatchEvent(e);
        return e;
    }
    function hover(component) {
        EventHandler.clearInteraction(); EventHandler.setInteraction(null);
        component.svg.graphicsElement.dispatchEvent(new MouseEvent('mouseover', { bubbles: true }));
    }
    function closeOverlays() {
        ['codePopover', 'tabularEditor', 'contextMenu', 'urlPopover'].forEach(function (id) {
            var e;
            while ((e = document.getElementById(id))) e.parentNode.removeChild(e);
        });
        Array.prototype.forEach.call(document.querySelectorAll('.modalBackground, #modalBackground'), function (e) { e.parentNode.removeChild(e); });
    }

    // --- loading and saving -------------------------------------------------------------------------------------------
    test('the page started without a script error', async function () {
        expect(window.__errs.length === 0, window.__errs.join(' | '));
    });

    test('the example model loads and has what the file has', async function () {
        await load(window.__MODELS['example.xml']);
        record('example.counts', counts());
        record('example.xml', fingerprint());
        expect(Model.components.length > 40, 'only ' + Model.components.length + ' components');
    });

    test('the roastery model loads and has what the file has', async function () {
        await load(window.__MODELS['examples/roastery.xml']);
        record('roastery.counts', counts());
        record('roastery.xml', fingerprint());
    });

    test('saving and loading again gives the same model', async function () {
        await load(window.__MODELS['example.xml']);
        var before = xmlOf();
        await load(before);
        var after = xmlOf(), d = 0;
        while (d < before.length && before[d] === after[d]) d++;
        expect(after === before, 'the model changed on a round trip at ' + d + ' of ' + before.length + '/' + after.length + ': [' + before.substr(d, 80) + '] [' + after.substr(d, 80) + ']');
    });

    test('the saved model keeps the positions of the nodes', async function () {
        await load(window.__MODELS['example.xml']);
        var withLayout = new XMLSerializer().serializeToString(Model.toXML(false));
        expect((withLayout.match(/<layout /g) || []).length > 20, 'few layout elements');
        await load(withLayout);
        var anchors = ofType(NodeType.ANCHOR);
        expect(anchors.every(function (a) { return isFinite(a.node.xPosition) && isFinite(a.node.yPosition); }), 'a position is missing');
    });

    // --- editing with the operations the menu and the keyboard offer -----------------------------------------------------
    var fps = {};
    var xmls = {};
    // the states are walked by version, which depends on how many states the layout recorded, so what is recorded for the
    // comparison with earlier runs is named by the step
    function snap(step) { fps[Model.version] = fingerprint(); xmls[Model.version] = xmlOf(); if (step) record('built.' + step, fps[Model.version]); }
    function difference(a, b) { var d = 0; while (d < a.length && a[d] === b[d]) d++; return 'at ' + d + ': [' + a.substr(Math.max(0, d - 40), 100) + '] against [' + b.substr(Math.max(0, d - 40), 100) + ']'; }
    test('a model can be built with the operations of the context menu', async function () {
        await fresh();
        var anchor = ofType(NodeType.ANCHOR)[0];
        anchor.mnemonic = 'AC'; anchor.descriptor = 'Actor';
        Model.recordState(); fps = {}; snap('minimal');
        Model.addAttribute([anchor]);
        var attribute = ofType(NodeType.ATTRIBUTE)[0];
        attribute.mnemonic = 'NAM'; attribute.descriptor = 'Name';
        Model.recordState(); snap('attribute');
        Model.toggleHistorized([attribute]);
        snap('historized');
        Model.addAttribute([anchor]);
        var second = ofType(NodeType.ATTRIBUTE)[1];
        second.mnemonic = 'GEN'; second.descriptor = 'Gender';
        Model.recordState();
        Model.toggleKnotted([second]);
        snap('knotted');
        expect(ofType(NodeType.KNOT).length === 1, 'no knot after toggleKnotted');
        Model.addTieAndAnchor([anchor]);
        snap('tie');
        expect(ofType(NodeType.TIE).length === 1 && ofType(NodeType.ANCHOR).length === 2, 'no tie and second anchor');
        Model.addNexus([anchor]);
        snap('nexus');
        expect(ofType(NodeType.NEXUS).length === 1, 'no nexus');
        record('built.counts', counts());
        expect(attribute.historized === true, 'the attribute was not historized');
    });

    test('undo and redo walk back and forth through the same states', async function () {
        var versions = Object.keys(fps).map(Number).sort(function (a, b) { return a - b; });
        expect(versions.length >= 5 && Model.version === versions[versions.length - 1], 'the previous test did not run: ' + versions + ', at ' + Model.version);
        var sizes = function () { return Model.versions.map(function (d) { return new XMLSerializer().serializeToString(d).length; }).join(','); };
        var sizesBefore = sizes();
        // some operations record more than one state, so the walk goes to the states that were fingerprinted
        for (var i = versions.length - 1; i >= 0; i--) {
            while (Model.version > versions[i]) { ControlButtons.undo(); await settle(); }
            expect(Model.version === versions[i], 'at version ' + Model.version + ', expected ' + versions[i]);
            expect(fingerprint() === fps[versions[i]], 'undo state ' + versions[i] + ' differs ' + difference(xmlOf(), xmls[versions[i]]));
        }
        var sizesAfter = sizes();
        expect(sizesBefore === sizesAfter, 'loading a saved state changed it: sizes ' + sizesBefore + ' became ' + sizesAfter);
        for (i = 1; i < versions.length; i++) {
            while (Model.version < versions[i]) { ControlButtons.redo(); await settle(); }
            expect(fingerprint() === fps[versions[i]], 'redo state ' + versions[i] + ' (model at ' + Model.version + ' of ' + (Model.versions.length - 1) + '; fingerprinted versions ' + versions + ') differs ' + difference(xmlOf(), xmls[versions[i]]));
        }
    });

    test('a change after an undo drops what could have been redone', async function () {
        Model.undoState(); Model.undoState();
        var version = Model.version;
        var anchor = ofType(NodeType.ANCHOR)[0];
        anchor.descriptor = 'Performer';
        Model.recordState();
        expect(Model.versions.length === Model.version + 1, 'stale redo states are kept');
        expect(Model.version === version + 1, 'the version did not move on');
    });

    test('the history is limited', async function () {
        Model.clearStates();
        for (var i = 0; i < Model.maxUndoLevels + 30; i++) Model.recordState();
        expect(Model.version === Model.maxUndoLevels, 'version ' + Model.version);
        expect(Model.versions.length === Model.maxUndoLevels + 1, 'states ' + Model.versions.length);
    });

    test('delete removes a construct and what hangs on it', async function () {
        await fresh();
        var anchor = ofType(NodeType.ANCHOR)[0];
        Model.addAttribute([anchor]); Model.addAttribute([anchor]);
        var before = Model.components.length;
        Model.erase([ofType(NodeType.ATTRIBUTE)[0]]);
        expect(Model.components.length < before, 'nothing was erased');
        record('erase.counts', counts());
    });

    test('a tie can be made between two anchors and a role made an identifier', async function () {
        await fresh();
        var a = ofType(NodeType.ANCHOR)[0];
        Model.addTieAndAnchor([a]);
        var anchors = ofType(NodeType.ANCHOR);
        expect(anchors.length === 2, 'no second anchor');
        var roles = ofType(NodeType.EDGE).filter(function (r) { return r.tied; });
        expect(roles.length >= 2, 'no tie roles');
        var identifier = roles[0].identifier;
        Model.toggleIdentifier([roles[0]]);
        expect(roles[0].identifier !== identifier, 'the identifier did not toggle');
    });

    // --- keyboard ---------------------------------------------------------------------------------------------------------
    test('keys act on the node under the pointer, and leave the browser alone', async function () {
        await fresh();
        var anchor = ofType(NodeType.ANCHOR)[0];
        hover(anchor);
        var before = Model.components.length, attributes = ofType(NodeType.ATTRIBUTE).length;
        var f5 = press('F5'), ctrl = press('a', { ctrlKey: true }), tab = press('Tab'), arrow = press('ArrowLeft');
        expect(!f5.defaultPrevented && !ctrl.defaultPrevented && !tab.defaultPrevented && !arrow.defaultPrevented, 'a browser key was swallowed');
        expect(Model.components.length === before, 'a key that is not a shortcut changed the model');
        var a = press('a');
        expect(a.defaultPrevented && ofType(NodeType.ATTRIBUTE).length === attributes + 1, 'key a did not add an attribute (attributes ' + attributes + ' to ' + ofType(NodeType.ATTRIBUTE).length + ', prevented ' + a.defaultPrevented + ')');
        hover(anchor);
        press('E', { shiftKey: true });
        expect(document.getElementById('tabularEditor'), 'Shift+E did not open the mass editor');
        closeOverlays();
    });

    test('h and k toggle historized and knotted on the hovered attribute', async function () {
        await fresh();
        var anchor = ofType(NodeType.ANCHOR)[0];
        hover(anchor); press('a');
        var attribute = ofType(NodeType.ATTRIBUTE)[0];
        EventHandler.clearInteraction(); hover(attribute);
        press('h');
        expect(attribute.historized === true, 'h did not historize');
        EventHandler.clearInteraction(); hover(attribute);
        press('k');
        expect(ofType(NodeType.KNOT).length === 1, 'k did not knot');
    });

    test('escape clears the selection', async function () {
        var anchor = ofType(NodeType.ANCHOR)[0];
        EventHandler.addComponentToSelection(anchor);
        expect(EventHandler.selectedComponents.length === 1, 'not selected');
        press('Escape');
        expect(EventHandler.selectedComponents.length === 0, 'the selection was kept');
    });

    // --- the editing dialogs ------------------------------------------------------------------------------------------------
    test('the context menu opens with the fields and the operations of the construct', async function () {
        await load(window.__MODELS['example.xml']);
        var anchor = ofType(NodeType.ANCHOR)[0];
        anchor.showContextMenu(anchor, [], null);
        anchor.contextMenu.toggle();
        var menu = anchor.contextMenu.contextMenu;
        expect(menu && document.body.contains(menu), 'no context menu');
        record('contextmenu.anchor.fields', menu.querySelectorAll('.editable').length);
        record('contextmenu.anchor.operations', menu.querySelectorAll('.operator').length);
        expect(menu.querySelectorAll('.editable').length >= 4, 'few fields: ' + menu.querySelectorAll('.editable').length + ', collapsed ' + anchor.contextMenu.collapsed);
        anchor.hideContextMenu();
        closeOverlays();
    });

    test('an edit in the context menu reaches the model and is recorded', async function () {
        await load(window.__MODELS['example.xml']);
        var anchor = ofType(NodeType.ANCHOR)[0];
        anchor.showContextMenu(anchor, [], null);
        anchor.contextMenu.toggle();
        var field = anchor.contextMenu.contextMenu.querySelector('.editable');
        var before = Model.version;
        field.value = 'Renamed';
        field.dispatchEvent(new Event('change', { bubbles: true }));
        anchor.contextMenu.edit(field, anchor);
        expect(anchor.descriptor === 'Renamed', 'the descriptor is ' + anchor.descriptor);
        anchor.contextMenu.close();
        expect(Model.version === before + 1, 'the edit was not recorded (version ' + before + ' to ' + Model.version + ')');
        closeOverlays();
    });

    test('the tabular editor lists the constructs', async function () {
        await load(window.__MODELS['example.xml']);
        new TabularEditor('');
        var e = document.getElementById('tabularEditor');
        expect(e, 'not opened');
        record('tabular.rows', e.querySelectorAll('tr').length);
        closeOverlays();
    });

    // --- view and search ---------------------------------------------------------------------------------------------------
    test('the search list holds the nodes and can be filtered', async function () {
        await load(window.__MODELS['example.xml']);
        var select = document.getElementById('nodeSelector');
        Actions.populateSelector(select, '');
        var all = select.options.length;
        Actions.populateSelector(select, 'Name');
        var some = select.options.length;
        record('search.all', all); record('search.name', some);
        expect(all > 20 && some > 1 && some < all, all + ' and ' + some + ' options');
    });

    test('implode and explode hide and show attributes', async function () {
        await load(window.__MODELS['example.xml']);
        var visible = function () { return Model.components.filter(function (c) { return c.visible; }).length; };
        var before = visible();
        Actions.implodeAll(); await sleep(50);
        var imploded = visible();
        Actions.explodeAll(); await sleep(50);
        expect(imploded < before && visible() === before, before + ', ' + imploded + ', ' + visible());
    });

    test('zoom changes the view and reset view restores it', async function () {
        var w = SVG.viewBox.baseVal.width;
        ControlButtons.zoomIn(); await sleep(50);
        expect(SVG.viewBox.baseVal.width < w, 'zoom in did not narrow the view');
        Actions.resetZoom();
        expect(SVG.viewBox.baseVal.width === window.innerWidth, 'reset view did not restore the width');
    });

    test('the theme switches and switches back', async function () {
        var dark = document.body.classList.contains('dark');
        Actions.toggleTheme(); await sleep(50);
        expect(document.body.classList.contains('dark') !== dark, 'no change');
        Actions.toggleTheme(); await sleep(50);
        expect(document.body.classList.contains('dark') === dark, 'did not go back');
    });

    test('bubbles and role names sit on their edges, also after a sudden move', async function () {
        await load(window.__MODELS['example.xml']);
        function worst() {
            var max = 0;
            Model.components.forEach(function (c) {
                if (c.node.type === NodeType.EDGE && (c.tied || c.chronicable) && c.svg.graphicsElement) {
                    var m = c.svg.graphicsElement.transform.baseVal.getItem(0).matrix, p = c.svg.pathElement, L = p.getTotalLength();
                    for (var i = 0, best = 1e9; i <= 300; i++) { var q = p.getPointAtLength(L * i / 300); best = Math.min(best, Math.hypot(q.x - m.e, q.y - m.f)); }
                    max = Math.max(max, best);
                }
            });
            return max;
        }
        await sleep(500);
        expect(worst() < 3, 'a bubble is ' + worst().toFixed(1) + ' px from its edge');
        ofType(NodeType.ANCHOR).slice(0, 3).forEach(function (a) { a.node.xPosition += 350; a.node.yPosition += 200; });
        DrawingEngine.start(true);
        await sleep(300);
        expect(worst() < 3, 'after a move a bubble is ' + worst().toFixed(1) + ' px from its edge');
    });

    // --- settings and output --------------------------------------------------------------------------------------------------
    test('settings are written to a store and read back', async function () {
        var store = {}, storage = { setItem: function (k, v) { store[k] = String(v); }, getItem: function (k) { return k in store ? store[k] : null; }, removeItem: function (k) { delete store[k]; }, clear: function () { store = {}; } };
        Settings.setNaming('original');
        Settings.storeSettings(storage);
        var keys = Object.keys(store).length;
        Settings.setNaming('improved');
        Settings.loadSettings(storage);
        record('settings.keys', keys);
        expect(Defaults.naming === 'original' || document.getElementById('naming').value === 'original', 'the naming was not restored');
        Settings.setNaming('improved');
    });

    test('changing the target database and temporalization changes what the page offers', async function () {
        Settings.setDatabase('Snowflake', false); Settings.setTemporalization('crt');
        await sleep(100);
        expect(document.body.classList.contains('temporal-crt'), 'no temporal-crt class');
        Settings.setDatabase('SQLServer', false); Settings.setTemporalization('uni');
        await sleep(100);
        expect(document.body.classList.contains('temporal-uni') && !document.body.classList.contains('temporal-crt'), 'crt class kept');
    });

    test('SQL, XML and documentation are generated', async function () {
        await load(window.__MODELS['example.xml']);
        var sql = await Actions.sql();
        expect(/CREATE TABLE/i.test(sql) && sql.length > 100000, 'the SQL has ' + sql.length + ' characters');
        record('sql.tables.sqlserver.uni', (sql.match(/CREATE TABLE/g) || []).length);
        Actions.generateXML();
        await sleep(500);
        expect(document.getElementById('codePopover'), 'no XML popover');
        closeOverlays();
        // the documentation goes into a new window: a document of its own stands in for it
        var doc = document.implementation.createHTMLDocument('documentation'), written = '', open = window.open;
        doc.open = function () {}; doc.close = function () {}; doc.write = function (t) { written += t; };
        window.open = function () { return { document: doc, focus: function () {} }; };
        Actions.generateHTML();
        await sleep(800);
        window.open = open;
        record('html.written', written.length); record('html.body', doc.body.innerHTML.length);
        expect(doc.body.innerHTML.length > 1000, 'the documentation has ' + doc.body.innerHTML.length + ' characters');
        closeOverlays();
    });

    test('a shared link carries the model', async function () {
        await load(window.__MODELS['examples/roastery.xml']);
        var link = null;
        Object.defineProperty(navigator, 'clipboard', { configurable: true, value: { writeText: async function (u) { link = u; } } });
        await Actions.shareModel();
        expect(link && link.indexOf('#model=') > 0, 'no link');
        var before = xmlOf();
        await load(window.__MODELS['example.xml']);
        window.location.hash = link.substring(link.indexOf('#'));
        expect(Actions.sharedModelInLink(), 'the link is not seen');
        await Actions.loadSharedModel();
        await sleep(200);
        var after = xmlOf(), d = 0;
        while (d < before.length && before[d] === after[d]) d++;
        expect(after === before, 'the model from the link differs at ' + d + ' of ' + before.length + '/' + after.length + ': [' + before.substr(d, 60) + '] [' + after.substr(d, 60) + ']');
        history.replaceState(null, '', window.location.pathname + window.location.search);
    });

    test('a model is kept in the browser when the page is left', async function () {
        await load(window.__MODELS['examples/roastery.xml']);
        save(window, false);
        var kept = window.localStorage.getItem('model');
        expect(kept && kept.indexOf('<schema') >= 0, 'no model in storage');
        record('storage.keys', Object.keys(window.localStorage).filter(function (k) { return k !== 'model'; }).sort().join(','));
    });

    test('there is no cloud and the gist loader is there', async function () {
        expect(!document.getElementById('cloud') && typeof Actions.loadModelFromGist === 'function', 'cloud or gist wrong');
    });

    test('the menus offer what they did', async function () {
        var items = Array.prototype.map.call(document.querySelectorAll('#header .menu'), function (m) { return m.firstChild.nodeValue.trim() + ':' + m.querySelectorAll('li').length; });
        record('menus', items.join(' '));
    });

    // --- run --------------------------------------------------------------------------------------------------------------------
    function report(text) { document.getElementById('ui-result').textContent = text; }
    function toBase64(s) { return btoa(unescape(encodeURIComponent(s))); }
    async function run() {
        var only = window.__ONLY, results = [];
        for (var i = 0; i < tests.length; i++) {
            var t = tests[i], r = { name: t.name, ok: true, message: '' };
            if (only && only.length && !only.some(function (p) { return t.name.indexOf(p) >= 0; })) continue;
            report("PENDING during: " + t.name);
            try {
                var v = await t.fn();
                if (v !== undefined && v !== true) { r.ok = false; r.message = String(v); }
            } catch (e) {
                r.ok = false; r.message = String(e && e.message || e);
            }
            results.push(r);
        }
        report('BASE64:' + toBase64(JSON.stringify({ results: results, observed: observed })));
    }
    window.__runUiTests = run;
})();
