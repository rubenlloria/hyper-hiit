/*
 * ProtocolEditor.qml
 * Functional companion for protocol structural changes.
 */
import QtQuick
import "."
import ".."

ProtocolEditorView {
    id: protocolEditor
    property bool isReady: false

    Component.onCompleted: isReady = true

    // headerArea.onClicked: {
    //     // Demana l'expansió exclusiva al pare (el DirectiveEditor)
    //     protocolEditor.expansionRequested(index);
    // }

    // Guardies per a l'estat Dirty (Magenta)
    // onDurationChanged: isReady ? isDirty = true : null
    // onRankChanged: isReady ? isDirty = true : null

    // signal expansionRequested(int index)
}
