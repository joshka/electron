const { contextBridge, ipcRenderer } = require('electron/renderer');

contextBridge.exposeInMainWorld('messageBoxDemo', {
  show: (useDestructiveAction) => ipcRenderer.invoke('show-save-confirm', useDestructiveAction)
});
