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
    // presses undo or redo until the history is at a version, and fails with what it found instead of going on for ever
    async function stepTo(target, forward) {
        for (var n = 0; forward ? Model.version < target : Model.version > target; n++) {
            if (n > 30) throw new Error('stuck at version ' + Model.version + ' on the way to ' + target + ' (states 0 to ' + (Model.versions.length - 1) + ', restoring ' + DrawingEngine.restoring + ', engine running ' + DrawingEngine.running + ', newState ' + DrawingEngine.newState + ')');
            if (forward) ControlButtons.redo(); else ControlButtons.undo();
            await settle();
        }
    }
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
        sv(component).graphicsElement.dispatchEvent(new MouseEvent('mouseover', { bubbles: true }));
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
            await stepTo(versions[i], false);
            expect(Model.version === versions[i], 'at version ' + Model.version + ', expected ' + versions[i]);
            expect(fingerprint() === fps[versions[i]], 'undo state ' + versions[i] + ' differs ' + difference(xmlOf(), xmls[versions[i]]));
        }
        var sizesAfter = sizes();
        expect(sizesBefore === sizesAfter, 'loading a saved state changed it: sizes ' + sizesBefore + ' became ' + sizesAfter);
        for (i = 1; i < versions.length; i++) {
            await stepTo(versions[i], true);
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

    test('the model tells its listeners about changes, and the history buttons listen', async function () {
        await fresh();
        var seen = { changed: 0, history: [], replaced: 0, after: 0 };
        var onChanged = function () { seen.changed++; }, onHistory = function (d) { seen.history.push(d.undo + '/' + d.redo); }, onReplaced = function () { seen.replaced++; };
        var failing = function () { throw new Error('a listener that fails'); }, afterFailing = function () { seen.after++; };
        Model.on('changed', failing); Model.on('changed', afterFailing);
        Model.on('changed', onChanged); Model.on('history', onHistory); Model.on('replaced', onReplaced);
        var errors = console.error; console.error = function () {};
        try {
            Model.addAttribute([ofType(NodeType.ANCHOR)[0]]);
            expect(seen.changed >= 1, 'no changed event');
            expect(seen.after >= 1, 'a listener that fails stopped the next one');
            var last = seen.history[seen.history.length - 1].split('/');
            expect(Number(last[0]) === Model.version && last[1] === '0', 'history event ' + seen.history.join(' '));
            expect(document.querySelector('#undo .count').textContent === String(Model.version), 'the undo button says ' + document.querySelector('#undo .count').textContent);
            ControlButtons.undo(); await settle();
            expect(seen.replaced >= 1, 'no replaced event after an undo');
            expect(document.querySelector('#redo .count').textContent === '1', 'the redo button says ' + document.querySelector('#redo .count').textContent);
            Model.off('changed', onChanged);
            var count = seen.changed;
            Model.addAttribute([ofType(NodeType.ANCHOR)[0]]);
            expect(seen.changed === count, 'a listener that was removed was still told');
        } finally {
            console.error = errors;
            Model.off('changed', failing); Model.off('changed', afterFailing); Model.off('changed', onChanged);
            Model.off('history', onHistory); Model.off('replaced', onReplaced);
        }
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

    test('a nexus can be imploded and exploded like an anchor, and keeps it when it is saved and read again', async function () {
        await load(window.__MODELS['example.xml']);
        var nexus = ofType(NodeType.NEXUS)[0];
        function attributesOf(n) {
            return n.node.edges.map(function (e) { return e.node === n.node ? e.otherNode : e.node; })
                .filter(function (other) { return other.type === NodeType.ATTRIBUTE; })
                .map(function (other) { return Model.nodeToComponent(other); });
        }
        var attributes = attributesOf(nexus);
        expect(attributes.length > 0 && attributes.every(function (a) { return a.visible; }), 'the nexus has no visible attributes to start with');
        record('nexus.implode.attributes', attributes.length);
        Model.explode([nexus]); await sleep(50);
        expect(nexus.imploded === true, 'the nexus was not imploded');
        expect(attributes.every(function (a) { return !a.visible; }), 'the attributes of the imploded nexus are still shown');
        var saved = new XMLSerializer().serializeToString(Model.toXML(false));
        expect(/<nexus[^>]*>(?:(?!<\/nexus>)[\s\S])*<layout[^>]*imploded="true"/.test(saved), 'the saved model does not say that the nexus is imploded');
        await load(saved);
        var again = ofType(NodeType.NEXUS)[0];
        expect(again.imploded === true, 'the nexus was not imploded after the model was read again');
        expect(attributesOf(again).every(function (a) { return !a.visible; }), 'the attributes are shown after the model was read again');
        Model.explode([again]); await sleep(50);
        expect(again.imploded === false && attributesOf(again).every(function (a) { return a.visible; }), 'the nexus did not explode');
        Actions.implodeAll(); await sleep(50);
        expect(ofType(NodeType.NEXUS).every(function (n) { return n.imploded; }), 'implode all left a nexus alone');
        expect(ofType(NodeType.ANCHOR).every(function (n) { return n.imploded; }), 'implode all left an anchor alone');
        Actions.explodeAll(); await sleep(50);
        expect(ofType(NodeType.NEXUS).every(function (n) { return !n.imploded; }), 'explode all left a nexus imploded');
        expect(ofType(NodeType.NEXUS).every(function (n) { return attributesOf(n).every(function (a) { return a.visible; }); }), 'explode all left attributes hidden');
    });

    test('what explodes is drawn where it is put, also if the layout stops it at once', async function () {
        await load(window.__MODELS['example.xml']);
        await sleep(500);
        var wrong = [];
        [NodeType.NEXUS, NodeType.ANCHOR].forEach(function (type) {
            var one = ofType(type)[0];
            Model.explode([one], false); // implode, without the layout that would move and draw them
            Model.explode([one], false); // explode, in the same way: nothing but the explode has drawn anything yet
            Model.components.forEach(function (c) {
                if (c.visible && c.node.type !== NodeType.EDGE && sv(c).control) {
                    var m = sv(c).control.matrix;
                    if (Math.hypot(m.e - c.node.xPosition, m.f - c.node.yPosition) > 0.5) wrong.push(c.toString());
                }
            });
        });
        expect(wrong.length === 0, wrong.length + ' constructs are not drawn where they are: ' + wrong.slice(0, 5).join(', '));
        DrawingEngine.start(true);
        await sleep(200);
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

    test('the colors come from tokens that both themes give a value, and the bar changes with them', async function () {
        var tokens = ['--bg', '--surface', '--surface-raised', '--border', '--text', '--text-muted', '--accent', '--hover', '--g-ink', '--g-halo', '--g-edge', '--g-card', '--g-anchor', '--g-attribute', '--g-tie', '--g-ring'];
        function read() { var s = getComputedStyle(document.body); return tokens.map(function (t) { return s.getPropertyValue(t).trim(); }); }
        var dark = document.body.classList.contains('dark');
        Actions.applyTheme('light'); var light = read();
        Actions.applyTheme('dark'); var night = read();
        var barDark = getComputedStyle(document.getElementById('header')).backgroundColor;
        Actions.applyTheme('light');
        var barLight = getComputedStyle(document.getElementById('header')).backgroundColor;
        Actions.applyTheme(dark ? 'dark' : 'light');
        tokens.forEach(function (t, i) { expect(light[i] && night[i], 'the token ' + t + ' has no value in the ' + (light[i] ? 'dark' : 'light') + ' theme'); });
        expect(light[tokens.indexOf('--bg')] !== night[tokens.indexOf('--bg')] && light[tokens.indexOf('--g-card')] !== night[tokens.indexOf('--g-card')], 'the themes do not differ');
        expect(barLight !== barDark, 'the bar does not change with the theme');
        // the accent, the one red of the interface, is not what the bar is filled with
        expect(barLight !== getComputedStyle(document.body).getPropertyValue('--accent').trim(), 'the bar is filled with the accent');
        record('theme.tokens', tokens.length);
    });

    test('the controls are buttons that say what they do, with an icon each, and undo and redo are off when there is nothing to undo or redo', async function () {
        await fresh();
        ['undo', 'redo', 'playpause', 'zoomin', 'zoomout'].forEach(function (id) {
            var b = document.getElementById(id), box = b.querySelector('svg').getBoundingClientRect();
            expect(b.tagName === 'BUTTON', id + ' is not a button');
            expect(b.getAttribute('aria-label') && b.getAttribute('title'), id + ' has no name for a screen reader, or no tooltip');
            expect(box.width > 8 && box.height > 8, id + ' has no icon that shows');
        });
        expect(document.getElementById('undo').disabled && document.getElementById('redo').disabled, 'undo and redo are on for a model without history');
        Model.addAttribute([ofType(NodeType.ANCHOR)[0]]); Model.recordState(); Model.recordState(); // the first state is the model as it is, so undo is on from the second
        expect(!document.getElementById('undo').disabled, 'undo is off after a change');
        ControlButtons.setPlayState();
        var playing = getComputedStyle(document.querySelector('#playpause .pause')).display, paused = getComputedStyle(document.querySelector('#playpause .play')).display;
        expect(paused === 'block' && playing === 'none', 'the pause button shows the wrong icon when paused (' + paused + ', ' + playing + ')');
        ControlButtons.setPauseState();
        expect(getComputedStyle(document.querySelector('#playpause .play')).display === 'none', 'the pause button shows play when it runs');
    });
    test('the square on the context menu is there to click, and opens the menu for editing', async function () {
        await load(window.__MODELS['example.xml']);
        Actions.resetView(); await sleep(600);
        var anchor = ofType(NodeType.ANCHOR)[0];
        anchor.showContextMenu(anchor, [], null);
        var menu = anchor.contextMenu, square = menu.toggler, box = square.getBoundingClientRect();
        expect(box.width > 8 && box.height > 8, 'the square has no size');
        expect(getComputedStyle(menu.contextMenu).overflow === 'visible', 'the menu clips what is across its corner, and the square is across it');
        if (box.left >= 0 && box.top >= 0 && box.right <= window.innerWidth && box.bottom <= window.innerHeight) {
            var hit = document.elementFromPoint(box.left + box.width / 2, box.top + box.height / 2);
            expect(hit === square, 'the square cannot be reached, ' + (hit && (hit.id || hit.className || hit.tagName)) + ' is in its place');
        }
        square.click(); await sleep(100);
        expect(!menu.collapsed && document.querySelector('#contextMenu .editable'), 'a click on the square did not open the menu for editing');
        anchor.hideContextMenu();
        window.removeEventListener('keydown', EventHandler.keydown, false); // closing the menu puts it back, as the pointer leaving would take it away
    });
    test('the model settings are in one dialog that opens, finds, changes settings and closes', async function () {
        await load(window.__MODELS['example.xml']);
        var dialog = document.getElementById('modelSettings');
        // nothing but the search fields is left in the bar, and the Generate menu only generates
        var left = Array.prototype.map.call(document.querySelectorAll('#header input, #header select'), function (e) { return e.id; });
        expect(left.join() === 'searchFilter,nodeSelector', 'the bar still has fields: ' + left.join());
        expect(document.querySelectorAll('#generate li').length === 6 && document.querySelectorAll('#generate li[data-action]').length === 6, 'the Generate menu holds more than commands');
        // the settings that the menus held
        var ids = ['database', 'naming', 'temporalization', 'metadataUsage', 'businessViews', 'knotAliases', 'triggers', 'naturalKeyAttributes', 'equivalence', 'decisiveness', 'entityIntegrity', 'partitioning',
            'changingSuffix', 'encapsulation', 'defaultIdentity', 'defaultNow', 'restatability', 'assertiveness', 'damping', 'stiffness', 'calculations'];
        ids.forEach(function (id) { expect(document.querySelector('#modelSettings #' + id), 'the setting ' + id + ' is not in the dialog'); });
        expect(document.querySelectorAll('#modelSettings .fields li').length >= 52, 'only ' + document.querySelectorAll('#modelSettings .fields li').length + ' settings');
        // every setting says what it is for, in words that show
        var helpless = Array.prototype.filter.call(document.querySelectorAll('#modelSettings .fields li.setting'), function (li) { return !li.querySelector('.help') || !li.querySelector('.help').textContent.trim() || !li.querySelector('label'); });
        expect(helpless.length === 0, helpless.length + ' settings have no label or no sentence of help');
        record('settings.fields', document.querySelectorAll('#modelSettings .fields li').length);
        // it opens, on a group
        Actions.openModelSettings('advanced'); await sleep(500);
        expect(dialog.open, 'the dialog did not open');
        var box = document.getElementById('settings-advanced').getBoundingClientRect(), dbox = dialog.getBoundingClientRect();
        expect(box.top < dbox.bottom && box.bottom > dbox.top, 'the group that was asked for is not in view');
        expect(document.querySelector('#modelSettings nav [aria-current]').textContent === 'Advanced', 'the group is not marked in the list');
        // it finds
        var all = document.querySelectorAll('#modelSettings .fields li:not(.filtered)').length;
        var search = document.getElementById('settingsSearch');
        search.value = 'naming'; search.dispatchEvent(new Event('input', { bubbles: true }));
        var found = document.querySelectorAll('#modelSettings .fields li:not(.filtered)');
        expect(found.length >= 1 && found.length < all, 'the search found ' + found.length + ' of ' + all);
        expect(Array.prototype.every.call(document.querySelectorAll('#modelSettings section.group'), function (s) { return s.classList.contains('filtered') === !s.querySelector('li:not(.filtered)'); }), 'a group without matches is shown, or one with is not');
        search.value = 'qqqqzzzz'; search.dispatchEvent(new Event('input', { bubbles: true }));
        expect(!document.getElementById('settingsNone').hidden, 'nothing matched and it does not say so');
        search.value = ''; search.dispatchEvent(new Event('input', { bubbles: true }));
        expect(document.querySelectorAll('#modelSettings .fields li:not(.filtered)').length === all, 'clearing the search did not bring everything back');
        // a setting changed in it is the setting
        var naming = document.getElementById('naming'), before = Defaults.naming;
        naming.value = before === 'original' ? 'improved' : 'original'; naming.dispatchEvent(new Event('change', { bubbles: true }));
        expect(Defaults.naming === naming.value && Defaults.naming !== before, 'the naming setting did not change');
        naming.value = before; naming.dispatchEvent(new Event('change', { bubbles: true }));
        // it closes, with the button and with a click beside it
        document.querySelector('#modelSettings .close').click();
        expect(!dialog.open, 'the close button did not close it');
        Actions.openModelSettings(); await sleep(100);
        dialog.dispatchEvent(new MouseEvent('click', { bubbles: true }));
        expect(!dialog.open, 'a click beside the dialog did not close it');
    });

    test('the theme button says what it will do and switches', async function () {
        var button = document.getElementById('themeToggle'), was = document.body.classList.contains('dark');
        Actions.applyTheme('light');
        expect(/dark/i.test(button.getAttribute('aria-label')) && getComputedStyle(button.querySelector('.moon')).display !== 'none' && getComputedStyle(button.querySelector('.sun')).display === 'none', 'the button in the light theme');
        button.click(); await sleep(50);
        expect(document.body.classList.contains('dark') && /light/i.test(button.getAttribute('aria-label')) && getComputedStyle(button.querySelector('.sun')).display !== 'none', 'the button in the dark theme');
        Actions.applyTheme(was ? 'dark' : 'light');
    });
    test('the menus work from the keyboard: names and items with roles, arrows, letters, Enter, Escape and Tab', async function () {
        await load(window.__MODELS['example.xml']);
        function key(el, k) { var e = new KeyboardEvent('keydown', { key: k, bubbles: true, cancelable: true }); el.dispatchEvent(e); return e; }
        var labels = Array.prototype.slice.call(document.querySelectorAll('#header .menulabel'));
        expect(labels.length === 4 && labels.every(function (l) { return l.tagName === 'BUTTON' && l.getAttribute('aria-haspopup') === 'menu' && l.hasAttribute('aria-expanded'); }), 'the names are not buttons that say they have a menu');
        expect(labels.filter(function (l) { return l.getAttribute('tabindex') === '0'; }).length === 1, 'more or fewer than one name can be reached with Tab');
        expect(Array.prototype.every.call(document.querySelectorAll('#header .submenu'), function (m) { return m.getAttribute('role') === 'menu' && m.getAttribute('aria-label'); }), 'a menu has no role or no name');
        var items = document.querySelectorAll('#header .submenu li');
        expect(Array.prototype.every.call(items, function (li) { return li.getAttribute('role') === 'menuitem' && li.getAttribute('tabindex') === '-1'; }), 'an item has no role, or it is in the Tab order');
        record('menus.items', items.length);
        var file = document.getElementById('file'), first = file.querySelector('li');
        labels[0].focus(); key(labels[0], 'ArrowDown');
        expect(file.classList.contains('open') && labels[0].getAttribute('aria-expanded') === 'true' && document.activeElement === first, 'Down on a name did not open the menu on its first item');
        var list = Array.prototype.slice.call(file.querySelectorAll('li'));
        key(document.activeElement, 'ArrowDown'); expect(document.activeElement === list[1], 'Down did not go to the next item');
        key(document.activeElement, 'End'); expect(document.activeElement === list[list.length - 1], 'End did not go to the last');
        key(document.activeElement, 'ArrowDown'); expect(document.activeElement === list[0], 'Down on the last did not wrap');
        key(document.activeElement, 'ArrowUp'); expect(document.activeElement === list[list.length - 1], 'Up on the first did not wrap');
        key(document.activeElement, 'Home'); expect(document.activeElement === list[0], 'Home did not go to the first');
        var save = list.filter(function (li) { return /^Save model/i.test(li.textContent.trim()); })[0];
        key(document.activeElement, 's'); expect(document.activeElement.textContent.trim().toLowerCase().indexOf('s') === 0, 'a letter did not go to an item that starts with it');
        var other = key(document.activeElement, 'q');
        expect(!other.defaultPrevented, 'a letter that no item starts with was taken');
        // sideways, with the menu open: the next opens
        key(document.activeElement, 'ArrowRight');
        var layout = document.getElementById('actions');
        expect(!file.classList.contains('open') && layout.classList.contains('open') && document.activeElement === layout.querySelector('li'), 'Right did not go to the next menu');
        expect(labels[1].getAttribute('tabindex') === '0' && labels[0].getAttribute('tabindex') === '-1', 'the name that can be reached with Tab did not follow');
        // Enter does what the item says, and the menu closes with the focus back on its name
        var before = DrawingEngine.showNames;
        var toggle = Array.prototype.filter.call(layout.querySelectorAll('li'), function (li) { return li.getAttribute('data-action') === 'Actions.toggleNames'; })[0];
        toggle.focus(); var enter = key(toggle, 'Enter'); await sleep(50);
        expect(enter.defaultPrevented && DrawingEngine.showNames !== before, 'Enter did not do what the item says');
        expect(!layout.classList.contains('open') && document.activeElement === labels[1], 'the menu did not close with the focus on its name');
        Actions.toggleNames();
        // Escape closes, Tab leaves, Left and Right move between the names without opening
        key(labels[1], 'ArrowDown'); expect(layout.classList.contains('open'), 'Down did not open');
        key(document.activeElement, 'Escape'); expect(!layout.classList.contains('open') && document.activeElement === labels[1], 'Escape did not close the menu and return to its name');
        key(labels[1], 'ArrowRight'); expect(document.activeElement === labels[2] && !document.getElementById('generate').classList.contains('open'), 'Right on a name did not just move');
        key(labels[2], 'ArrowRight'); expect(document.activeElement === labels[3], 'Right did not reach the last name');
        key(labels[3], 'ArrowRight'); expect(document.activeElement === labels[0], 'Right on the last name did not wrap');
        key(labels[0], 'ArrowUp'); expect(document.activeElement === list[list.length - 1], 'Up on a name did not open the menu on its last item');
        key(document.activeElement, 'Tab'); expect(!file.classList.contains('open'), 'Tab did not close the menu');
        // a click opens and closes, as it has to where there is nothing to hover with
        labels[2].click(); expect(document.getElementById('generate').classList.contains('open'), 'a click did not open the menu');
        labels[2].click(); expect(!document.getElementById('generate').classList.contains('open'), 'a second click did not close it');
        labels[2].click(); document.body.click(); expect(!document.getElementById('generate').classList.contains('open'), 'a click elsewhere did not close it');
        Menus.closeAll();
    });

    test('the graph can be reached with Tab and moved with the keys, and what happens is announced', async function () {
        await load(window.__MODELS['example.xml']);
        var graph = document.getElementById('graph'), box = SVG.viewBox.baseVal;
        function key(k, shift) { var e = new KeyboardEvent('keydown', { key: k, shiftKey: !!shift, bubbles: true, cancelable: true }); graph.dispatchEvent(e); return e; }
        expect(graph.tabIndex === 0 && graph.getAttribute('aria-label'), 'the graph cannot be reached, or does not say what it is');
        Actions.resetZoom(); var x = box.x, y = box.y, w = box.width;
        key('ArrowRight'); expect(box.x > x, 'Right did not move the view');
        key('ArrowLeft'); expect(Math.abs(box.x - x) < 0.001, 'Left did not move it back');
        key('ArrowDown'); expect(box.y > y, 'Down did not move the view');
        key('ArrowUp'); expect(Math.abs(box.y - y) < 0.001, 'Up did not move it back');
        key('ArrowRight', true); expect(box.x - x > 0.25 * w, 'shift did not make the step larger');
        key('+'); expect(box.width < w, 'plus did not zoom in');
        key('-'); key('-'); expect(box.width > w, 'minus did not zoom out');
        var zero = key('0'); expect(box.width === window.innerWidth && zero.defaultPrevented, 'zero did not show the model again');
        expect(!key('a').defaultPrevented, 'a key that the graph does not use was taken');
        // the live region
        var region = document.getElementById('announcer');
        expect(region && region.getAttribute('aria-live') === 'polite', 'there is no polite live region');
        Actions.announce('Hello'); await sleep(150);
        expect(region.textContent === 'Hello', 'announce did not say it');
        Model.addAttribute([ofType(NodeType.ANCHOR)[0]]); Model.recordState(); Model.recordState();
        ControlButtons.undo(); await sleep(150);
        expect(/^Undone, \d+ more can be undone$/.test(region.textContent), 'undo was not announced: ' + region.textContent);
        ControlButtons.redo(); await sleep(150);
        expect(/^Redone/.test(region.textContent), 'redo was not announced: ' + region.textContent);
    });
    test('the outline panel shows the model as a tree, follows the selection, edits and operates', async function () {
        await load(window.__MODELS['example.xml']);
        var panel = document.getElementById('panel'), tree = document.getElementById('outlineTree');
        expect(panel.hidden && !document.body.classList.contains('panel-open'), 'the panel is open before it was asked for');
        document.getElementById('panelButton').click(); await sleep(150);
        expect(!panel.hidden && document.body.classList.contains('panel-open') && document.getElementById('panelButton').getAttribute('aria-expanded') === 'true', 'the button did not open the panel');
        function rowOf(component) { return tree.querySelector('[data-id="' + Outline.idOf(component) + '"]'); }
        // every anchor, nexus, tie and knot is a row, and says how many there are
        var counts = {};
        ['ANCHOR', 'NEXUS', 'TIE', 'KNOT'].forEach(function (k) {
            var of = ofType(NodeType[k]);
            counts[k] = of.length;
            of.forEach(function (c) { expect(rowOf(c), 'no row for ' + k + ' ' + c); expect(rowOf(c).textContent.trim(), 'a ' + k + ' row has no name'); });
        });
        var titles = Array.prototype.map.call(tree.querySelectorAll('li.group'), function (li) { return li.textContent.trim(); }).join(' ');
        expect(titles === 'Anchors (' + counts.ANCHOR + ') Nexuses (' + counts.NEXUS + ') Ties (' + counts.TIE + ') Knots (' + counts.KNOT + ')', 'the groups say ' + titles);
        record('outline.groups', titles);
        // one row can be reached with Tab, and the tree is a tree
        expect(tree.getAttribute('role') === 'tree' && tree.querySelectorAll('[role=treeitem][tabindex="0"]').length === 1, 'the tree has no roles, or more than one row in the Tab order');
        // the owner of an attribute opens when the attribute is selected in the graph, and the row is selected
        var owner = ofType(NodeType.ANCHOR).filter(function (a) { return Outline.partsOf(a).length > 2; })[0], part = Outline.partsOf(owner)[0];
        expect(!rowOf(part), 'the attributes of a closed anchor are shown');
        EventHandler.clearSelection(); EventHandler.addComponentToSelection(part); await sleep(150);
        expect(rowOf(part) && rowOf(part).getAttribute('aria-selected') === 'true', 'the selection in the graph is not selected in the tree');
        expect(/^Attribute: /.test(document.querySelector('#panelProperties h3').textContent) && document.querySelector('#panelProperties input.editable'), 'the properties are not those of the attribute');
        // and the other way: a row selects in the graph
        EventHandler.clearSelection(); await sleep(100);
        rowOf(owner).querySelector('.line').dispatchEvent(new MouseEvent('click', { bubbles: true })); await sleep(150);
        expect(EventHandler.selectedComponents.length === 1 && EventHandler.selectedComponents[0] === owner, 'a click on a row did not select in the graph');
        expect(/^Anchor: /.test(document.querySelector('#panelProperties h3').textContent), 'the properties are not those of the anchor');
        // a field is a field: changing it changes the construct, the history, and the row
        var version = Model.version, field = document.querySelector('#panelProperties input.editable');
        expect(field && field.value === owner.descriptor, 'the first field is not the descriptor');
        field.value = 'Performer'; field.dispatchEvent(new Event('change', { bubbles: true })); field.dispatchEvent(new Event('blur')); await sleep(150);
        expect(owner.descriptor === 'Performer', 'the descriptor did not change');
        expect(Model.version === version + 1, 'the change was not recorded in the history');
        expect(rowOf(owner).textContent.indexOf('Performer') >= 0, 'the row has the old name');
        // the operations of the selection are buttons, and they work
        var before = Outline.partsOf(owner).length;
        var add = Array.prototype.filter.call(document.querySelectorAll('#panelProperties .operations button'), function (b) { return /attribute/i.test(b.textContent); })[0];
        expect(add, 'there is no operation to add an attribute');
        add.click(); await sleep(200);
        expect(Outline.partsOf(owner).length === before + 1, 'adding an attribute from the panel added none');
        expect(rowOf(owner).getAttribute('aria-expanded') === 'true' && tree.querySelectorAll('li[aria-level="3"]').length >= before, 'the new attribute is not in the tree');
        // the keys of a tree
        var row = rowOf(owner); row.focus();
        row.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowDown', bubbles: true, cancelable: true }));
        expect(document.activeElement === row.nextElementSibling, 'Down did not go to the next row');
        row = rowOf(owner); row.focus();
        row.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowLeft', bubbles: true, cancelable: true })); await sleep(50);
        expect(rowOf(owner).getAttribute('aria-expanded') === 'false', 'Left did not close the row');
        rowOf(owner).dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowRight', bubbles: true, cancelable: true })); await sleep(50);
        expect(rowOf(owner).getAttribute('aria-expanded') === 'true', 'Right did not open the row');
        EventHandler.clearSelection(); await sleep(100);
        rowOf(owner).dispatchEvent(new KeyboardEvent('keydown', { key: 'Enter', bubbles: true, cancelable: true })); await sleep(150);
        expect(EventHandler.selectedComponents[0] === owner, 'Enter did not select the row');
        // the filter
        var filter = document.getElementById('outlineFilter');
        filter.value = 'performer'; filter.dispatchEvent(new Event('input', { bubbles: true }));
        var shown = tree.querySelectorAll('li[data-id]');
        expect(shown.length >= 1 && Array.prototype.every.call(shown, function (li) { return li.getAttribute('data-id') === Outline.idOf(owner) || /performer/i.test(li.textContent) || li.getAttribute('aria-level') === '3'; }), 'the filter shows rows that do not match');
        filter.value = ''; filter.dispatchEvent(new Event('input', { bubbles: true }));
        // closed, it is gone and the miniature has its place again
        document.querySelector('#panel .close').click(); await sleep(50);
        expect(panel.hidden && !document.body.classList.contains('panel-open'), 'the panel did not close');
        EventHandler.clearSelection();
    });
    test('the XML view shows the model, and text that is right becomes the model, and text that is not is left out', async function () {
        await load(window.__MODELS['example.xml']);
        // the text that is made of a model is the model
        var round = XmlText.pretty(Model.toXML(false)), again = new DOMParser().parseFromString(round, 'application/xml');
        expect(!again.getElementsByTagName('parsererror').length, 'the text made of the model is not XML');
        expect(canonical(again.documentElement) === xmlOf(), 'the text made of the model is not the model: ' + difference(canonical(again.documentElement), xmlOf()));
        record('xml.lines', round.split('\n').length);
        // the view
        var panel = document.getElementById('panel'), text = document.getElementById('xmlText'), status = document.getElementById('xmlStatus');
        Outline.setOpen(true, true);
        document.getElementById('tab-xml').click(); await sleep(100);
        expect(!document.getElementById('view-xml').hidden && document.getElementById('view-outline').hidden && document.body.classList.contains('panel-wide')
            && document.getElementById('tab-xml').getAttribute('aria-selected') === 'true' && document.getElementById('tab-outline').getAttribute('aria-selected') === 'false', 'the tab did not show the view');
        expect(/^<\?xml/.test(text.value) && /<schema /.test(text.value), 'the text is not the XML of the model');
        // the model changes, the text follows
        var anchor = ofType(NodeType.ANCHOR)[0], was = anchor.descriptor;
        anchor.descriptor = 'Performer'; Model.recordState(); await sleep(100);
        expect(text.value.indexOf('descriptor="Performer"') >= 0, 'the text did not follow a change in the model');
        // the text changes, the model follows, once it is right
        var version = Model.version;
        text.value = text.value.replace('descriptor="Performer"', 'descriptor="Dancer"');
        text.dispatchEvent(new Event('input', { bubbles: true }));
        expect(/Checking/.test(status.textContent), 'nothing says that the text is being checked');
        await sleep(1200);
        var after = ofType(NodeType.ANCHOR).filter(function (a) { return a.descriptor === 'Dancer'; });
        expect(after.length === 1, 'the model did not follow the text');
        expect(Model.version === version + 1 && /Applied/.test(status.textContent), 'the change was not a step in the history, or it was not said: ' + status.textContent);
        // and it can be undone, and the text follows that too
        ControlButtons.undo(); await sleep(400);
        expect(ofType(NodeType.ANCHOR).filter(function (a) { return a.descriptor === 'Dancer'; }).length === 0, 'undo did not take the change from the text back');
        expect(text.value.indexOf('descriptor="Dancer"') < 0, 'the text did not follow the undo');
        // text that is not XML is not believed, and the problem is said
        var good = text.value, count = ofType(NodeType.ANCHOR).length, names = ofType(NodeType.ANCHOR).map(function (a) { return a.descriptor; }).join();
        text.value = good.slice(0, good.length - 40);
        text.dispatchEvent(new Event('input', { bubbles: true })); await sleep(1200);
        expect(/not been changed/.test(status.textContent) && document.querySelectorAll('#xmlProblems li').length >= 1 && document.getElementById('xmlView').classList.contains('bad'), 'text that is not XML was not refused: ' + status.textContent);
        expect(ofType(NodeType.ANCHOR).map(function (a) { return a.descriptor; }).join() === names, 'the model changed although the text was not XML');
        // text that is XML but not right (two anchors with one mnemonic) is not believed either
        var first = /<anchor mnemonic="(\w\w)"/.exec(good)[1];
        text.value = good.replace(/(<anchor mnemonic=")(\w\w)(")/g, function (m, a, mn, c) { return a + first + c; });
        text.dispatchEvent(new Event('input', { bubbles: true })); await sleep(1200);
        expect(document.querySelectorAll('#xmlProblems li').length >= 1 && ofType(NodeType.ANCHOR).map(function (a) { return a.descriptor; }).join() === names, 'text with one mnemonic for every anchor was believed: ' + status.textContent);
        record('xml.problem', document.querySelector('#xmlProblems li').textContent.replace(/\b[A-Z]{2}\b/g, 'XX').slice(0, 60));
        // what is being typed is not replaced by the model
        text.focus(); text.value = good + '<!-- a note -->'; text.dispatchEvent(new Event('input', { bubbles: true }));
        Model.recordState(); await sleep(100);
        expect(text.value.indexOf('a note') >= 0, 'the text that was being typed was replaced by the model');
        clearTimeout(XmlView.timer); text.blur(); XmlView.dirty = false;
        // copy
        var written = [];
        Object.defineProperty(navigator, 'clipboard', { value: { writeText: function (s) { written.push(s); return Promise.resolve(); } }, configurable: true });
        try { XmlView.copy(); await sleep(300); } finally { delete navigator.clipboard; }
        expect(written.length === 1 && written[0] === text.value, 'copy did not give the text to the clipboard');
        expect(status.textContent === 'Copied.', 'copy did not say that it copied: ' + status.textContent);
        // the tabs have the keys of tabs
        var tab = document.getElementById('tab-xml');
        tab.dispatchEvent(new KeyboardEvent('keydown', { key: 'ArrowLeft', bubbles: true, cancelable: true })); await sleep(100);
        expect(Outline.view === 'outline' && !document.getElementById('view-outline').hidden && !document.body.classList.contains('panel-wide'), 'Left did not show the outline');
        Outline.setOpen(false, true);
        anchor.descriptor = was;
    });
    test('bubbles and role names sit on their edges, also after a sudden move', async function () {
        await load(window.__MODELS['example.xml']);
        function worst() {
            var max = 0;
            Model.components.forEach(function (c) {
                if (c.node.type === NodeType.EDGE && (c.tied || c.chronicable) && sv(c).graphicsElement) {
                    var m = sv(c).graphicsElement.transform.baseVal.getItem(0).matrix, p = sv(c).pathElement, L = p.getTotalLength();
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

    // What every control of the menu bar does, found without doing it: the functions of Actions and Settings, and the few
    // others that the menus call, are replaced by recorders, and each menu item is clicked and each field is changed.
    // What is recorded for a control is the list of calls it made. A control that is wired in another way, but calls the
    // same functions with the same arguments, gives the same record.
    test('every menu item and every settings field calls what it called', async function () {
        await load(window.__MODELS['example.xml']);
        var calls = [], restore = [];
        function show(a) {
            if (typeof a === 'string') return a.length > 60 ? '<string>' : JSON.stringify(a);
            if (a && a.nodeType) return '<element ' + (a.id || a.nodeName) + '>';
            if (a && typeof a === 'object') return '<object>';
            return String(a);
        }
        function recorder(name) { return function () { calls.push(name + '(' + Array.prototype.map.call(arguments, show).join(', ') + ')'); }; }
        // a few menu items call a function of Actions that only makes the calls the markup used to make itself (see Wiring.js);
        // it is left as it is, so that what is recorded for the item is those calls, as it was
        var wrappers = ['chooseModelFile', 'saveSettingsInBrowser', 'saveModelToDisk', 'saveSVGToDisk', 'mailModel', 'resetView', 'screenshotSVG', 'screenshotPNG', 'openTutorials', 'openAbout'];
        function replaceAll(owner, ownerName) {
            Object.keys(owner).forEach(function (k) {
                if (typeof owner[k] === 'function' && wrappers.indexOf(k) < 0) { restore.push([owner, k, owner[k]]); owner[k] = recorder(ownerName + '.' + k); }
            });
        }
        replaceAll(Actions, 'Actions'); replaceAll(Settings, 'Settings');
        // three menu items used to call save() and URLPopover() from the markup; the page imports them now, where a test cannot
        // reach them, so the functions that stand for them record what the markup used to call
        var legacy = {
            saveSettingsInBrowser: 'save(<object>, true)',
            openTutorials: 'URLPopover("http://www.anchormodeling.com/?page_id=186")',
            openAbout: 'URLPopover("about.html")'
        };
        Object.keys(legacy).forEach(function (k) {
            restore.push([Actions, k, Actions[k]]);
            Actions[k] = function () { calls.push(legacy[k]); };
        });
        restore.push([HTMLInputElement.prototype, 'click', HTMLInputElement.prototype.click]);
        HTMLInputElement.prototype.click = function () { calls.push('input.click(' + this.id + ')'); };
        var controls = Array.prototype.slice.call(document.querySelectorAll('#header li, #header input, #header select, #header button[data-action], #modelSettings input, #modelSettings select, #modelSettings button[data-action]'));
        var seen = {};
        try {
            controls.forEach(function (el, i) {
                var clicks = el.tagName === 'LI' || el.tagName === 'BUTTON', menu = el.closest('.menu, #modelSettings'), label = clicks ? (el.getAttribute('aria-label') || el.textContent).replace(/\s+/g, ' ').trim().slice(0, 40) : (el.id || 'field' + i);
                var key = 'wiring.' + (clicks ? 'item.' : 'field.') + (menu ? menu.id : 'bar') + '.' + label;
                if (seen[key]) key += '#' + i;
                seen[key] = true;
                var before = calls.length;
                if (clicks) {
                    el.dispatchEvent(new MouseEvent('click', { bubbles: true }));
                } else {
                    var value = el.value, checked = el.checked, index = el.selectedIndex;
                    if (el.type === 'checkbox') el.checked = !el.checked;
                    else if (el.tagName === 'SELECT') el.selectedIndex = el.options.length - 1;
                    else if (el.type === 'number') el.value = '5';
                    else el.value = 'x';
                    el.dispatchEvent(new Event('change', { bubbles: true }));
                    el.dispatchEvent(new Event('blur'));
                    if (el.id === 'searchFilter' || el.id === 'nodeSelector') { el.dispatchEvent(new Event('focus')); el.dispatchEvent(new MouseEvent('mouseover')); }
                    el.value = value; el.checked = checked; el.selectedIndex = index;
                }
                record(key, calls.slice(before).join(' ; ') || '-');
            });
        } finally {
            restore.reverse().forEach(function (r) { r[0][r[1]] = r[2]; });
        }
        expect(controls.length > 80, 'only ' + controls.length + ' controls');
    });

    test('the item that loads a model can be opened with Enter and Space on the keyboard', async function () {
        var item = Array.prototype.filter.call(document.querySelectorAll('#file li'), function (li) { return /Load model from local file/.test(li.textContent); })[0];
        expect(item && item.getAttribute('role') === 'menuitem' && item.hasAttribute('tabindex'), 'no item that the keyboard can reach');
        var clicks = [], click = HTMLInputElement.prototype.click;
        HTMLInputElement.prototype.click = function () { clicks.push(this.id); };
        try {
            var enter = new KeyboardEvent('keydown', { key: 'Enter', bubbles: true, cancelable: true });
            item.dispatchEvent(enter);
            var space = new KeyboardEvent('keydown', { key: ' ', bubbles: true, cancelable: true });
            item.dispatchEvent(space);
            var other = new KeyboardEvent('keydown', { key: 'a', bubbles: true, cancelable: true });
            item.dispatchEvent(other);
        } finally { HTMLInputElement.prototype.click = click; }
        expect(clicks.join() === 'modelFileInput,modelFileInput', 'clicks: ' + clicks.join());
        expect(enter.defaultPrevented && space.defaultPrevented && !other.defaultPrevented, 'the keys were not handled as they should');
    });

    // A dialog that cannot be closed traps the user: its close button has to be there to see (it is drawn from an image), and
    // Escape has to close it too.
    async function imageLoads(url) {
        return new Promise(function (resolve) { var i = new Image(); i.onload = function () { resolve(i.naturalWidth > 0); }; i.onerror = function () { resolve(false); }; i.src = url; });
    }
    async function checkDialog(name, open, selector) {
        await load(window.__MODELS['example.xml']);
        open();
        await sleep(600);
        var dialog = document.querySelector(selector);
        expect(dialog, name + ' did not open');
        var button = dialog.querySelector('.closebutton');
        expect(button, name + ' has no close button');
        var style = getComputedStyle(button), box = button.getBoundingClientRect();
        expect(style.display !== 'none' && box.width > 10 && box.height > 10, name + ': the close button is ' + Math.round(box.width) + 'x' + Math.round(box.height) + ', display ' + style.display);
        var url = (style.backgroundImage.match(/url\("?([^")]+)"?\)/) || [])[1];
        expect(url, name + ': the close button has no image');
        expect(await imageLoads(url), name + ': the image of the close button (' + url.replace(/.*\//, '') + ') cannot be loaded');
        press('Escape');
        await sleep(100);
        expect(!document.querySelector(selector), name + ' was not closed by Escape');
        closeOverlays();
    }
    test('the SQL and XML dialog has a close button that shows, and Escape closes it', async function () {
        await checkDialog('the XML dialog', function () { Actions.generateXML(); }, '#codePopover');
    });
    test('the mass editor has a close button that shows, and Escape closes it', async function () {
        await checkDialog('the mass editor', function () { new TabularEditor(''); }, '#tabularEditor');
    });
    test('the page dialog (Help, About) has a close button that shows, and Escape closes it', async function () {
        await checkDialog('the About dialog', function () { Actions.openAbout(); }, '#urlPopover');
    });

    // --- what is drawn for the constructs: the graph, the names, the miniature --------------------------------------------------
    // These pin down the drawing of every construct before it is moved from the construct classes into views. They reach the SVG
    // elements of a component the way the page does, whichever object holds them.
    function sv(c) { return c.svg || (c.view && c.view.svg); }
    function nv(c) { return c.nav || (c.view && c.view.nav); }
    function href(el) { return el && el.getAttributeNS('http://www.w3.org/1999/xlink', 'href'); }
    function kind(c) { return NodeType[c.node.type]; }

    test('every construct is drawn in the graph and in the miniature, with the shape of its kind', async function () {
        await load(window.__MODELS['example.xml']);
        await sleep(300);
        var shapes = {}, navShapes = {}, missing = [];
        Model.components.forEach(function (c) {
            var s = sv(c), n = nv(c);
            if (!s || !n) { missing.push(kind(c)); return; }
            var key = kind(c) + ' ' + (c.visible ? 'visible' : 'hidden') + ' ' + href(s.useElement || s.graphicsElement && s.graphicsElement.firstChild);
            shapes[key] = (shapes[key] || 0) + 1;
            var nkey = kind(c) + ' ' + href(n.useElement);
            navShapes[nkey] = (navShapes[nkey] || 0) + 1;
        });
        expect(missing.length === 0, 'no drawing for ' + missing.join());
        function list(o) { return Object.keys(o).sort().map(function (k) { return k + '=' + o[k]; }).join('; '); }
        record('view.shapes', list(shapes));
        record('view.navShapes', list(navShapes));
        record('view.layers', ['nodes', 'edges', 'names'].map(function (l) { return l + '=' + SVGLayer[l].childNodes.length; }).join(' ') + ' nav ' + ['nodes', 'edges'].map(function (l) { return l + '=' + NAVLayer[l].childNodes.length; }).join(' '));
    });

    test('every construct that has a name shows it, with the class of its kind', async function () {
        var classes = {}, count = 0;
        Model.components.forEach(function (c) {
            var s = sv(c);
            if (s.nameElement) { count++; var k = kind(c) + ' ' + ((s.nameElement.getAttribute('class') || '').replace(/(^| )(end|bad)(?= |$)/g, '').trim() || '-'); classes[k] = (classes[k] || 0) + 1; }
        });
        record('view.names', count + ': ' + Object.keys(classes).sort().map(function (k) { return k + '=' + classes[k]; }).join('; '));
        var anchor = ofType(NodeType.ANCHOR)[0];
        record('view.anchorName', sv(anchor).nameText.nodeValue);
    });

    test('the pointer over a construct highlights it, and leaving removes it', async function () {
        await fresh();
        var anchor = ofType(NodeType.ANCHOR)[0], s = sv(anchor);
        hover(anchor);
        var on = anchor.highlighted && s.graphicsElement.contains(s.highlightElement) && s.graphicsElement.firstChild === s.highlightElement;
        EventHandler.clearInteraction();
        var off = !anchor.highlighted && !s.graphicsElement.contains(s.highlightElement);
        record('view.highlight', 'on=' + on + ' off=' + off);
        expect(on && off, 'highlight on ' + on + ', off ' + off);
    });

    test('a selected construct has a selection mark that goes when it is deselected', async function () {
        var anchor = ofType(NodeType.ANCHOR)[0], s = sv(anchor);
        EventHandler.addComponentToSelection(anchor);
        var on = anchor.selected && s.graphicsElement.firstChild === s.selectionElement;
        EventHandler.removeComponentFromSelection(anchor);
        var off = !anchor.selected && !s.graphicsElement.contains(s.selectionElement);
        record('view.selection', 'on=' + on + ' off=' + off);
        expect(on && off, 'selection on ' + on + ', off ' + off);
    });

    test('a fixed construct shows a fixation mark, and releasing it removes the mark', async function () {
        var anchor = ofType(NodeType.ANCHOR)[0], s = sv(anchor);
        anchor.setFixed(true);
        var on = anchor.getFixed() === true && s.graphicsElement.contains(s.fixationElement);
        anchor.setFixed(false);
        var off = anchor.getFixed() === false && !s.graphicsElement.contains(s.fixationElement);
        hover(anchor); press('p');
        var byKey = anchor.getFixed() === true && s.graphicsElement.contains(s.fixationElement);
        anchor.setFixed(false);
        record('view.fixation', 'on=' + on + ' off=' + off + ' key=' + byKey);
        expect(on && off && byKey, 'fixation on ' + on + ', off ' + off + ', by key ' + byKey);
    });

    test('hiding a construct takes its drawing out of the layers, and showing puts it back', async function () {
        await load(window.__MODELS['example.xml']);
        var anchor = ofType(NodeType.ANCHOR)[0], s = sv(anchor), n = nv(anchor);
        var role = ofType(NodeType.EDGE)[0], rs = sv(role);
        var before = [SVGLayer.nodes.contains(s.graphicsElement), NAVLayer.nodes.contains(n.graphicsElement), SVGLayer.names.contains(s.nameElement), SVGLayer.edges.contains(rs.pathElement)];
        anchor.hide(); role.hide();
        var hidden = [anchor.visible, SVGLayer.nodes.contains(s.graphicsElement), NAVLayer.nodes.contains(n.graphicsElement), SVGLayer.names.contains(s.nameElement), SVGLayer.edges.contains(rs.pathElement), NAVLayer.edges.contains(nv(role).pathElement)];
        anchor.show(); role.show();
        var shown = [anchor.visible, SVGLayer.nodes.contains(s.graphicsElement), NAVLayer.nodes.contains(n.graphicsElement), SVGLayer.names.contains(s.nameElement), SVGLayer.edges.contains(rs.pathElement), NAVLayer.edges.contains(nv(role).pathElement)];
        record('view.hideShow', 'before=' + before.join() + ' hidden=' + hidden.join() + ' shown=' + shown.join());
        expect(before.join() === 'true,true,true,true' && hidden.join() === 'false,false,false,false,false,false' && shown.join() === 'true,true,true,true,true,true', before.join() + ' / ' + hidden.join() + ' / ' + shown.join());
    });

    test('imploding anchors and nexuses changes their shape, and exploding restores it', async function () {
        await load(window.__MODELS['example.xml']);
        function shapes() { return ofType(NodeType.ANCHOR).concat(ofType(NodeType.NEXUS)).map(function (c) { return kind(c) + ':' + href(sv(c).useElement) + ':' + href(nv(c).useElement); }).sort().join(' '); }
        var before = shapes();
        Actions.implodeAll(); await sleep(300);
        var imploded = shapes();
        Actions.explodeAll(); await sleep(300);
        var after = shapes();
        record('view.implode', 'before=' + before + ' imploded=' + imploded + ' after=' + after);
        expect(/Nexus:#nexus_imploded/.test(imploded) && /Nexus:#nexus:/.test(after), 'a nexus does not change its shape when it is imploded and exploded: ' + imploded + ' / ' + after);
        expect(before === after && before !== imploded, 'before ' + before + ' / imploded ' + imploded + ' / after ' + after);
    });

    test('the shape of an attribute, an identifier, a tie and a role follows what it is', async function () {
        await load(window.__MODELS['example.xml']);
        var attribute = ofType(NodeType.ATTRIBUTE).filter(function (a) { return a.operations.indexOf('toggleHistorized') >= 0; })[0], tie = ofType(NodeType.TIE)[0];
        var out = [];
        function shape(c) { return href(sv(c).useElement) + '/' + href(nv(c).useElement); }
        out.push('attribute ' + attribute.historized + ' ' + shape(attribute));
        attribute.setHistorized(!attribute.historized);
        out.push('attribute ' + attribute.historized + ' ' + shape(attribute));
        out.push('tie ' + tie.historized + ' ' + shape(tie));
        tie.setHistorized(!tie.historized);
        out.push('tie ' + tie.historized + ' ' + shape(tie));
        var roles = ofType(NodeType.EDGE).filter(function (r) { return r.tied; });
        roles.slice(0, 3).forEach(function (r) {
            out.push('role ' + r.identifier + ' ' + href(sv(r).useElement));
            r.setIdentifier(!r.identifier);
            out.push('role ' + r.identifier + ' ' + href(sv(r).useElement));
        });
        var identifiers = ofType(NodeType.IDENTIFIER);
        if (identifiers.length) { var i = identifiers[0]; out.push('identifier ' + i.historized + ' ' + shape(i)); i.setHistorized(!i.historized); out.push('identifier ' + i.historized + ' ' + shape(i)); }
        record('view.shapesFollow', out.join('; '));
    });

    test('the names show mnemonics or descriptors and can be hidden', async function () {
        await load(window.__MODELS['example.xml']);
        await sleep(300);
        var anchor = ofType(NodeType.ANCHOR)[0], s = sv(anchor), out = [];
        out.push(s.nameText.nodeValue);
        Actions.toggleMnemonics(); DrawingEngine.draw(); await sleep(100);
        out.push(s.nameText.nodeValue);
        Actions.toggleMnemonics(); DrawingEngine.draw(); await sleep(100);
        out.push(s.nameText.nodeValue);
        var shown = SVGLayer.isShowing('names');
        Actions.toggleNames(); await sleep(100);
        out.push('names layer ' + shown + ' -> ' + SVGLayer.isShowing('names'));
        Actions.toggleNames(); await sleep(100);
        out.push('and back ' + SVGLayer.isShowing('names'));
        record('view.names.toggle', out.join(' | '));
    });

    test('a node can be dragged with the mouse, and then stays where it was put', async function () {
        await load(window.__MODELS['example.xml']);
        await settle();
        var anchor = ofType(NodeType.ANCHOR)[0], s = sv(anchor), svg = document.getElementById('graph');
        var box = s.graphicsElement.getBoundingClientRect(), x = box.left + box.width / 2, y = box.top + box.height / 2;
        var startX = anchor.node.xPosition, startY = anchor.node.yPosition;
        hover(anchor);
        s.graphicsElement.dispatchEvent(new MouseEvent('mousedown', { clientX: x, clientY: y, button: 0, bubbles: true, cancelable: true }));
        svg.dispatchEvent(new MouseEvent('mousemove', { clientX: x + 20, clientY: y + 20, bubbles: true, cancelable: true }));
        svg.dispatchEvent(new MouseEvent('mousemove', { clientX: x + 120, clientY: y + 60, bubbles: true, cancelable: true }));
        var dragging = EventHandler.getInteraction();
        window.dispatchEvent(new MouseEvent('mouseup', { clientX: x + 120, clientY: y + 60, bubbles: true }));
        var moved = Math.abs(anchor.node.xPosition - startX) > 50 || Math.abs(anchor.node.yPosition - startY) > 30;
        record('view.drag', 'interaction=' + dragging + ' moved=' + moved + ' fixed=' + anchor.getFixed() + ' fixationMark=' + s.graphicsElement.contains(s.fixationElement));
        expect(moved, 'the node did not move with the mouse');
        anchor.setFixed(false);
        EventHandler.clearInteraction();
    });

    // The model is its own layer: with the views and the page's hooks switched off, constructs can still be made, changed, saved
    // as XML and read again. (The page is put back as it was afterwards.)
    test('the model works without a view: constructs are made, changed, saved and read back', async function () {
        var createView = Component.createView, surroundings = Model.surroundings, asked = {};
        var quiet = {};
        Object.keys(surroundings).forEach(function (k) { quiet[k] = function () { asked[k] = (asked[k] || 0) + 1; return k === 'selectedRoute' ? null : undefined; }; });
        var drawn = SVGLayer.nodes.childNodes.length + SVGLayer.edges.childNodes.length;
        try {
            Component.createView = null; Model.surroundings = quiet;
            Model.components.forEach(function (c) { c.view = null; });
            Model.setupMinimal(false);
            var anchor = ofType(NodeType.ANCHOR)[0];
            expect(anchor.view === null, 'the anchor has a view');
            anchor.mnemonic = 'AC'; anchor.descriptor = 'Actor';
            Model.addAttribute([anchor]);
            var attribute = ofType(NodeType.ATTRIBUTE)[0];
            attribute.mnemonic = 'NAM'; attribute.descriptor = 'Name';
            Model.toggleHistorized([attribute]);
            Model.addTieAndAnchor([anchor]);
            Model.addNexus([anchor]);
            anchor.setFixed(true); anchor.setSelection(true); anchor.setHighlight(true); anchor.hide(); anchor.show();
            var before = counts(), xml = xmlOf();
            Model.fromXML(Model.toXML(false));
            expect(xmlOf() === xml, 'the model changed when it was saved and read again');
            record('headless.counts', before);
            record('headless.asked', Object.keys(asked).sort().join(','));
            expect(Model.components.every(function (c) { return c.view === null; }), 'a construct got a view');
            expect((SVGLayer.nodes.childNodes.length + SVGLayer.edges.childNodes.length) === drawn, 'something was drawn');
        } finally {
            Component.createView = createView; Model.surroundings = surroundings;
        }
        await load(window.__MODELS['example.xml']);
    });

    test('the menus offer what they did', async function () {
        var items = Array.prototype.map.call(document.querySelectorAll('#header .menu'), function (m) { return m.querySelector('.menulabel').textContent.trim() + ':' + m.querySelectorAll('li').length; });
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
