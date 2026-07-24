const result = document.querySelector('#result');

async function showDialog(useDestructiveAction) {
  result.textContent = 'Dialog open…';
  const selection = await window.messageBoxDemo.show(useDestructiveAction);
  result.textContent = `${selection.variant}: response ${selection.index} (${selection.label})`;
}

document.querySelector('#baseline').addEventListener('click', () => {
  showDialog(false);
});

document.querySelector('#destructive').addEventListener('click', () => {
  showDialog(true);
});
