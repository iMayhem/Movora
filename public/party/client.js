// Global state variables
let currentRoomId = null;
let username = null;

// Supabase client instance and config keys
let supabaseClient = null;
const savedUrl = localStorage.getItem('supabase_url') || 'https://ggzuydqfxamvwalbfvyr.supabase.co';
const savedKey = localStorage.getItem('supabase_key') || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdnenV5ZHFmeGFtdndhbGJmdnlyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkyODk3MzQsImV4cCI6MjA5NDg2NTczNH0.B6A0oTZmds2vSrrKbfd0Nb1_Dal1pUnJutigiRZda2I';

if (savedUrl && savedKey) {
    try {
        supabaseClient = window.supabase.createClient(savedUrl, savedKey);
    } catch (e) {
        console.error("Failed to initialize Supabase client:", e);
    }
}

// Multiple video player embed sources
let embedSources = null;
let activePlayer = localStorage.getItem('watch_preferred_player') || 'vidplus';

// Clock offset state to sync client/server time
let serverStartTime = null;
let clientServerOffset = 0; // Difference between client and server system clock in ms
let syncInterval = null;
let realtimeChannel = null;

// DOM Elements
const roomSelectorScreen = document.getElementById('room-selector-screen');
const watchLobbyScreen = document.getElementById('watch-lobby-screen');
const roomsGrid = document.getElementById('rooms-grid');

const usernameModal = document.getElementById('username-modal');
const usernameForm = document.getElementById('username-form');
const usernameInput = document.getElementById('username-input');

const lobbyMovieTitle = document.getElementById('lobby-movie-title');
const videoPlayer = document.getElementById('video-player');
const videoOverlay = document.getElementById('video-overlay');

const syncBanner = document.getElementById('sync-banner');
const syncBannerIcon = document.getElementById('sync-banner-icon');
const syncBannerText = document.getElementById('sync-banner-text');
const syncManualBtn = document.getElementById('sync-manual-btn');

const chatMessages = document.getElementById('chat-messages');
const chatForm = document.getElementById('chat-form');
const chatInput = document.getElementById('chat-input');
const lobbyUsernameLabel = document.getElementById('lobby-username');

const btnBack = document.getElementById('btn-back');
const btnLightsOut = document.getElementById('btn-lights-out');

const syncModal = document.getElementById('sync-modal');
const syncTimestampVal = document.getElementById('sync-timestamp-val');
const closeSyncModalBtn = document.getElementById('close-sync-modal');

// Database Configuration elements
const btnConfig = document.getElementById('btn-config');
const configModal = document.getElementById('config-modal');
const configForm = document.getElementById('config-form');
const supabaseUrlInput = document.getElementById('supabase-url-input');
const supabaseKeyInput = document.getElementById('supabase-key-input');
const closeConfigModalBtn = document.getElementById('close-config-modal');

// ==========================================================================
// INITIALIZATION AND ROUTING
// ==========================================================================

document.addEventListener('DOMContentLoaded', () => {
    // Check if username already exists in localStorage
    username = localStorage.getItem('watch_username');
    if (username) {
        lobbyUsernameLabel.textContent = username;
    }

    // Show configuration gear button only to administrators (via ?setup=1 or ?admin=true query parameter)
    const urlParams = new URLSearchParams(window.location.search);
    if (urlParams.get('setup') === '1' || urlParams.get('admin') === 'true') {
        btnConfig.classList.remove('hidden');
    }

    // Bind Configuration Gear Button triggers
    btnConfig.addEventListener('click', () => {
        supabaseUrlInput.value = localStorage.getItem('supabase_url') || 'https://ggzuydqfxamvwalbfvyr.supabase.co';
        supabaseKeyInput.value = localStorage.getItem('supabase_key') || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdnenV5ZHFmeGFtdndhbGJmdnlyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkyODk3MzQsImV4cCI6MjA5NDg2NTczNH0.B6A0oTZmds2vSrrKbfd0Nb1_Dal1pUnJutigiRZda2I';
        configModal.classList.remove('hidden');
    });

    closeConfigModalBtn.addEventListener('click', () => {
        configModal.classList.add('hidden');
    });

    configForm.addEventListener('submit', (e) => {
        e.preventDefault();
        const urlVal = supabaseUrlInput.value.trim();
        const keyVal = supabaseKeyInput.value.trim();

        if (urlVal && keyVal) {
            localStorage.setItem('supabase_url', urlVal);
            localStorage.setItem('supabase_key', keyVal);
            configModal.classList.add('hidden');
            // Reload the page to connect and fetch fresh data
            window.location.reload();
        }
    });

    // Lights Out Cinema Mode toggler
    if (btnLightsOut) {
        const savedLightsOut = localStorage.getItem('watch_lights_out') === 'true';
        if (savedLightsOut) {
            document.body.classList.add('lights-out-active');
            btnLightsOut.classList.add('active');
            btnLightsOut.innerHTML = '💡 Lights On';
        }

        btnLightsOut.addEventListener('click', () => {
            const isActive = document.body.classList.toggle('lights-out-active');
            btnLightsOut.classList.toggle('active', isActive);
            localStorage.setItem('watch_lights_out', isActive);
            if (isActive) {
                btnLightsOut.innerHTML = '💡 Lights On';
            } else {
                btnLightsOut.innerHTML = '💡 Lights Out';
            }
        });
    }

    // Parse URL room parameters
    const roomParam = urlParams.get('room');

    if (roomParam) {
        currentRoomId = roomParam;
        if (!username) {
            showUsernameModal();
        } else {
            enterLobby(currentRoomId, username);
        }
    } else {
        showRoomSelector();
    }
});

