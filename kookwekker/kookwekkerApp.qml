import QtQuick 1.1
import qb.components 1.0
import qb.base 1.0

App {
	id: kookwekkerApp

	property url tileUrl: "KookwekkerTile.qml"
	property url screenUrl: "KookwekkerScreen.qml"
	property url alarmScreenUrl: "KookwekkerAlarmScreen.qml"
	property url settingsScreenUrl: "KookwekkerSettingsScreen.qml"
	property url trayUrl: "KookwekkerSystray.qml"
	property url thumbnailIcon: "drawables/kookwekker.png"

	property KookwekkerScreen kookwekkerScreen
	property KookwekkerAlarmScreen kookwekkerAlarmScreen
	property KookwekkerSettingsScreen kookwekkerSettingsScreen
	property KookwekkerSystray kookwekkerTray

	property alias timers: timersModel
	property alias presets: presetsModel
	property int maxTimers: 4
	property int maxPresets: 6
	property int maxNames: 16
	property string settingsPath: "file:///mnt/data/tsc/kookwekker_userSettings.json"

	// Kleurenpalet voor timers en snelkeuzes
	property variant palette: ["#4a90a4", "#5cb85c", "#2fa59b", "#d6639a", "#8e6bbf", "#555555"]

	// Namen om uit te kiezen (uitbreidbaar in de instellingen)
	property variant names: ["Timer", "Pasta", "Ei", "Thee", "Rijst", "Oven", "Wasmachine", "Aardappels", "Pizza"]

	// Home Assistant (webhook)
	property bool haEnabled: false
	property string haUrl: ""
	property string haWebhook: "kookwekker"
	property string haStatus: ""

	// Samenvatting voor de tile, tray en het alarmscherm
	property string summaryTime: "Start"
	property string summaryLabel: "Kookwekker"
	property string summaryColor: "#4a90a4"
	property string doneText: ""
	property bool anyDone: false
	property int activeCount: 0
	// Korte tekst voor de tray: "5m", "42s" of "!" bij klaar
	property string trayText: ""

	property bool ringing: false
	property variant audioObj: null
	property bool soundBroken: false

	ListModel {
		id: timersModel
	}

	ListModel {
		id: presetsModel
	}

	Timer {
		id: tickTimer
		interval: 1000
		repeat: true
		running: timersModel.count > 0
		onTriggered: kookwekkerApp.tick()
	}

	// Herhaalt het geluid zolang het alarm afgaat
	Timer {
		id: soundRepeat
		interval: 2500
		repeat: true
		running: false
		onTriggered: {
			try {
				kookwekkerApp.audioObj.stop();
				kookwekkerApp.audioObj.play();
			} catch (e) {}
		}
	}

	// Geluid stopt vanzelf na 90 seconden
	Timer {
		id: soundLimit
		interval: 90000
		repeat: false
		running: false
		onTriggered: kookwekkerApp.stopSound()
	}

	function init() {
		registry.registerWidget("tile", tileUrl, this, null, {
			thumbLabel: "Kookwekker",
			thumbIcon: thumbnailIcon,
			thumbCategory: "general",
			thumbWeight: 30,
			baseTileWeight: 10,
			baseTileSolarWeight: 10,
			thumbIconVAlignment: "center"
		});
		registry.registerWidget("screen", screenUrl, this, "kookwekkerScreen");
		registry.registerWidget("screen", alarmScreenUrl, this, "kookwekkerAlarmScreen");
		registry.registerWidget("screen", settingsScreenUrl, this, "kookwekkerSettingsScreen");
		registry.registerWidget("systrayIcon", trayUrl, this, "kookwekkerTray");
		defaultPresets();
		loadSettings();
	}

	// ------------------------------------------------------------------
	// Hulpfuncties
	// ------------------------------------------------------------------

	function nowSec() {
		return Math.floor(new Date().getTime() / 1000);
	}

	function pad(n) {
		return (n < 10 ? "0" : "") + n;
	}

	function fmt(sec) {
		var h = Math.floor(sec / 3600);
		var m = Math.floor((sec % 3600) / 60);
		var s = sec % 60;
		if (h > 0)
			return h + ":" + pad(m) + ":" + pad(s);
		return pad(m) + ":" + pad(s);
	}

	function trim(s) {
		return ("" + s).replace(/^\s+|\s+$/g, "");
	}

	function colorIndex(c) {
		for (var i = 0; i < palette.length; i++) {
			if (palette[i] === c)
				return i;
		}
		return 0;
	}

	function nextColor(c) {
		return palette[(colorIndex(c) + 1) % palette.length];
	}

	function nameIndex(n) {
		for (var i = 0; i < names.length; i++) {
			if (names[i] === n)
				return i;
		}
		return -1;
	}

	// ------------------------------------------------------------------
	// Timers
	// ------------------------------------------------------------------

	function addTimer(label, seconds, col) {
		if (timersModel.count >= maxTimers)
			return false;
		if (col === undefined || col === "")
			col = palette[0];
		timersModel.append({
			"label": label,
			"col": col,
			"endSec": nowSec() + seconds,
			"totalSec": seconds,
			"remaining": seconds,
			"done": false
		});
		saveSettings();
		updateSummary();
		haSend("started", label, col, seconds, false);
		return true;
	}

	function removeTimer(index) {
		if (index < 0 || index >= timersModel.count)
			return;
		var t = timersModel.get(index);
		var label = t.label;
		var col = t.col;
		var total = t.totalSec;
		var wasDone = t.done;
		timersModel.remove(index);
		saveSettings();
		updateSummary();
		haSend(wasDone ? "dismissed" : "cancelled", label, col, total, false);
	}

	function extendTimer(index, seconds) {
		if (index < 0 || index >= timersModel.count)
			return;
		var t = timersModel.get(index);
		var now = nowSec();
		if (t.done || t.endSec <= now) {
			timersModel.setProperty(index, "endSec", now + seconds);
			timersModel.setProperty(index, "totalSec", seconds);
			timersModel.setProperty(index, "remaining", seconds);
		} else {
			timersModel.setProperty(index, "endSec", t.endSec + seconds);
			timersModel.setProperty(index, "totalSec", t.totalSec + seconds);
			timersModel.setProperty(index, "remaining", t.endSec + seconds - now);
		}
		timersModel.setProperty(index, "done", false);
		saveSettings();
		updateSummary();
		haSend("extended", t.label, t.col, seconds, false);
	}

	function dismissDone() {
		var dismissed = [];
		for (var i = timersModel.count - 1; i >= 0; i--) {
			var t = timersModel.get(i);
			if (t.done) {
				dismissed.push({label: t.label, col: t.col, total: t.totalSec});
				timersModel.remove(i);
			}
		}
		saveSettings();
		updateSummary();
		for (var j = 0; j < dismissed.length; j++)
			haSend("dismissed", dismissed[j].label, dismissed[j].col, dismissed[j].total, false);
	}

	function tick() {
		var now = nowSec();
		var finished = [];
		for (var i = 0; i < timersModel.count; i++) {
			var t = timersModel.get(i);
			var rem = t.endSec - now;
			if (rem < 0)
				rem = 0;
			if (t.remaining !== rem)
				timersModel.setProperty(i, "remaining", rem);
			if (rem === 0 && !t.done) {
				timersModel.setProperty(i, "done", true);
				finished.push({label: t.label, col: t.col, total: t.totalSec});
			}
		}
		updateSummary();
		if (finished.length > 0) {
			startAlarm();
			for (var j = 0; j < finished.length; j++)
				haSend("finished", finished[j].label, finished[j].col, finished[j].total, false);
		}
	}

	function updateSummary() {
		var best = -1;
		var bestRem = 0;
		var done = 0;
		var doneNames = [];
		for (var i = 0; i < timersModel.count; i++) {
			var t = timersModel.get(i);
			if (t.done) {
				done++;
				doneNames.push(t.label);
			} else if (best < 0 || t.remaining < bestRem) {
				best = i;
				bestRem = t.remaining;
			}
		}
		anyDone = done > 0;
		doneText = doneNames.join(", ");
		activeCount = timersModel.count - done;
		if (done > 0) {
			summaryTime = "Klaar!";
			summaryLabel = doneText;
			summaryColor = "#d9534f";
			trayText = "!";
		} else if (best >= 0) {
			var b = timersModel.get(best);
			summaryTime = fmt(bestRem);
			summaryLabel = b.label + (activeCount > 1 ? " (+" + (activeCount - 1) + ")" : "");
			summaryColor = b.col;
			trayText = bestRem >= 60 ? Math.ceil(bestRem / 60) + "m" : bestRem + "s";
		} else {
			summaryTime = "Start";
			summaryLabel = "Kookwekker";
			summaryColor = palette[0];
			trayText = "";
		}
	}

	// ------------------------------------------------------------------
	// Alarm en geluid
	// ------------------------------------------------------------------

	function startAlarm() {
		if (ringing)
			return;
		ringing = true;
		try {
			if (typeof screenStateController !== "undefined")
				screenStateController.wakeup();
		} catch (e) {}
		stage.openFullscreen(alarmScreenUrl);
	}

	// Wordt aangeroepen als het alarmscherm sluit (Stop of wegnavigeren)
	function alarmClosed() {
		ringing = false;
		stopSound();
	}

	function startSound() {
		if (soundBroken)
			return;
		try {
			if (audioObj === null) {
				audioObj = Qt.createQmlObject(
					'import QtQuick 1.1\nimport QtMultimediaKit 1.1\nAudio { source: "' + Qt.resolvedUrl("sounds/alarm.wav") + '" }',
					kookwekkerApp, "kookwekkerAudio");
			}
			audioObj.play();
			soundRepeat.restart();
			soundLimit.restart();
		} catch (e) {
			// Geen audio-module beschikbaar: alleen visueel alarm
			soundBroken = true;
		}
	}

	function stopSound() {
		soundRepeat.stop();
		soundLimit.stop();
		try {
			if (audioObj !== null)
				audioObj.stop();
		} catch (e) {}
	}

	// ------------------------------------------------------------------
	// Snelkeuzes beheren
	// ------------------------------------------------------------------

	function defaultPresets() {
		presetsModel.clear();
		var d = [
			{label: "Ei zacht", minutes: 6, col: palette[3]},
			{label: "Ei hard", minutes: 9, col: palette[4]},
			{label: "Thee", minutes: 3, col: palette[1]},
			{label: "Pasta", minutes: 10, col: palette[0]},
			{label: "Rijst", minutes: 12, col: palette[2]},
			{label: "Oven", minutes: 20, col: palette[5]}
		];
		for (var i = 0; i < d.length; i++)
			presetsModel.append(d[i]);
	}

	function cyclePresetName(i) {
		if (i < 0 || i >= presetsModel.count || names.length === 0)
			return;
		var idx = (nameIndex(presetsModel.get(i).label) + 1) % names.length;
		presetsModel.setProperty(i, "label", names[idx]);
		saveSettings();
	}

	function cyclePresetColor(i) {
		if (i < 0 || i >= presetsModel.count)
			return;
		presetsModel.setProperty(i, "col", nextColor(presetsModel.get(i).col));
		saveSettings();
	}

	function changePresetMinutes(i, delta) {
		if (i < 0 || i >= presetsModel.count)
			return;
		var m = presetsModel.get(i).minutes + delta;
		if (m < 1)
			m = 1;
		if (m > 180)
			m = 180;
		presetsModel.setProperty(i, "minutes", m);
		saveSettings();
	}

	function removePreset(i) {
		if (i < 0 || i >= presetsModel.count)
			return;
		presetsModel.remove(i);
		saveSettings();
	}

	function addPreset() {
		if (presetsModel.count >= maxPresets)
			return;
		presetsModel.append({
			label: "Timer",
			minutes: 5,
			col: palette[presetsModel.count % palette.length]
		});
		saveSettings();
	}

	function addName(text) {
		var n = trim(text);
		if (n === "" || names.length >= maxNames || nameIndex(n) >= 0)
			return;
		if (n.length > 20)
			n = n.substring(0, 20);
		names = names.concat([n]);
		saveSettings();
	}

	// ------------------------------------------------------------------
	// Home Assistant
	// ------------------------------------------------------------------

	function setHaUrl(text) {
		haUrl = trim(text);
		saveSettings();
	}

	function setHaWebhook(text) {
		haWebhook = trim(text);
		saveSettings();
	}

	function toggleHa() {
		haEnabled = !haEnabled;
		saveSettings();
	}

	function testHa() {
		haSend("test", "Test", palette[0], 0, true);
	}

	function haBase() {
		var u = trim(haUrl).replace(/\/+$/, "");
		if (u === "")
			return "";
		if (u.indexOf("http://") !== 0 && u.indexOf("https://") !== 0)
			u = "http://" + u;
		return u;
	}

	// Stuurt een JSON-bericht naar de webhook: {event, label, color, seconds, active}
	// force=true verstuurt ook als de koppeling uit staat (testknop)
	function haSend(eventName, label, col, seconds, force) {
		if (!haEnabled && !force)
			return;
		var base = haBase();
		var id = trim(haWebhook);
		if (base === "" || id === "") {
			haStatus = "Vul adres en webhook-id in";
			return;
		}
		try {
			var doc = new XMLHttpRequest();
			doc.onreadystatechange = function() {
				if (doc.readyState === 4) {
					if (doc.status >= 200 && doc.status < 300)
						haStatus = "Laatste bericht (" + eventName + "): OK";
					else
						haStatus = "Laatste bericht (" + eventName + "): fout " + doc.status;
				}
			};
			doc.open("POST", base + "/api/webhook/" + id);
			doc.setRequestHeader("Content-Type", "application/json");
			doc.send(JSON.stringify({
				event: eventName,
				label: label,
				color: col,
				seconds: seconds,
				active: activeCount
			}));
		} catch (e) {
			haStatus = "Versturen mislukt";
		}
	}

	// ------------------------------------------------------------------
	// Opslag
	// ------------------------------------------------------------------

	function saveSettings() {
		var tArr = [];
		for (var i = 0; i < timersModel.count; i++) {
			var t = timersModel.get(i);
			tArr.push({label: t.label, col: t.col, endSec: t.endSec, totalSec: t.totalSec});
		}
		var pArr = [];
		for (var j = 0; j < presetsModel.count; j++) {
			var p = presetsModel.get(j);
			pArr.push({label: p.label, minutes: p.minutes, col: p.col});
		}
		var nArr = [];
		for (var k = 0; k < names.length; k++)
			nArr.push(names[k]);
		try {
			var doc = new XMLHttpRequest();
			doc.open("PUT", settingsPath);
			doc.send(JSON.stringify({
				timers: tArr,
				presets: pArr,
				names: nArr,
				haEnabled: haEnabled,
				haUrl: haUrl,
				haWebhook: haWebhook
			}));
		} catch (e) {}
	}

	function loadSettings() {
		try {
			var doc = new XMLHttpRequest();
			doc.onreadystatechange = function() {
				if (doc.readyState === 4 && doc.responseText) {
					try {
						applySettings(JSON.parse(doc.responseText));
					} catch (e) {}
					updateSummary();
				}
			};
			doc.open("GET", settingsPath, true);
			doc.send();
		} catch (e) {}
	}

	function applySettings(data) {
		var now = nowSec();
		var i;
		if (data.names && data.names.length > 0)
			names = data.names;
		if (data.presets && data.presets.length > 0) {
			presetsModel.clear();
			for (i = 0; i < data.presets.length && i < maxPresets; i++) {
				var p = data.presets[i];
				presetsModel.append({
					label: p.label,
					minutes: p.minutes,
					col: p.col ? p.col : palette[0]
				});
			}
		}
		if (data.haEnabled !== undefined)
			haEnabled = data.haEnabled;
		if (data.haUrl !== undefined)
			haUrl = data.haUrl;
		if (data.haWebhook !== undefined)
			haWebhook = data.haWebhook;
		if (data.timers) {
			for (i = 0; i < data.timers.length && timersModel.count < maxTimers; i++) {
				var t = data.timers[i];
				if (t.endSec > now) {
					timersModel.append({
						"label": t.label,
						"col": t.col ? t.col : palette[0],
						"endSec": t.endSec,
						"totalSec": t.totalSec,
						"remaining": t.endSec - now,
						"done": false
					});
				}
			}
		}
	}
}
