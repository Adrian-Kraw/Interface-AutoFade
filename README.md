<a id="english"></a>

# Interface AutoFade
[English](#english) · [Deutsch](#deutsch)

Fades your interface depending on where you are. One addon for WoW Retail and WoW Forever.

---

## What you can do

Interface AutoFade hides the parts of your interface that you do not need right now. You stand still in a city or in the open world, and the screen is clear. You start to move, and the interface fades in. You enter combat, and everything is visible.

Every place has its own mode with its own settings. You switch each mode on or off separately. All modes are off by default.

### Modes

| Mode | Applies | Client |
|------|---------|--------|
| Chill Mode in Rest Areas | In rest areas such as cities and inns, outside of instances | Retail and Forever |
| Open World | Outside of rest areas and outside of instances | Retail and Forever |
| Housing | In housing neighborhoods and inside houses | Retail only |

In dungeons, raids, battlegrounds and other instances the Chill and Open World modes do not apply, so the interface stays as it is.

### How a mode works

* **Standing still**: The faded elements are hidden.
* **Moving**: After the set time they fade in to the set transparency.
* **Standing still again**: After the set time they fade out again.
* **Combat**: Everything is fully visible. After combat the countdown to fade out starts again.
* **New chat message**: The chat shows for a moment, see Chat below.

### Settings of every mode

* **Mode on or off**: The checkbox in the header of the mode.
* **Show on Mouse Hover**: Shows a faded element while the mouse is over it. Details below.
* **Transparency**: How visible the elements are while you move, from 0 to 100 percent.
* **Move Duration until Fade In**: How long you move before the interface fades in, from 0 seconds (instantly) to 10 seconds.
* **Fade Out After**: How long you stand still before the interface fades out, from 5 to 180 seconds in steps of 5.
* **Chat Visible For**: How long the chat stays visible after a new message, after you close the chat input and after the mouse left the chat, from 5 to 180 seconds in steps of 5.
* **Always visible at 100%**: Elements that never fade in this mode. You can keep any of these visible: Chat, Minimap, Quest / Objectives, Micro Menu, Bags, Action Bars, Unit Frames, Buffs / Debuffs, Reputation Bar and Damage Meter. In the Housing mode of Retail there is also the Housing Build Menu.

### What fades

* Action bars, including the stance bar and the pet bar
* Micro menu
* Bags
* Minimap, including markers such as the player arrow, and the expansion button
* Buffs and debuffs
* Player, target, focus and party frames
* Quest tracker
* Reputation and experience bar
* Damage meter
* Quick Join button
* Chat
* Housing build menu at the top of the screen (Retail, Housing mode)

### Chat

* All chat tabs fade, also whisper tabs and the tab of a Battle.net conversation.
* A tab that you drag out of the chat window fades together with its window, the tab name included.
* A new message shows the chat for the set time. This covers Say, Yell, Emote, whispers, Battle.net whispers, Party, Raid, Guild, Officer, channels and instance chat.
* While the chat input is open, the chat stays visible. Pressing Enter is enough, you do not have to type anything. After you close the input, the chat stays visible for the set time.
* With Show on Mouse Hover the chat shows while the mouse is over it. After the mouse left, it stays visible for the set time.

### Show on Mouse Hover

* The option is the first entry in every mode. It is off by default.
* If it is on and you point the mouse at a faded element, only this element is shown. The rest stays faded.
* It works for every element in the list above, for example the action bars when you look for a spell, the quest tracker or the chat.
* Hover uses the area of each element, so an empty part of the quest tracker area reacts as well.
* The minimap button sits on the minimap and fades with it. Point the mouse at the minimap to show it.

### Settings window and minimap button

* The settings window opens with `/autofade` or with a click on the minimap button.
* Drag the minimap button to move it along the minimap border. The position is saved.
* The window and the texts are available in English and German.

---

## Installation

* **Download**: Interface AutoFade is available on CurseForge: CURSEFORGE_LINK
* One download for both clients. The addon detects by itself whether it runs in Retail or in Forever.
* Copy the folder `InterfaceAutoFade` to `World of Warcraft\_retail_\Interface\AddOns` for Retail or to `World of Warcraft\_forever_\Interface\AddOns` for Forever.
* If the addon does not show up in Forever after an install through an addon manager, copy the folder to the Forever path by hand.
* The settings are saved separately for Retail and for Forever.

## Compatibility

* Use only one addon that fades the interface at a time. Two of them change the same frames and work against each other.
* Aklime Mod Tools contains the same Interface Fading. If you use both, switch off the Interface Fading in one of them.

## Commands

| Command | Function |
|---------|----------|
| `/autofade` | Open / close settings window |



---
---

<a id="deutsch"></a>

# Interface AutoFade
[English](#english) · [Deutsch](#deutsch)

Blendet dein Interface je nach Aufenthaltsort aus. Ein Addon für WoW Retail und WoW Forever.

---

## Was du damit machen kannst

Interface AutoFade versteckt die Teile deines Interface, die du gerade nicht brauchst. Du stehst still in einer Stadt oder in der offenen Welt, und der Bildschirm ist frei. Du läufst los, und das Interface blendet ein. Du gehst in den Kampf, und alles ist sichtbar.

Jeder Ort hat einen eigenen Modus mit eigenen Einstellungen. Du schaltest jeden Modus einzeln an oder aus. Alle Modi sind standardmäßig aus.

### Modi

| Modus | Gilt | Client |
|-------|------|--------|
| Chillmodus in Ruhezonen | In Ruhezonen wie Städten und Gasthäusern, außerhalb von Instanzen | Retail und Forever |
| Offene Welt | Außerhalb von Ruhezonen und außerhalb von Instanzen | Retail und Forever |
| Housing | In Housing-Nachbarschaften und in Häusern | Nur Retail |

In Dungeons, Raids, Schlachtfeldern und anderen Instanzen gelten Chillmodus und Offene Welt nicht, das Interface bleibt dort, wie es ist.

### So arbeitet ein Modus

* **Stillstehen**: Die ausgeblendeten Elemente sind versteckt.
* **Laufen**: Nach der eingestellten Zeit blenden sie auf die eingestellte Transparenz ein.
* **Wieder stillstehen**: Nach der eingestellten Zeit blenden sie wieder aus.
* **Kampf**: Alles ist voll sichtbar. Nach dem Kampf startet der Countdown zum Ausblenden neu.
* **Neue Chatnachricht**: Der Chat wird kurz eingeblendet, siehe Chat weiter unten.

### Einstellungen jedes Modus

* **Modus an oder aus**: Der Haken in der Kopfzeile des Modus.
* **Beim Hovern einblenden**: Blendet ein ausgeblendetes Element ein, solange die Maus darüber ist. Details weiter unten.
* **Transparenz**: Wie sichtbar die Elemente beim Laufen sind, von 0 bis 100 Prozent.
* **Bewegdauer bis Einblenden**: Wie lange du läufst, bevor das Interface einblendet, von 0 Sekunden (sofort) bis 10 Sekunden.
* **Ausblenden nach**: Wie lange du stillstehst, bevor das Interface ausblendet, von 5 bis 180 Sekunden in Schritten von 5.
* **Chat eingeblendet für**: Wie lange der Chat nach einer neuen Nachricht, nach dem Schließen der Chat-Eingabe und nachdem die Maus den Chat verlassen hat sichtbar bleibt, von 5 bis 180 Sekunden in Schritten von 5.
* **Immer bei 100% sichtbar**: Elemente, die in diesem Modus nie ausblenden. Du kannst jedes davon sichtbar lassen: Chat, Minimap, Quest / Ziele, Mikromenü, Taschen, Aktionsleisten, HP-Anzeigen, Buffs / Debuffs, Rufbar und Schadensanzeige. Im Housing-Modus von Retail kommt das Housing-Baumenü dazu.

### Was ausgeblendet wird

* Aktionsleisten, auch die Haltungsleiste und die Begleiterleiste
* Mikromenü
* Taschen
* Minimap, auch Markierungen wie der Spielerpfeil, und der Erweiterungs-Button
* Buffs und Debuffs
* Spieler-, Ziel-, Fokus- und Gruppenfenster
* Questverfolgung
* Ruf- und Erfahrungsleiste
* Schadensanzeige
* Schnellbeitritt-Button
* Chat
* Housing-Baumenü oben am Bildschirm (Retail, Housing-Modus)

### Chat

* Alle Chat-Tabs blenden aus, auch Flüster-Tabs und der Tab einer Battle.net-Unterhaltung.
* Ein Tab, den du aus dem Chatfenster herausziehst, blendet zusammen mit seinem Fenster aus, auch der Tab-Name.
* Eine neue Nachricht blendet den Chat für die eingestellte Zeit ein. Das gilt für Sagen, Schreien, Emotes, Flüstern, Battle.net-Flüstern, Gruppe, Schlachtzug, Gilde, Offiziere, Kanäle und Instanzchat.
* Solange die Chat-Eingabe offen ist, bleibt der Chat sichtbar. Enter drücken reicht, du musst nichts tippen. Nach dem Schließen der Eingabe bleibt der Chat für die eingestellte Zeit sichtbar.
* Mit Beim Hovern einblenden wird der Chat eingeblendet, solange die Maus darüber ist. Nachdem die Maus ihn verlassen hat, bleibt er für die eingestellte Zeit sichtbar.

### Beim Hovern einblenden

* Die Option ist der erste Eintrag in jedem Modus. Sie ist standardmäßig aus.
* Ist sie an und du fährst mit der Maus über ein ausgeblendetes Element, wird nur dieses Element eingeblendet. Der Rest bleibt ausgeblendet.
* Sie funktioniert für jedes Element aus der Liste oben, zum Beispiel die Aktionsleisten, wenn du einen Zauber suchst, die Questverfolgung oder den Chat.
* Das Hovern nutzt die Fläche jedes Elements, ein leerer Teil der Fläche der Questverfolgung reagiert also auch.
* Der Minimap-Button sitzt auf der Minimap und blendet mit ihr aus. Fahr mit der Maus über die Minimap, um ihn einzublenden.

### Einstellungsfenster und Minimap-Button

* Das Einstellungsfenster öffnest du mit `/autofade` oder mit einem Klick auf den Minimap-Button.
* Ziehe den Minimap-Button, um ihn am Rand der Minimap zu verschieben. Die Position wird gespeichert.
* Fenster und Texte gibt es auf Deutsch und Englisch.

---

## Installation

* **Download**: Interface AutoFade gibt es auf CurseForge: CURSEFORGE_LINK
* Ein Download für beide Clients. Das Addon erkennt selbst, ob es in Retail oder in Forever läuft.
* Kopiere den Ordner `InterfaceAutoFade` nach `World of Warcraft\_retail_\Interface\AddOns` für Retail oder nach `World of Warcraft\_forever_\Interface\AddOns` für Forever.
* Taucht das Addon nach einer Installation über einen Addon-Manager in Forever nicht auf, kopiere den Ordner von Hand in den Forever-Pfad.
* Die Einstellungen werden für Retail und Forever getrennt gespeichert.

## Kompatibilität

* Nutze immer nur ein Addon, das das Interface ausblendet. Zwei davon ändern dieselben Frames und arbeiten gegeneinander.
* Aklime Mod Tools enthält dieselbe Interface Ausblendung. Nutzt du beide, schalte die Interface Ausblendung in einem von beiden aus.

## Befehle

| Befehl | Funktion |
|--------|----------|
| `/autofade` | Einstellungsfenster öffnen / schließen |