// Watch URL parameter changes (Back/Forward browser buttons)
window.addEventListener('popstate', () => {
    const urlParams = new URLSearchParams(window.location.search);
    const roomParam = urlParams.get('room');
    
    if (roomParam) {
        currentRoomId = roomParam;
        if (username) {
            enterLobby(currentRoomId, username);
        } else {
            showUsernameModal();
        }
    } else {
        leaveLobbyAndReturn();
    }
});

// ==========================================================================
// SCREEN: ROOM SELECTOR
// ==========================================================================

async function showRoomSelector() {
    roomSelectorScreen.classList.add('active');
    watchLobbyScreen.classList.remove('active');
    disconnectRealtime();

    if (!supabaseClient) {
        roomsGrid.innerHTML = `
            <div class="loading-state" style="padding: 3rem 1.5rem; border: 1px dashed rgba(255,255,255,0.1); border-radius: 12px; margin-top: 1rem;">
                <p style="color: var(--text-muted); font-size: 1rem; line-height: 1.5;">Welcome to Moovie Watch Party!</p>
                <p style="color: #a78bfa; font-size: 0.9rem; margin-top: 0.5rem; font-weight: 500;">Please click the ⚙️ gear icon in the top right to configure your serverless Supabase connection.</p>
            </div>
        `;
        return;
    }

    try {
        // Fetch rooms and measure server clock offset in a single REST request!
        const url = `${savedUrl}/rest/v1/rooms?select=*`;
        const response = await fetch(url, {
            headers: {
                'apikey': savedKey,
                'Authorization': `Bearer ${savedKey}`
            }
        });
        if (!response.ok) throw new Error('Failed to connect to Supabase.');
        
        const rooms = await response.json();
        
        // Measure clock offset using NTP-synchronized response header
        const serverTimeStr = response.headers.get('Date') || new Date().toISOString();
        const clientNow = Date.now();
        const serverNow = new Date(serverTimeStr).getTime();
        clientServerOffset = clientNow - serverNow;

        renderRooms(rooms);
    } catch (error) {
        console.error(error);
        roomsGrid.innerHTML = `
            <div class="loading-state">
                <p style="color: #ef4444;">⚠️ Error connecting to Supabase database. Check your configuration keys by clicking the ⚙️ icon.</p>
            </div>
        `;
    }
}

function renderRooms(rooms) {
    roomsGrid.innerHTML = '';

    if (rooms.length === 0) {
        roomsGrid.innerHTML = `
            <div class="loading-state">
                <p>No active scheduled lobbies. Insert rooms using schema.sql in your Supabase SQL editor!</p>
            </div>
        `;
        return;
    }

    rooms.forEach(room => {
        const card = document.createElement('div');
        card.className = 'glass-card room-card';
        
        // Calculate dynamic status tag using the server-skew corrected timestamp
        const adjustedNow = Date.now() - clientServerOffset;
        const timeDiffSeconds = Math.floor((adjustedNow - new Date(room.scheduled_start_time).getTime()) / 1000);

        let stateTag = '';
        let stateClass = '';
        let relativeDesc = '';

        if (timeDiffSeconds < 0) {
            stateTag = 'Countdown';
            stateClass = 'tag-countdown';
            const absSecs = Math.abs(timeDiffSeconds);
            relativeDesc = `Starts in ${formatCountdownDesc(absSecs)}`;
        } else if (timeDiffSeconds >= 0 && timeDiffSeconds <= 10) {
            stateTag = 'Starting Now';
            stateClass = 'tag-alert';
            relativeDesc = 'Starts at zero hour!';
        } else {
            stateTag = 'In Progress';
            stateClass = 'tag-catchup';
            relativeDesc = `Running for ${formatTime(timeDiffSeconds)}`;
        }

        card.innerHTML = `
            <span class="room-tag ${stateClass}">${stateTag}</span>
            <h3>${room.movie_title}</h3>
            <div class="room-meta">
                <p class="room-time-desc">${relativeDesc}</p>
            </div>
            <button class="btn btn-primary room-btn-select">Enter Watch Lobby</button>
        `;

        card.addEventListener('click', () => {
            selectRoom(room.id);
        });

        roomsGrid.appendChild(card);
    });
}

