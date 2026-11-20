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
        ['codePopover', 'contextMenu', 'urlPopover'].forEach(function (id) {
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
        press('E', { shiftKey: true }); // the mass editor that this used to open is gone (the outline and the XML view do what it did)
        expect(!document.getElementById('tabularEditor') && typeof TabularEditor === 'undefined', 'the mass editor is still there');
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
        expect(document.querySelectorAll('#generate li').length === 5 && document.querySelectorAll('#generate li[data-action]').length === 5, 'the Generate menu holds more than commands');
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
        expect(Model.version > version && /Applied|The text is the model/.test(status.textContent), 'the change was not a step in the history, or it was not said: ' + status.textContent);
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
        expect(Outline.view === 'problems' && !document.getElementById('view-problems').hidden && !document.body.classList.contains('panel-wide'), 'Left did not show the view before it');
        document.getElementById('tab-problems').dispatchEvent(new KeyboardEvent('keydown', { key: 'Home', bubbles: true, cancelable: true })); await sleep(100);
        expect(Outline.view === 'outline' && !document.getElementById('view-outline').hidden, 'Home did not show the first view');
        Outline.setOpen(false, true);
        anchor.descriptor = was;
    });
    test('the problems panel lists what ModelCheck finds and some hints, and each line selects what it is about', async function () {
        await load(window.__MODELS['example.xml']);
        var tabCount = document.querySelector('#tab-problems .count'), buttonCount = document.querySelector('#panelButton .count');
        Outline.setOpen(true, true);
        document.getElementById('tab-problems').click(); await sleep(300);
        var view = document.getElementById('view-problems'), status = document.getElementById('problemStatus');
        expect(!view.hidden && document.getElementById('tab-problems').getAttribute('aria-selected') === 'true', 'the tab did not show the view');
        expect(Problems.problems.length === 0 && tabCount.textContent === '' && buttonCount.textContent === '', 'a model that the modeler writes has problems: ' + Problems.problems.map(function (p) { return p.text; }).join(' | '));
        expect(/^No problems/.test(status.textContent), 'the status does not say that there are none: ' + status.textContent);
        // two anchors with one mnemonic
        var anchors = ofType(NodeType.ANCHOR), second = anchors[1], mnemonic = second.mnemonic;
        second.mnemonic = anchors[0].mnemonic; Model.recordState(); await sleep(500);
        var errors = document.querySelectorAll('#problemList li.error button.problem');
        var direct = ''; if (!errors.length) { try { Problems.update(); direct = ' (direct update: ' + Problems.problems.length + ' problems, shown ' + Problems.isShown + ')'; } catch (e) { direct = ' (update fails: ' + e + ')'; } }
        expect(errors.length >= 1 && tabCount.textContent === String(Problems.problems.length) && buttonCount.textContent === tabCount.textContent, 'the problem was not found, or not counted: ' + status.textContent + direct);
        expect(/^\d+ problems?/.test(status.textContent) && document.getElementById('problemView').classList.contains('bad'), 'the status does not say how many: ' + status.textContent);
        var duplicate = Array.prototype.filter.call(errors, function (b) { return /same mnemonic/.test(b.textContent); })[0];
        expect(duplicate && !duplicate.disabled, 'there is no line for the duplicate mnemonic that can be clicked');
        EventHandler.clearSelection();
        duplicate.click(); await sleep(300);
        expect(EventHandler.selectedComponents.length === 1 && EventHandler.selectedComponents[0].node.type === NodeType.ANCHOR && EventHandler.selectedComponents[0].mnemonic === anchors[0].mnemonic, 'the line did not select the anchor');
        expect(/^Anchor: /.test(document.querySelector('#problemProperties h3').textContent) && document.querySelector('#problemProperties input.editable'), 'the properties are not shown under the problems');
        record('problems.line', duplicate.textContent.replace(/\b[A-Z]{2}\b/g, 'XX'));
        // putting it right takes the problem away
        second.mnemonic = mnemonic; Model.recordState(); await sleep(500);
        expect(Problems.problems.length === 0 && tabCount.textContent === '' && buttonCount.textContent === '', 'the problem is still there after it was put right');
        // hints
        var third = anchors[2], description = third.description;
        third.description = ''; Model.recordState(); await sleep(500);
        var hint = Array.prototype.filter.call(document.querySelectorAll('#problemList li.hint button.problem'), function (b) { return /has no description/.test(b.textContent) && b.getAttribute('data-id') === Outline.idOf(third); })[0];
        expect(hint, 'there is no hint that an anchor has no description');
        expect(tabCount.textContent === '', 'a hint was counted as a problem');
        third.description = description;
        // a setting that the model needs is missing: the line opens the settings
        var keep = Defaults.changingSuffix; Defaults.changingSuffix = '';
        Model.recordState(); await sleep(500);
        var setting = document.querySelector('#problemList button.problem[data-settings]');
        expect(setting && /metadata/i.test(setting.textContent), 'a missing setting was not found');
        setting.click(); await sleep(100);
        expect(document.getElementById('modelSettings').open, 'the line did not open the settings');
        Actions.closeModelSettings();
        Defaults.changingSuffix = keep; Model.recordState(); await sleep(400);
        expect(Problems.problems.length === 0, 'the setting is back and there are still problems');
        Outline.setOpen(false, true);
        EventHandler.clearSelection();
    });
    test('new things are put by what they are tied to: what was there keeps its place', async function () {
        var parse = function () { return new DOMParser().parseFromString(window.__MODELS['example.xml'], 'application/xml'); };
        var doc = parse(), constructs = Placement.constructs(doc), centre = { x: 600, y: 400 };
        expect(constructs.length > 30, 'only ' + constructs.length + ' constructs');
        expect(constructs.every(function (c) { return !Placement.layoutOf(c.element); }), 'the model has places already');
        var written = Placement.seed(doc, {}, centre);
        expect(written === constructs.length, 'only ' + written + ' of ' + constructs.length + ' were given a place');
        var at = Placement.positions(doc), keys = Object.keys(at);
        expect(keys.length === constructs.length && keys.every(function (k) { return isFinite(at[k].x) && isFinite(at[k].y); }), 'a place is not a number');
        var distinct = {}; keys.forEach(function (k) { distinct[at[k].x + ',' + at[k].y] = true; });
        expect(Object.keys(distinct).length === keys.length, 'two constructs have the same place');
        var far = keys.filter(function (k) { return Math.hypot(at[k].x - centre.x, at[k].y - centre.y) > 1500; });
        expect(far.length === 0, 'these are far from the middle: ' + far.join(', '));
        // a tie is between what it ties, an attribute around its anchor, a knot beside what uses it
        var d = LayoutEngine.normalDistance;
        constructs.filter(function (c) { return c.kind === 'attribute'; }).forEach(function (c) {
            var owner = at[c.owner], me = at[c.key], r = Math.hypot(me.x - owner.x, me.y - owner.y);
            expect(Math.abs(r - 3 * d) < 1, 'an attribute is ' + r.toFixed(1) + ' from its anchor');
        });
        var nearTies = constructs.filter(function (c) { return c.kind === 'tie'; }).every(function (c) {
            var ends = Placement.children(c.element, 'role').map(function (r) { return constructs.filter(function (e) { return e.kind !== 'tie' && e.element.getAttribute('mnemonic') === r.getAttribute('type') && Placement.ENTITIES.indexOf(e.kind) >= 0; })[0]; }).filter(Boolean).map(function (e) { return at[e.key]; });
            var mx = ends.reduce(function (s, p) { return s + p.x; }, 0) / ends.length, my = ends.reduce(function (s, p) { return s + p.y; }, 0) / ends.length;
            return Math.hypot(at[c.key].x - mx, at[c.key].y - my) < 3 * d;
        });
        expect(nearTies, 'a tie is not between what it ties');
        record('placement.written', written);
        // nothing left to do the second time
        expect(Placement.seed(doc, at, centre) === 0, 'places were written for things that have them');
        // what was there keeps its place, with its fixation, and what is tied to it is put beside it
        var again = parse();
        Placement.seed(again, { 'anchor:AC': { x: 11, y: 22, fixed: 'true', imploded: null } }, centre);
        var kept = Placement.positions(again)['anchor:AC'];
        expect(kept.x === 11 && kept.y === 22 && kept.fixed === 'true', 'what was there lost its place');
        var tied = Placement.positions(again)['anchor:PE'] || Placement.positions(again)['anchor:ST'];
        expect(tied && Math.hypot(tied.x - 11, tied.y - 22) < 1500, 'a new anchor is not placed');
    });

    test('a model that has no positions is placed by what is tied to what, and all of it is in view', async function () {
        await load(window.__MODELS['example.xml']);
        await sleep(300);
        var box = SVG.viewBox.baseVal, margin = 40, outside = Model.visibleNodes.filter(function (n) {
            return n.type !== NodeType.EDGE && (n.xPosition < box.x - margin || n.xPosition > box.x + box.width + margin || n.yPosition < box.y - margin || n.yPosition > box.y + box.height + margin);
        });
        expect(outside.length === 0, outside.length + ' of the nodes are out of view');
        // those that are tied are nearer each other than the ends of the model are: the average length of an edge is shorter than half the width of the model
        var xs = Model.visibleNodes.map(function (n) { return n.xPosition; }), ys = Model.visibleNodes.map(function (n) { return n.yPosition; });
        var width = Math.max.apply(null, xs) - Math.min.apply(null, xs), height = Math.max.apply(null, ys) - Math.min.apply(null, ys);
        var lengths = Model.components.filter(function (c) { return c.node.type === NodeType.EDGE && c.visible; }).map(function (c) { return Math.hypot(c.node.node.xPosition - c.node.otherNode.xPosition, c.node.node.yPosition - c.node.otherNode.yPosition); });
        var mean = lengths.reduce(function (s, l) { return s + l; }, 0) / lengths.length;
        expect(mean < Math.max(width, height) / 2, 'the edges are ' + mean.toFixed(0) + ' long on average in a model that is ' + width.toFixed(0) + ' by ' + height.toFixed(0));
    });
    test('code that is shown can be copied and downloaded as a file', async function () {
        await load(window.__MODELS['example.xml']);
        var written = [], saved = [], realBlob = Actions.downloadBlob;
        Object.defineProperty(navigator, 'clipboard', { value: { writeText: function (s) { written.push(s); return Promise.resolve(); } }, configurable: true });
        Actions.downloadBlob = function (blob, name) { saved.push({ blob: blob, name: name }); };
        try {
            var kinds = [['generateXML', /\.xml$/, 'Download .xml', 'application/xml'], ['generateBindings', /\.json$/, 'Download .json', 'application/json'], ['generateSQL', /\.sql$/, 'Download .sql', 'text/plain']];
            for (var i = 0; i < kinds.length; i++) {
                closeOverlays(); written.length = 0; saved.length = 0;
                Actions[kinds[i][0]]();
                for (var w = 0; w < 80 && !document.querySelector('#codePopover .codebar'); w++) await sleep(50);
                var bar = document.querySelector('#codePopover .codebar');
                expect(bar, kinds[i][0] + ' has no buttons to copy and download');
                var buttons = bar.querySelectorAll('button');
                expect(buttons.length === 2 && buttons[0].textContent === 'Copy' && buttons[1].textContent === kinds[i][2], kinds[i][0] + ' has the buttons ' + Array.prototype.map.call(buttons, function (b) { return b.textContent; }).join(', '));
                var shown = document.querySelector('#codePopover #content').textContent;
                expect(shown.length > 200, kinds[i][0] + ' shows nothing');
                buttons[0].click(); await sleep(100);
                expect(written.length === 1 && written[0] === shown, kinds[i][0] + ': the copy is not what is shown');
                buttons[1].click(); await sleep(100);
                expect(saved.length === 1 && kinds[i][1].test(saved[0].name) && saved[0].blob.type.indexOf(kinds[i][3]) === 0, kinds[i][0] + ': the download is ' + (saved[0] && saved[0].name + ' ' + saved[0].blob.type));
                var text = await new Promise(function (resolve) { var r = new FileReader(); r.onload = function () { resolve(r.result); }; r.readAsText(saved[0].blob); });
                expect(text === shown, kinds[i][0] + ': the file is not what is shown');
            }
        } finally { delete navigator.clipboard; Actions.downloadBlob = realBlob; closeOverlays(); }
    });

    test('the documentation is a page that tells the model: every construct, its description, what it is tied to, and links that lead somewhere', async function () {
        await load(window.__MODELS['example.xml']);
        await sleep(500);
        var html = Documentation.html(), page = new DOMParser().parseFromString(html, 'text/html');
        expect(/^<!DOCTYPE html>/i.test(html) && !/<link\b|<script\b/i.test(html), 'the page is not one file with everything in it');
        expect(page.querySelector('h1') && page.querySelector('title').textContent.indexOf('documentation') > 0, 'the page has no title');
        // a section for each construct
        var counts = { anchor: ofType(NodeType.ANCHOR).length, nexus: ofType(NodeType.NEXUS).length, tie: ofType(NodeType.TIE).length, knot: ofType(NodeType.KNOT).length };
        Object.keys(counts).forEach(function (k) { expect(page.querySelectorAll('section.entity.' + k).length === counts[k], 'the page has ' + page.querySelectorAll('section.entity.' + k).length + ' ' + k + ' sections, the model ' + counts[k]); });
        expect(page.querySelectorAll('h2').length === 4, 'the page has ' + page.querySelectorAll('h2').length + ' parts');
        // the words of the model are in it
        var anchor = ofType(NodeType.ANCHOR).filter(function (a) { return a.mnemonic === 'AC'; })[0];
        expect(page.querySelector('#anchor-AC') && /An actor, a person who performs parts/.test(page.querySelector('#anchor-AC').textContent), 'the description of the anchor is not on the page');
        expect(page.querySelectorAll('#anchor-AC table tbody tr').length === Outline.partsOf(anchor).filter(function (p) { return p.node.type === NodeType.ATTRIBUTE; }).length, 'the anchor does not have a row for each attribute');
        expect(/Gender/.test(page.querySelector('#anchor-AC table').textContent) && /changes over time/.test(page.querySelector('#anchor-AC').textContent) && /never changes/.test(page.querySelector('#anchor-AC').textContent), 'the attributes are not told');
        expect(/Identified by/.test(page.querySelector('#anchor-AC').textContent), 'what identifies the anchor is not told');
        var nexus = page.querySelector('section.nexus');
        expect(nexus && nexus.querySelectorAll('table').length === 2 && /Roles/.test(nexus.textContent) && /chronicle/.test(nexus.textContent), 'the nexus does not have attributes and roles');
        // a tie has its roles, each with what it is and how many, and a description
        page.querySelectorAll('section.tie').forEach(function (tie) {
            expect(tie.querySelectorAll('tbody tr').length >= 2 && tie.querySelector('p') && tie.querySelector('h3').textContent.length > 5, 'a tie does not tell its roles: ' + tie.querySelector('h3').textContent);
            expect(Array.prototype.every.call(tie.querySelectorAll('tbody tr'), function (r) { return /^(one|many)$/.test(r.children[2].textContent) && r.children[1].textContent.trim() && r.children[3].textContent.trim(); }), 'a role of ' + tie.querySelector('h3').textContent + ' lacks what it is, how many or what it is about');
        });
        // a knot says where it is used
        expect(Array.prototype.every.call(page.querySelectorAll('section.knot'), function (k) { return /Used by/.test(k.textContent); }), 'a knot does not say where it is used');
        // every link leads to something on the page
        var links = Array.prototype.slice.call(page.querySelectorAll('a[href^="#"]')), broken = links.filter(function (a) { return !page.getElementById(a.getAttribute('href').slice(1)); });
        expect(links.length > 40 && broken.length === 0, links.length + ' links, and ' + broken.length + ' lead nowhere: ' + broken.slice(0, 3).map(function (a) { return a.getAttribute('href'); }).join(' '));
        // the picture is the model, in light colours although the theme is dark
        Actions.applyTheme('dark'); var dark = Documentation.html(); Actions.applyTheme('light');
        var picture = new DOMParser().parseFromString(dark, 'text/html').querySelector('figure svg');
        expect(picture && picture.getAttribute('viewBox') && picture.querySelector(':scope > rect') && parseInt(picture.querySelector(':scope > rect').getAttribute('fill').replace('#', '').slice(0, 2), 16) > 200, 'the picture in the page is not light');
        expect(Actions.currentTheme === 'light' && !document.body.classList.contains('dark'), 'the theme was left changed');
        record('doc.sections', page.querySelectorAll('section.entity').length);
        // the dialog shows it, and the buttons give it away
        var saved = [], real = Actions.downloadBlob;
        Actions.downloadBlob = function (blob, name) { saved.push({ blob: blob, name: name }); };
        try {
            Actions.generateHTML(); await sleep(300);
            var dialog = document.getElementById('docView'), frame = document.getElementById('docFrame');
            expect(dialog.open && frame.srcdoc.indexOf('<h1>') > 0 && frame.contentDocument.querySelector('h1'), 'the documentation is not shown');
            document.querySelector('#docView [data-action="Documentation.download"]').click(); await sleep(100);
            expect(saved.length === 1 && /\.html$/.test(saved[0].name) && saved[0].blob.type.indexOf('text/html') === 0, 'the file was not downloaded');
            document.querySelector('#docView .close').click();
            expect(!dialog.open, 'the dialog did not close');
        } finally { Actions.downloadBlob = real; }
    });
    test('the whole model can be saved as a PNG that is a picture of it, in both themes', async function () {
        await load(window.__MODELS['example.xml']);
        await sleep(1500);
        async function picture(theme) {
            Actions.applyTheme(theme); await sleep(100);
            var blob = await Actions.pngBlob(1);
            expect(blob.type === 'image/png' && blob.size > 2000, 'the ' + theme + ' picture is ' + blob.type + ', ' + blob.size + ' bytes');
            var image = await new Promise(function (resolve, reject) { var i = new Image(); i.onload = function () { resolve(i); }; i.onerror = reject; i.src = URL.createObjectURL(blob); });
            var canvas = document.createElement('canvas'); canvas.width = image.naturalWidth; canvas.height = image.naturalHeight;
            var ctx = canvas.getContext('2d'); ctx.drawImage(image, 0, 0);
            var data = ctx.getImageData(0, 0, canvas.width, canvas.height).data, corner = Array.prototype.slice.call(data, 0, 4), different = 0, pixels = data.length / 4;
            for (var p = 0; p < data.length; p += 4) if (Math.abs(data[p] - corner[0]) + Math.abs(data[p + 1] - corner[1]) + Math.abs(data[p + 2] - corner[2]) > 40) different++;
            return { w: image.naturalWidth, h: image.naturalHeight, corner: corner, share: different / pixels };
        }
        var light = await picture('light'), dark = await picture('dark');
        Actions.applyTheme('light');
        expect(light.w > 300 && light.h > 200, 'the picture is ' + light.w + ' by ' + light.h);
        expect(light.corner[0] > 200 && dark.corner[0] < 80, 'the background is ' + light.corner.join(',') + ' and ' + dark.corner.join(','));
        expect(light.share > 0.005 && light.share < 0.6 && dark.share > 0.005 && dark.share < 0.6, 'the drawing is ' + (100 * light.share).toFixed(1) + '% and ' + (100 * dark.share).toFixed(1) + '% of the picture');
        // it is all of the model: the picture has the aspect of the model, with room around it
        var box = SVGLayer.nodes.getBBox();
        expect(light.w / light.h > (box.width / box.height) * 0.6 && light.w / light.h < (box.width / box.height) * 1.6, 'the picture is not of the model: ' + (light.w / light.h).toFixed(2) + ' against ' + (box.width / box.height).toFixed(2));
        // and the menu item saves it as a file
        var saved = [], realBlob = Actions.downloadBlob;
        Actions.downloadBlob = function (blob, name) { saved.push(name); };
        try { Actions.savePNG(); for (var w = 0; w < 60 && !saved.length; w++) await sleep(50); } finally { Actions.downloadBlob = realBlob; }
        expect(saved.length === 1 && /\.png$/.test(saved[0]), 'the picture was not saved as a file: ' + saved.join());
        record('png.aspect', (light.w / light.h).toFixed(1));
    });

    test('the SVG file is the whole model, in the colours of the theme and on its background', async function () {
        await load(window.__MODELS['example.xml']);
        await sleep(800);
        function drawing(theme) {
            Actions.applyTheme(theme);
            var d = Actions.modelSVG(), doc = new DOMParser().parseFromString(d.source, 'image/svg+xml'), root = doc.documentElement;
            expect(root.nodeName === 'svg' && !doc.getElementsByTagName('parsererror').length, 'the ' + theme + ' picture is not SVG');
            var rect = Array.prototype.filter.call(root.children, function (e) { return e.nodeName === 'rect'; })[0];
            return { d: d, root: root, background: rect && rect.getAttribute('fill'), text: root.getElementsByTagName('text').length, uses: root.getElementsByTagName('use').length };
        }
        var light = drawing('light'), dark = drawing('dark');
        Actions.applyTheme('light');
        expect(light.background && dark.background && light.background !== dark.background, 'the background is the same in both themes: ' + light.background + ' ' + dark.background);
        expect(/^#?[0-9a-f]{3,8}$/i.test(light.background.trim()) && parseInt(light.background.replace('#', '').slice(0, 2), 16) > 200, 'the light background is ' + light.background);
        expect(parseInt(dark.background.replace('#', '').slice(0, 2), 16) < 80, 'the dark background is ' + dark.background);
        expect(light.text > 20 && light.uses === 0, 'the picture has ' + light.text + ' texts and ' + light.uses + ' uses that point out of it');
        // the names are in the colour of the theme, not the other one
        var fills = function (r) { return Array.prototype.map.call(r.root.getElementsByTagName('text'), function (t) { return (t.getAttribute('style') || '').match(/fill:([^;]+)/); }).filter(Boolean).map(function (m) { return m[1].trim(); }); };
        expect(fills(light).join() !== fills(dark).join(), 'the names have the same colours in both themes');
        var vb = light.root.getAttribute('viewBox').split(' ').map(Number), box = SVGLayer.nodes.getBBox();
        expect(vb[0] < box.x && vb[1] < box.y && vb[0] + vb[2] > box.x + box.width && vb[1] + vb[3] > box.y + box.height, 'the picture does not hold all of the model');
        // the menu item saves it as a file
        var saved = [], real = Actions.downloadBlob;
        Actions.downloadBlob = function (blob, name) { saved.push({ blob: blob, name: name }); };
        try { Actions.saveSVGToDisk(); } finally { Actions.downloadBlob = real; }
        expect(saved.length === 1 && /\.svg$/.test(saved[0].name) && saved[0].blob.type.indexOf('image/svg+xml') === 0, 'the SVG was not saved as a file');
        expect(!document.querySelector('#generate [data-action*="creenshot"]'), 'the SVG screenshot is still in the Generate menu');
    });
    test('models are kept in the browser under names, listed, opened and removed', async function () {
        await load(window.__MODELS['example.xml']);
        var key = ModelStore.key, kept = window.localStorage.getItem(key);
        window.localStorage.removeItem(key);
        try {
            expect(ModelStore.names().length === 0, 'there are models kept already');
            var anchor = ofType(NodeType.ANCHOR)[0], original = anchor.descriptor;
            expect(ModelStore.save('Theatre') && ModelStore.names().join() === 'Theatre', 'the model was not kept');
            anchor.descriptor = 'Performer';
            expect(ModelStore.save('Theatre, changed') && ModelStore.names()[0] === 'Theatre, changed' && ModelStore.names().length === 2, 'a second model was not kept, or is not first');
            expect(!ModelStore.save('   '), 'a model was kept without a name');
            // the dialog
            Actions.openModelStore(); await sleep(100);
            var dialog = document.getElementById('modelStore'), field = document.getElementById('storeName'), button = document.getElementById('storeSave');
            expect(dialog.open && document.querySelectorAll('#storeList li').length === 2, 'the dialog does not list the models');
            expect(document.querySelector('#storeList li strong').textContent === 'Theatre, changed', 'the list is not in the order of the last saved');
            field.value = 'Theatre'; field.dispatchEvent(new Event('input', { bubbles: true }));
            expect(button.textContent === 'Replace', 'the button does not say that it replaces: ' + button.textContent);
            field.value = 'Third'; field.dispatchEvent(new Event('input', { bubbles: true }));
            expect(button.textContent === 'Keep', 'the button does not say that it keeps');
            button.click(); await sleep(50);
            expect(ModelStore.names().length === 3 && /Kept as Third/.test(document.getElementById('storeStatus').textContent), 'the dialog did not keep the model');
            record('store.row', document.querySelector('#storeList li small').textContent.replace(/ · [^·]*$/, ''));
            // opening one makes it the model
            var row = Array.prototype.filter.call(document.querySelectorAll('#storeList li'), function (li) { return li.querySelector('strong').textContent === 'Theatre'; })[0];
            row.querySelector('button[data-store=open]').click(); await sleep(300);
            expect(!dialog.open && ofType(NodeType.ANCHOR)[0].descriptor === original, 'opening did not give the model that was kept: ' + ofType(NodeType.ANCHOR)[0].descriptor);
            expect(/Theatre/.test(document.getElementById('model').textContent), 'the name is not shown as the model');
            // removing asks first
            Actions.openModelStore(); await sleep(100);
            var third = Array.prototype.filter.call(document.querySelectorAll('#storeList li'), function (li) { return li.querySelector('strong').textContent === 'Third'; })[0];
            third.querySelector('button[data-store=delete]').click();
            expect(ModelStore.names().length === 3 && third.querySelector('button[data-store=delete]').textContent === 'Sure?', 'a model was removed without asking');
            third.querySelector('button[data-store=delete]').click();
            expect(ModelStore.names().length === 2 && ModelStore.names().indexOf('Third') < 0, 'the model was not removed');
            // a browser that is full says so, and nothing is lost
            var realSet = Storage.prototype.setItem;
            Storage.prototype.setItem = function () { throw new Error('QuotaExceededError'); };
            try { field.value = 'Too much'; button.click(); } finally { Storage.prototype.setItem = realSet; }
            expect(ModelStore.names().length === 2 && document.getElementById('modelStore').classList.contains('bad') && /full/.test(document.getElementById('storeStatus').textContent), 'a full browser was not told');
            dialog.close();
        } finally {
            if (kept === null) window.localStorage.removeItem(key); else window.localStorage.setItem(key, kept);
        }
    });
    // The page is started again in a frame of a given size, since the size of the window of the test cannot be changed (and a
    // browser window is never narrower than 500 px), and the media queries of a page follow the size of its frame.
    async function framed(width, height) {
        var kept = {}; for (var i = 0; i < window.localStorage.length; i++) { var k = window.localStorage.key(i); kept[k] = window.localStorage.getItem(k); }
        var frame = document.createElement('iframe');
        frame.src = 'index.html';
        frame.style.cssText = 'position:fixed;top:0;left:0;width:' + width + 'px;height:' + height + 'px;border:0;background:#fff;z-index:100000';
        document.body.appendChild(frame);
        for (var w = 0; w < 200 && !(frame.contentWindow && frame.contentWindow.AnchorStarted && frame.contentWindow.Model && frame.contentWindow.Actions); w++) await sleep(50);
        var win = frame.contentWindow;
        expect(win.AnchorStarted, 'the page did not start in a frame of ' + width + ' px');
        win.Actions._applyLoadedModel(new win.DOMParser().parseFromString(window.__MODELS['example.xml'], 'text/xml'), false);
        await sleep(700);
        return {
            win: win, doc: frame.contentDocument,
            close: async function () {
                document.body.removeChild(frame);
                await sleep(100);
                window.localStorage.clear(); Object.keys(kept).forEach(function (key) { window.localStorage.setItem(key, kept[key]); });
            }
        };
    }
    var SIZES = [{ name: 'phone', w: 390, h: 844 }, { name: 'tablet', w: 820, h: 1000 }, { name: 'desktop', w: 1440, h: 900 }];
    test('the page fits a phone, a tablet and a desktop: the bar, the menus, the panel and what is selected are all in view', async function () {
        for (var s = 0; s < SIZES.length; s++) {
            var size = SIZES[s], page = await framed(size.w, size.h), win = page.win, doc = page.doc;
            try {
                var at = size.name + ' (' + size.w + ' px)';
                function inside(el, what) {
                    var r = el.getBoundingClientRect();
                    expect(r.width > 4 && r.height > 4 && r.left >= -0.5 && r.right <= size.w + 0.5 && r.top >= -0.5 && r.bottom <= size.h + 0.5, what + ' is not in view at ' + at + ': ' + [r.left, r.top, r.right, r.bottom].map(Math.round).join(','));
                    return r;
                }
                expect(doc.documentElement.scrollWidth <= size.w && doc.body.scrollWidth <= size.w, 'the page is wider than the window at ' + at);
                ['file', 'actions', 'generate', 'about', 'undo', 'redo', 'playpause', 'themeToggle', 'modelSettingsButton', 'panelButton'].forEach(function (id) { inside(doc.getElementById(id), id); });
                if (size.name !== 'desktop') { /* the zoom buttons stay too */ inside(doc.getElementById('zoomin'), 'zoomin'); }
                var bar = doc.getElementById('header').getBoundingClientRect();
                expect(Math.abs(bar.height - (size.w <= 700 ? 80 : 40)) < 1.5, 'the bar is ' + bar.height + ' px high at ' + at);
                expect((doc.getElementById('search').getBoundingClientRect().width > 0) === (size.w > 900), 'the search is ' + (size.w > 900 ? 'missing' : 'in the way') + ' at ' + at);
                expect((doc.getElementById('miniature').getBoundingClientRect().width > 0) === (size.w > 700), 'the miniature is ' + (size.w > 700 ? 'missing' : 'in the way') + ' at ' + at);
                // a menu opens where it can be seen, and the items are in the window
                win.Menus.open(doc.getElementById('generate'), null); await sleep(100);
                var menu = doc.querySelector('#generate .submenu'); inside(menu, 'the Generate menu');
                win.Menus.closeAll();
                win.Menus.open(doc.getElementById('about'), null); await sleep(100);
                inside(doc.querySelector('#about .submenu'), 'the Help menu'); win.Menus.closeAll();
                // the panel: at the side on a desktop, a sheet at the bottom elsewhere
                win.Outline.setOpen(true, true); await sleep(200);
                var panel = doc.getElementById('panel').getBoundingClientRect();
                if (size.w > 900) expect(Math.abs(panel.right - size.w) < 1 && panel.width > 300 && panel.width < 400 && panel.top >= bar.bottom - 1, 'the panel is not at the side at ' + at);
                else expect(panel.left <= 1 && Math.abs(panel.width - size.w) < 2 && Math.abs(panel.bottom - size.h) < 1 && panel.height < size.h * 0.6 && panel.height > size.h * 0.3, 'the panel is not a sheet at the bottom at ' + at + ': ' + [panel.left, panel.top, panel.width, panel.height].map(Math.round).join(','));
                // what is selected is brought to where it can be seen (not under the bar, nor under the panel)
                var owner = win.Model.components.filter(function (c) { return c.node.type === win.NodeType.ANCHOR && win.Outline.partsOf(c).length > 2; })[0];
                win.Actions.selectNode(win.Outline.idOf(owner)); await sleep(500);
                var shape = owner.view.svg.graphicsElement.getBoundingClientRect(), area = win.Actions.visibleArea(), cx = shape.left + shape.width / 2, cy = shape.top + shape.height / 2;
                expect(cx > area.x && cx < area.x + area.width && cy > area.y && cy < area.y + area.height, 'the selected anchor is at ' + Math.round(cx) + ',' + Math.round(cy) + ', outside the part that can be seen (' + [area.x, area.y, area.width, area.height].map(Math.round).join(',') + ') at ' + at);
                expect(Math.abs(cx - (area.x + area.width / 2)) < 60 && Math.abs(cy - (area.y + area.height / 2)) < 60, 'the selected anchor is not in the middle of what can be seen at ' + at);
                // a dialog is in the window too
                win.Actions.openModelSettings(); await sleep(200); inside(doc.getElementById('modelSettings'), 'the settings dialog'); win.Actions.closeModelSettings();
                record('layout.' + size.name, 'bar ' + Math.round(bar.height) + ', panel ' + (size.w > 900 ? 'side' : 'sheet'));
            } finally { await page.close(); }
        }
    });
    function pointer(type, id, x, y, target, kind) {
        return target.dispatchEvent(new PointerEvent(type, { pointerId: id, pointerType: kind || 'touch', clientX: x, clientY: y, bubbles: true, cancelable: true, isPrimary: id === 1 }));
    }
    function centreOf(c) { var r = c.view.svg.graphicsElement.getBoundingClientRect(); return { x: r.left + r.width / 2, y: r.top + r.height / 2 }; }
    test('a finger taps to select, drags a construct, moves the view and pinches; a mouse is left to the hover and the keys', async function () {
        await load(window.__MODELS['example.xml']);
        Actions.resetZoom(); await sleep(1500);
        var anchor = ofType(NodeType.ANCHOR).filter(function (a) { return a.mnemonic === 'AC'; })[0], other = ofType(NodeType.ANCHOR).filter(function (a) { return a.mnemonic === 'ST'; })[0];
        var shapeOf = function (c) { return c.view.svg.graphicsElement; };
        var box = SVG.viewBox.baseVal;
        EventHandler.clearSelection(); Outline.setOpen(false, true);
        // the graph is for fingers: no scrolling of the page, and a larger circle to hit that a mouse does not have
        expect(getComputedStyle(SVG).touchAction === 'none', 'the graph does not keep the browser from using the fingers');
        expect(ofType(NodeType.ANCHOR).every(function (a) { return shapeOf(a).querySelector('circle.hit'); }) && getComputedStyle(shapeOf(anchor).querySelector('circle.hit')).r === '0px', 'the constructs have no circle for a finger, or it is there for a mouse');
        // a mouse is not a finger
        var c = centreOf(anchor);
        pointer('pointerdown', 1, c.x, c.y, shapeOf(anchor), 'mouse'); pointer('pointerup', 1, c.x, c.y, shapeOf(anchor), 'mouse');
        expect(EventHandler.selectedComponents.length === 0 && Object.keys(Gestures.pointers).length === 0 && !Outline.isOpen, 'a mouse was treated as a finger');
        // a menu that is open closes when the graph is touched
        Menus.open(document.getElementById('generate'), null);
        pointer('pointerdown', 1, 3, 300, SVG); pointer('pointerup', 1, 3, 300, SVG);
        expect(!document.getElementById('generate').classList.contains('open'), 'a touch on the graph left a menu open');
        // a tap selects, and the properties come up in the panel
        pointer('pointerdown', 1, c.x, c.y, shapeOf(anchor)); pointer('pointerup', 1, c.x, c.y, shapeOf(anchor)); await sleep(300);
        expect(EventHandler.selectedComponents.length === 1 && EventHandler.selectedComponents[0] === anchor, 'a tap did not select the construct');
        expect(Outline.isOpen && /^Anchor: /.test(document.querySelector('#panelProperties h3').textContent), 'a tap did not bring up the properties');
        var inView = Actions.visibleArea(), cc = centreOf(anchor);
        expect(cc.x >= inView.x && cc.x <= inView.x + inView.width && cc.y >= inView.y && cc.y <= inView.y + inView.height, 'the selected construct is under the panel');
        // a tap on it again lets go, and so does a tap on the background, and a tap on another selects that instead
        c = centreOf(anchor);
        pointer('pointerdown', 1, c.x, c.y, shapeOf(anchor)); pointer('pointerup', 1, c.x, c.y, shapeOf(anchor));
        expect(EventHandler.selectedComponents.length === 0, 'a second tap did not let go');
        var o = centreOf(other);
        pointer('pointerdown', 1, o.x, o.y, shapeOf(other)); pointer('pointerup', 1, o.x, o.y, shapeOf(other));
        c = centreOf(anchor); pointer('pointerdown', 1, c.x, c.y, shapeOf(anchor)); pointer('pointerup', 1, c.x, c.y, shapeOf(anchor));
        expect(EventHandler.selectedComponents.length === 1 && EventHandler.selectedComponents[0] === anchor, 'a tap on another did not make it the only one selected');
        pointer('pointerdown', 1, 3, 300, SVG); pointer('pointerup', 1, 3, 300, SVG);
        expect(EventHandler.selectedComponents.length === 0, 'a tap on the background did not let go');
        // one finger on the background moves the view
        var x0 = box.x, y0 = box.y, k = box.width / window.innerWidth;
        pointer('pointerdown', 1, 400, 500, SVG); pointer('pointermove', 1, 430, 520, SVG); pointer('pointermove', 1, 460, 540, SVG); pointer('pointerup', 1, 460, 540, SVG);
        expect(Math.abs((x0 - box.x) - 60 * k) < 0.5 && Math.abs((y0 - box.y) - 40 * k) < 0.5, 'the view moved ' + (x0 - box.x).toFixed(1) + ',' + (y0 - box.y).toFixed(1) + ' for a finger that moved 60,40');
        expect(Gestures.mode === null && EventHandler.selectedComponents.length === 0, 'a move was taken for a tap, or the mode is left');
        // two fingers zoom about the middle between them
        var w0 = box.width, mid = EventHandler.screenToSVG(650, 400);
        pointer('pointerdown', 1, 600, 400, SVG); pointer('pointerdown', 2, 700, 400, SVG);
        pointer('pointermove', 2, 800, 400, SVG); pointer('pointermove', 1, 500, 400, SVG);
        expect(Math.abs(box.width / w0 - 1 / 3) < 0.02, 'the view is ' + (box.width / w0).toFixed(2) + ' of what it was after the fingers went from 100 to 300 apart');
        var after = EventHandler.screenToSVG(650, 400);
        expect(Math.abs(after.x - mid.x) < 2 && Math.abs(after.y - mid.y) < 2, 'the point between the fingers moved: ' + mid.x.toFixed(0) + ',' + mid.y.toFixed(0) + ' to ' + after.x.toFixed(0) + ',' + after.y.toFixed(0));
        pointer('pointerup', 2, 800, 400, SVG); pointer('pointermove', 1, 520, 420, SVG); pointer('pointerup', 1, 520, 420, SVG);
        expect(EventHandler.selectedComponents.length === 0 && Gestures.mode === null, 'lifting the fingers after a pinch selected something');
        Actions.resetZoom(); await sleep(1200);
        // a finger drags a construct, and leaves it there, fixed
        c = centreOf(anchor);
        var before = { x: anchor.node.xPosition, y: anchor.node.yPosition };
        pointer('pointerdown', 1, c.x, c.y, shapeOf(anchor)); pointer('pointermove', 1, c.x + 30, c.y + 10, shapeOf(anchor)); pointer('pointermove', 1, c.x + 120, c.y + 60, shapeOf(anchor));
        var want = EventHandler.screenToSVG(c.x + 120, c.y + 60);
        expect(Math.abs(anchor.node.xPosition - want.x) < 1 && Math.abs(anchor.node.yPosition - want.y) < 1 && anchor.node.unstoppable, 'the construct is not under the finger: ' + anchor.node.xPosition.toFixed(0) + ',' + anchor.node.yPosition.toFixed(0) + ' for ' + want.x.toFixed(0) + ',' + want.y.toFixed(0));
        pointer('pointerup', 1, c.x + 120, c.y + 60, shapeOf(anchor)); await sleep(500);
        expect(anchor.getFixed() && !anchor.node.unstoppable && Math.abs(anchor.node.xPosition - want.x) < 1, 'the construct is not left where it was put, fixed');
        expect(EventHandler.selectedComponents.length === 0, 'a drag selected the construct');
        anchor.setFixed(false);
        record('gestures.ok', 'tap drag pan pinch');
    });

    test('a finger held on a construct adds it to the selection and opens its context menu, which stays in the window', async function () {
        await load(window.__MODELS['example.xml']);
        Actions.resetZoom(); await sleep(1500);
        var anchors = ofType(NodeType.ANCHOR), first = anchors[0], second = anchors[1], shapeOf = function (c) { return c.view.svg.graphicsElement; };
        EventHandler.clearSelection(); Outline.setOpen(false, true);
        var c = centreOf(first);
        pointer('pointerdown', 1, c.x, c.y, shapeOf(first));
        await sleep(300);
        expect(!document.getElementById('contextMenu'), 'the menu opened before the finger was held');
        await sleep(450);
        expect(EventHandler.selectedComponents.indexOf(first) >= 0 && document.getElementById('contextMenu') && first.contextMenu && !first.contextMenu.collapsed, 'holding did not select the construct and open its menu');
        pointer('pointerup', 1, c.x, c.y, shapeOf(first));
        expect(EventHandler.selectedComponents.length === 1, 'lifting after holding changed the selection');
        var box = document.getElementById('contextMenu').getBoundingClientRect();
        expect(box.left >= 0 && box.top >= 0 && box.right <= window.innerWidth + 0.5 && box.bottom <= window.innerHeight + 0.5, 'the menu is not in the window: ' + [box.left, box.top, box.right, box.bottom].map(Math.round).join(','));
        // a touch beside the menu closes it
        document.getElementById('modalBackground').dispatchEvent(new MouseEvent('click', { bubbles: true })); await sleep(100);
        expect(!document.getElementById('contextMenu') || first.contextMenu.collapsed, 'a touch beside the menu did not close it');
        first.hideContextMenu();
        // a second construct held is added: two are selected
        var d = centreOf(second);
        pointer('pointerdown', 1, d.x, d.y, shapeOf(second)); await sleep(700); pointer('pointerup', 1, d.x, d.y, shapeOf(second));
        expect(EventHandler.selectedComponents.length === 2, 'a second construct that was held was not added to the selection: ' + EventHandler.selectedComponents.length);
        second.hideContextMenu(); EventHandler.clearSelection();
        // a construct at the edge of the window gets a menu that is in the window
        second.node.xPosition = EventHandler.screenToSVG(window.innerWidth - 5, 300).x; second.node.yPosition = EventHandler.screenToSVG(0, window.innerHeight - 5).y; second.node.start();
        second.view.draw(second.view.svg);
        second.showContextMenu(second, [], null); second.contextMenu.toggle(); await sleep(100);
        var edge = document.getElementById('contextMenu').getBoundingClientRect();
        expect(edge.right <= window.innerWidth + 0.5 && edge.bottom <= window.innerHeight + 0.5 && edge.left >= 0, 'the menu of a construct at the corner is out of the window: ' + [edge.left, edge.top, edge.right, edge.bottom].map(Math.round).join(','));
        second.hideContextMenu(); EventHandler.clearSelection();
    });

    test('a finger on the miniature puts the middle of the view where it is, and follows', async function () {
        await load(window.__MODELS['example.xml']);
        Actions.resetZoom(); await sleep(1500);
        var mini = document.getElementById('minigraph'), r = mini.getBoundingClientRect(), box = SVG.viewBox.baseVal;
        var before = { x: box.x, y: box.y };
        pointer('pointerdown', 1, r.left + r.width * 0.2, r.top + r.height * 0.2, mini);
        var first = { x: box.x, y: box.y };
        pointer('pointermove', 1, r.left + r.width * 0.8, r.top + r.height * 0.8, mini);
        var second = { x: box.x, y: box.y };
        pointer('pointerup', 1, r.left + r.width * 0.8, r.top + r.height * 0.8, mini);
        expect(Math.abs(first.x - before.x) + Math.abs(first.y - before.y) > 1, 'a touch on the miniature did not move the view');
        expect(second.x > first.x && second.y > first.y, 'the view did not follow the finger on the miniature');
        expect(Gestures.mode === null && Object.keys(Gestures.pointers).length === 0, 'the finger is still down');
        Actions.resetZoom();
    });
    test('a model goes to an agent without its positions, and what comes back replaces it, with what was there in its place', async function () {
        await load(window.__MODELS['example.xml']);
        await sleep(300);
        var actor = ofType(NodeType.ANCHOR).filter(function (a) { return a.mnemonic === 'AC'; })[0];
        actor.node.xPosition = 123.45; actor.node.yPosition = 234.56;
        var written = [];
        Object.defineProperty(navigator, 'clipboard', { value: { writeText: function (s) { written.push(s); return Promise.resolve(); } }, configurable: true });
        try { Actions.copyForAgent(); await sleep(300); } finally { delete navigator.clipboard; }
        expect(written.length === 1, 'nothing was copied');
        var text = written[0];
        expect(/anchor-modeling-skill/.test(text) && /What I want changed/.test(text) && /```xml/.test(text), 'the text does not say what an agent needs to know');
        expect(!/<layout\s/.test(text), 'the positions are in the text');
        expect(document.getElementById('toast').classList.contains('show') && /Copied the model/.test(document.getElementById('toast').textContent), 'nothing said that it was copied');
        var extracted = new DOMParser().parseFromString(AgentHandoff.extract(text), 'application/xml');
        expect(canonical(extracted.documentElement) === xmlOf(), 'the model in the text is not the model: ' + difference(canonical(extracted.documentElement), xmlOf()));
        record('agent.lines', text.split('\n').length);
        // the answer: the model with an anchor more, in the middle of other words
        var answer = 'Here you go! I added a Zebra anchor with a Name.\n\n' + text.replace('</schema>', '    <anchor mnemonic="ZB" descriptor="Zebra" identity="int"><metadata capsule="dbo" generator="true"/><attribute mnemonic="ZBNAM" descriptor="Name" dataRange="varchar(42)"><metadata capsule="dbo"/></attribute></anchor>\n</schema>') + '\nTell me if you want more.';
        answer = answer.replace('mnemonic="ZBNAM"', 'mnemonic="NAM"');
        var version = Model.version;
        Actions.openAgentPaste(); await sleep(100);
        var dialog = document.getElementById('agentPaste'), box = document.getElementById('agentText'), replace = document.getElementById('agentReplace');
        expect(dialog.open && replace.disabled, 'the dialog did not open with nothing to replace with');
        box.value = 'not a model'; box.dispatchEvent(new Event('input', { bubbles: true })); await sleep(600);
        expect(replace.disabled && document.querySelectorAll('#agentProblems li').length >= 1, 'text that is not a model can replace the model');
        box.value = answer; box.dispatchEvent(new Event('input', { bubbles: true })); await sleep(600);
        expect(!replace.disabled && /5 anchors/.test(document.getElementById('agentStatus').textContent), 'a model that is right cannot be pasted: ' + document.getElementById('agentStatus').textContent);
        record('agent.status', document.getElementById('agentStatus').textContent);
        var placed = ofType(NodeType.ANCHOR).filter(function (a) { return a.mnemonic === 'AC'; })[0].node, wasX = placed.xPosition, wasY = placed.yPosition; // the layout keeps moving things until they rest
        replace.click();
        // at once, before the layout has moved anything: what was there is where it was, what is new has a place
        var actor2 = ofType(NodeType.ANCHOR).filter(function (a) { return a.mnemonic === 'AC'; })[0], zebra = ofType(NodeType.ANCHOR).filter(function (a) { return a.mnemonic === 'ZB'; })[0];
        expect(zebra, 'the new anchor is not in the model');
        expect(Math.abs(actor2.node.xPosition - wasX) < 0.01 && Math.abs(actor2.node.yPosition - wasY) < 0.01, 'what was there did not keep its place: ' + actor2.node.xPosition + ',' + actor2.node.yPosition);
        expect(isFinite(zebra.node.xPosition) && isFinite(zebra.node.yPosition), 'the new anchor has no place');
        expect(!dialog.open && Model.version > version, 'the dialog is open, or the replacement is not a step');
        expect(/replaced/.test(document.getElementById('toast').textContent), 'nothing said that the model was replaced');
        // the new anchor's attribute is on a ring around it
        var attribute = Outline.partsOf(zebra)[0];
        expect(attribute && Math.abs(Math.hypot(attribute.node.xPosition - zebra.node.xPosition, attribute.node.yPosition - zebra.node.yPosition) - 3 * LayoutEngine.normalDistance) < 1, 'the attribute of the new anchor is not around it');
        // and undo brings the old model back
        ControlButtons.undo(); await sleep(400);
        expect(ofType(NodeType.ANCHOR).filter(function (a) { return a.mnemonic === 'ZB'; }).length === 0, 'undo did not take the new anchor away');
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

    test('SQL and XML are generated (the documentation has its own test)', async function () {
        await load(window.__MODELS['example.xml']);
        var sql = await Actions.sql();
        expect(/CREATE TABLE/i.test(sql) && sql.length > 100000, 'the SQL has ' + sql.length + ' characters');
        record('sql.tables.sqlserver.uni', (sql.match(/CREATE TABLE/g) || []).length);
        Actions.generateXML();
        await sleep(500);
        expect(document.getElementById('codePopover'), 'no XML popover');
        closeOverlays();
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
        // the number of a construct depends on how many were made before it, so it is not recorded
        function recorder(name) { return function () { calls.push(name + '(' + (name === 'Actions.selectNode' ? '<id>' : Array.prototype.map.call(arguments, show).join(', ')) + ')'); }; }
        // a few menu items call a function of Actions that only makes the calls the markup used to make itself (see Wiring.js);
        // it is left as it is, so that what is recorded for the item is those calls, as it was
        var wrappers = ['chooseModelFile', 'saveSettingsInBrowser', 'saveModelToDisk', 'saveSVGToDisk', 'mailModel', 'resetView', 'openTutorials', 'openAbout'];
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
