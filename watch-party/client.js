// client.js - handles lobby UI interactions

// Share button: copy current lobby URL to clipboard
const shareBtn = document.getElementById('btn-share');
if (shareBtn) {
  shareBtn.addEventListener('click', () => {
    const lobbyUrl = window.location.href;
    navigator.clipboard.writeText(lobbyUrl).then(() => {
      alert('Lobby URL copied to clipboard!');
    }).catch(err => {
      console.error('Failed to copy URL:', err);
    });
  });
}

// Existing sync modal handling (preserve previous logic if any)
const syncModal = document.getElementById('sync-modal');
if (syncModal) {
  syncModal.addEventListener('click', (e) => {
    if (e.target === syncModal) {
      syncModal.classList.add('hidden');
    }
  });
}