function selectRoom(roomId) {
    currentRoomId = roomId;
    const url = new URL(window.location);
    url.searchParams.set('room', roomId);
    window.history.pushState({}, '', url);

    if (!username) {
        showUsernameModal();
    } else {
        enterLobby(currentRoomId, username);
    }
}

// Username modal control
function showUsernameModal() {
    usernameModal.classList.remove('hidden');
    usernameInput.focus();
}

usernameForm.addEventListener('submit', (e) => {
    e.preventDefault();
    const inputVal = usernameInput.value.trim();
    if (inputVal) {
        username = inputVal;
        localStorage.setItem('watch_username', username);
        lobbyUsernameLabel.textContent = username;
        usernameModal.classList.add('hidden');
        if (currentRoomId) {
            enterLobby(currentRoomId, username);
        }
    }
});

// ==========================================================================
// SCREEN: WATCH LOBBY MAIN LOBBY SYSTEM
// ==========================================================================

async function enterLobby(roomId, userAlias) {
    roomSelectorScreen.classList.remove('active');
    watchLobbyScreen.classList.add('active');

    lobbyMovieTitle.textContent = "Connecting to Database...";
    videoPlayer.src = "";
    videoOverlay.classList.add('hidden');
    chatMessages.innerHTML = '';

    if (!supabaseClient) {
        lobbyMovieTitle.textContent = "Configuration Missing";
        alert("Please set up your Supabase connection parameters on the Room selector first!");
        leaveLobbyAndReturn();
        return;
    }

    try {
        // Fetch specific room details
        const url = `${savedUrl}/rest/v1/rooms?id=eq.${roomId}&select=*`;
        const response = await fetch(url, {
            headers: {
                'apikey': savedKey,
                'Authorization': `Bearer ${savedKey}`
            }
        });
        if (!response.ok) throw new Error('Lobby not found');
        const results = await response.json();
        
        let roomData = null;
        if (results.length === 0) {
            const urlParams = new URLSearchParams(window.location.search);
            const titleParam = urlParams.get('title');
            if (titleParam) {
                const decodedTitle = decodeURIComponent(titleParam);
                const newRoom = {
                    id: roomId,
                    movie_title: decodedTitle,
                    embed_sources: {
                        vidplus: `https://player.vidplus.to/embed/movie/${roomId}`,
                        videasy: `https://player.videasy.net/movie/${roomId}`,
                        vidsrc: `https://vidsrc-embed.ru/embed/movie?tmdb=${roomId}&autoplay=1`
                    },
                    scheduled_start_time: new Date().toISOString()
                };

                const insertResponse = await fetch(`${savedUrl}/rest/v1/rooms`, {
                    method: 'POST',
                    headers: {
                        'apikey': savedKey,
                        'Authorization': `Bearer ${savedKey}`,
                        'Content-Type': 'application/json',
                        'Prefer': 'return=representation'
                    },
                    body: JSON.stringify(newRoom)
                });

                if (insertResponse.ok) {
                    const inserted = await insertResponse.json();
                    roomData = inserted[0] || newRoom;
                } else {
                    console.error("Failed to auto-create room in Supabase:", await insertResponse.text());
                    throw new Error("Lobby not found. Please enable public insert RLS policies in your Supabase admin panel, or create the room manually.");
                }
            } else {
                throw new Error('Lobby deleted or not found.');
            }
        } else {
            roomData = results[0];
        }

        // Perform time synchronization using PostgREST HTTP header
        const serverTimeStr = response.headers.get('Date') || new Date().toISOString();
        const clientNow = Date.now();
        const serverNow = new Date(serverTimeStr).getTime();
        clientServerOffset = clientNow - serverNow;

        lobbyMovieTitle.textContent = roomData.movie_title;
        serverStartTime = new Date(roomData.scheduled_start_time);
        embedSources = roomData.embed_sources;

        updatePlayerSelectorUI();

        // Connect Realtime channel
        initializeSupabaseRealtime(roomId, userAlias);

        if (syncInterval) clearInterval(syncInterval);
        runSyncStateEngine();
        syncInterval = setInterval(() => runSyncStateEngine(), 1000);

    } catch (e) {
        console.error(e);
        alert("Error loading lobby details: " + e.message);
        leaveLobbyAndReturn();
    }
}

