const path = require('node:path');

const { app, BrowserWindow, dialog, ipcMain } = require('electron/main');

const buttons = ['Save', "Don't Save", 'Cancel'];

let mainWindow;

async function showSaveConfirm(useDestructiveAction) {
  const options = {
    type: 'warning',
    buttons,
    defaultId: 0,
    cancelId: 2,
    message: 'Do you want to save the changes you made?',
    detail: 'Your changes will be lost if you do not save them.'
  };

  if (useDestructiveAction) {
    options.destructiveId = 1;
  }

  const { response } = await dialog.showMessageBox(mainWindow, options);
  const result = {
    index: response,
    label: buttons[response],
    variant: useDestructiveAction ? 'destructive' : 'baseline'
  };
  console.log(`[${result.variant}] response ${result.index}: ${result.label}`);
  return result;
}

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 720,
    height: 560,
    webPreferences: {
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js')
    }
  });

  mainWindow.loadFile('index.html');
  mainWindow.on('closed', () => {
    mainWindow = undefined;
  });
}

app.whenReady().then(createWindow);

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

ipcMain.handle('show-save-confirm', (_event, useDestructiveAction) => showSaveConfirm(useDestructiveAction));