function initializeSupabaseRealtime(roomId, userAlias) {
    disconnectRealtime();

    const channelName = `watch_lobby_${roomId}`;
    realtimeChannel = supabaseClient.channel(channelName, {
        config: {
            presence: {
                key: userAlias,
            },
        },
    });

    // 1. Listen for Chat Broadcasts
    realtimeChannel.on('broadcast', { event: 'chat' }, (payload) => {
        renderMessage(payload.payload);
    });

    // 2. Listen to Presence online indicator
    realtimeChannel.on('presence', { event: 'sync' }, () => {
        const presenceState = realtimeChannel.presenceState();
        const onlineCount = Object.keys(presenceState).length;
        document.getElementById('user-count').innerHTML = `Joined: <span>${escapeHtml(userAlias)}</span> (${onlineCount} online)`;
    });

    realtimeChannel.on('presence', { event: 'join' }, ({ key, newPresences }) => {
        // Avoid duplicate rendering for own presence joins
        if (key !== userAlias) {
            renderMessage({
                type: 'system',
                text: `📢 ${key} has joined the lobby!`,
                timestamp: new Date().toISOString()
            });
        }
    });

    realtimeChannel.on('presence', { event: 'leave' }, ({ key, leftPresences }) => {
        renderMessage({
            type: 'system',
            text: `🚪 ${key} has left the lobby.`,
            timestamp: new Date().toISOString()
        });
    });

    // Connect subscription
    realtimeChannel.subscribe(async (status) => {
        if (status === 'SUBSCRIBED') {
            await realtimeChannel.track({
                username: userAlias,
                online_at: new Date().toISOString()
            });
        }
    });
}

function disconnectRealtime() {
    if (syncInterval) {
        clearInterval(syncInterval);
        syncInterval = null;
    }
    if (realtimeChannel) {
        supabaseClient.removeChannel(realtimeChannel);
        realtimeChannel = null;
    }
}

// ==========================================================================
// THE SYNCHRONIZATION BANNER STATE MACHINE
// ==========================================================================

function runSyncStateEngine() {
    if (!serverStartTime || !embedSources) return;

    const adjustedNow = Date.now() - clientServerOffset;
    const timeDiffSeconds = Math.floor((adjustedNow - serverStartTime.getTime()) / 1000);
    const targetUrl = embedSources[activePlayer] || embedSources.vidplus;

    // 1. COUNTDOWN MODE
    if (timeDiffSeconds < 0) {
        const remainingSeconds = Math.abs(timeDiffSeconds);
        
        syncBanner.className = "sync-banner banner-countdown";
        syncBannerIcon.textContent = "⏳";
        syncBannerText.textContent = `Movie starts in ${formatCountdownDesc(remainingSeconds)}`;
        syncManualBtn.classList.add('hidden');

        if (videoPlayer.src) {
            videoPlayer.src = "";
        }
        videoOverlay.classList.remove('hidden');
    }
    // 2. ALERT MODE
    else if (timeDiffSeconds >= 0 && timeDiffSeconds <= 10) {
        syncBanner.className = "sync-banner banner-alert";
        syncBannerIcon.textContent = "🚨";
        syncBannerText.textContent = "IT'S TIME! CLICK PLAY ON THE VIDEO NOW! 🚨";
        syncManualBtn.classList.add('hidden');

        videoOverlay.classList.add('hidden');
        if (!videoPlayer.src || videoPlayer.src !== targetUrl) {
            videoPlayer.src = targetUrl;
        }
    }
    // 3. CATCH-UP MODE
    else {
        syncBanner.className = "sync-banner banner-catchup";
        syncBannerIcon.textContent = "🎬";
        syncBannerText.textContent = `Room Progress: ${formatTime(timeDiffSeconds)}`;
        syncManualBtn.classList.remove('hidden');

        videoOverlay.classList.add('hidden');
        if (!videoPlayer.src || videoPlayer.src !== targetUrl) {
            videoPlayer.src = targetUrl;
        }
    }
}

// Update the source selector tabs in the Watch Lobby
function updatePlayerSelectorUI() {
    const pills = document.querySelectorAll('#player-selector .pill-btn');
    pills.forEach(pill => {
        if (pill.getAttribute('data-player') === activePlayer) {
            pill.classList.add('active');
        } else {
            pill.classList.remove('active');
        }
    });
}

// Bind clicks to selector pills
document.addEventListener('DOMContentLoaded', () => {
    document.querySelectorAll('#player-selector .pill-btn').forEach(pill => {
        pill.addEventListener('click', () => {
            const playerKey = pill.getAttribute('data-player');
            if (playerKey && playerKey !== activePlayer) {
                activePlayer = playerKey;
                localStorage.setItem('watch_preferred_player', activePlayer);
                updatePlayerSelectorUI();
                
                if (serverStartTime && embedSources) {
                    const adjustedNow = Date.now() - clientServerOffset;
                    const timeDiffSeconds = Math.floor((adjustedNow - serverStartTime.getTime()) / 1000);
                    if (timeDiffSeconds >= 0) {
                        const targetUrl = embedSources[activePlayer];
                        if (targetUrl) {
                            videoPlayer.src = targetUrl;
                        }
                    }
                }
            }
        });
    });
});

// Helper: formats seconds to HH:MM:SS
function formatTime(totalSeconds) {
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = totalSeconds % 60;

    const pad = (num) => String(num).padStart(2, '0');
    return `${pad(hours)}:${pad(minutes)}:${pad(seconds)}`;
}

// Helper: formats countdown display
function formatCountdownDesc(totalSeconds) {
    const hours = Math.floor(totalSeconds / 3600);
    const minutes = Math.floor((totalSeconds % 3600) / 60);
    const seconds = totalSeconds % 60;

    const pad = (num) => String(num).padStart(2, '0');

    if (hours > 0) {
        return `${hours}h ${pad(minutes)}m ${pad(seconds)}s`;
    }
    return `${pad(minutes)}m ${pad(seconds)}s`;
}

// ==========================================================================
// REAL-TIME TEXT CHAT LOGIC
// ==========================================================================

chatForm.addEventListener('submit', (e) => {
    e.preventDefault();
    const text = chatInput.value.trim();
    if (text && realtimeChannel) {
        const payload = {
            type: 'user',
            username: username,
            text: text,
            timestamp: new Date().toISOString()
        };

        // Broadcast to channel
        realtimeChannel.send({
            type: 'broadcast',
            event: 'chat',
            payload: payload
        });

        // Add to local chat UI instantly
        renderMessage(payload);

        chatInput.value = '';
        chatInput.focus();
    }
});

function renderMessage(data) {
    const msgDiv = document.createElement('div');

    if (data.type === 'system') {
        msgDiv.className = 'msg-system animate-fade-in';
        msgDiv.textContent = data.text;
    } else {
        const isMe = data.username === username;
        msgDiv.className = `msg-wrapper ${isMe ? 'me' : ''} animate-fade-in`;

        const timestampStr = new Date(data.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

        msgDiv.innerHTML = `
            <div class="msg-header">
                <span class="msg-username">${isMe ? 'You' : data.username}</span>
                <span class="msg-time">${timestampStr}</span>
            </div>
            <div class="msg-bubble">${escapeHtml(data.text)}</div>
        `;
    }

    chatMessages.appendChild(msgDiv);
    chatMessages.scrollTop = chatMessages.scrollHeight;
}

// Escapes HTML tags to prevent cross-site scripting (XSS)
function escapeHtml(str) {
    return str
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

// ==========================================================================
// MANUAL SEEK SYNC CALCULATOR AND MODAL CONTROL
// ==========================================================================

syncManualBtn.addEventListener('click', (e) => {
    e.preventDefault();
    if (!serverStartTime) return;

    const adjustedNow = Date.now() - clientServerOffset;
    const timeDiffSeconds = Math.max(0, Math.floor((adjustedNow - serverStartTime.getTime()) / 1000));

    syncTimestampVal.textContent = formatTime(timeDiffSeconds);
    syncModal.classList.remove('hidden');
});

closeSyncModalBtn.addEventListener('click', () => {
    syncModal.classList.add('hidden');
});

syncModal.addEventListener('click', (e) => {
    if (e.target === syncModal) {
        syncModal.classList.add('hidden');
    }
});

// ==========================================================================
// NAVIGATION BACK EVENTS
// ==========================================================================

btnBack.addEventListener('click', () => {
    leaveLobbyAndReturn();
});

function leaveLobbyAndReturn() {
    disconnectRealtime();
    
    const urlParams = new URLSearchParams(window.location.search);
    const roomParam = urlParams.get('room');
    
    if (roomParam) {
        // Redirect directly back to the exact movie details page
        window.location.href = `/movie/${roomParam}`;
    } else {
        const url = new URL(window.location);
        url.searchParams.delete('room');
        window.history.pushState({}, '', url);
        showRoomSelector();
    }
}
