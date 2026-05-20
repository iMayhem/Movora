const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const path = require('path');
const cors = require('cors');

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
});

const PORT = process.env.PORT || 3001;

// Enable CORS and JSON parsing
app.use(cors());
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// Seeded rooms using relative times based on server startup time
// This guarantees that when the user starts the server, they have valid rooms for testing all 3 modes immediately!
const now = new Date();

const rooms = {
  "interstellar": {
    roomId: "interstellar",
    movieTitle: "Interstellar",
    embedUrl: "https://player.vidplus.to/embed/movie/157336",
    embedSources: {
      vidplus: "https://player.vidplus.to/embed/movie/157336",
      videasy: "https://player.videasy.net/movie/157336",
      vidsrc: "https://vidsrc-embed.ru/embed/movie?tmdb=157336&autoplay=1"
    },
    // Starts 120 seconds (2 minutes) in the future -> COUNTDOWN MODE
    scheduledStartTime: new Date(now.getTime() + 120 * 1000).toISOString(),
  },
  "dark-knight": {
    roomId: "dark-knight",
    movieTitle: "The Dark Knight",
    embedUrl: "https://player.vidplus.to/embed/movie/155",
    embedSources: {
      vidplus: "https://player.vidplus.to/embed/movie/155",
      videasy: "https://player.videasy.net/movie/155",
      vidsrc: "https://vidsrc-embed.ru/embed/movie?tmdb=155&autoplay=1"
    },
    // Started 5 seconds ago -> ALERT MODE (active for first 10s: 0s to 10s progress)
    scheduledStartTime: new Date(now.getTime() - 5 * 1000).toISOString(),
  },
  "spider-verse": {
    roomId: "spider-verse",
    movieTitle: "Spider-Man: Into the Spider-Verse",
    embedUrl: "https://player.vidplus.to/embed/movie/324857",
    embedSources: {
      vidplus: "https://player.vidplus.to/embed/movie/324857",
      videasy: "https://player.videasy.net/movie/324857",
      vidsrc: "https://vidsrc-embed.ru/embed/movie?tmdb=324857&autoplay=1"
    },
    // Started 45 minutes (2700 seconds) ago -> CATCH-UP MODE
    scheduledStartTime: new Date(now.getTime() - 2700 * 1000).toISOString(),
  }
};

// REST API endpoints
app.get('/api/rooms', (req, res) => {
  const roomsList = Object.values(rooms).map(room => {
    const timeDiffSeconds = Math.floor((Date.now() - new Date(room.scheduledStartTime).getTime()) / 1000);
    return {
      ...room,
      timeDiffSeconds,
      serverTime: new Date().toISOString()
    };
  });
  res.json(roomsList);
});

app.get('/api/rooms/:roomId', (req, res) => {
  const room = rooms[req.params.roomId];
  if (!room) {
    return res.status(404).json({ error: 'Room not found' });
  }
  const timeDiffSeconds = Math.floor((Date.now() - new Date(room.scheduledStartTime).getTime()) / 1000);
  res.json({
    ...room,
    timeDiffSeconds,
    serverTime: new Date().toISOString()
  });
});

// Socket.io Real-Time Synchronization & Chat Logic
io.on('connection', (socket) => {
  let currentRoom = null;
  let currentUsername = null;

  console.log(`Socket connected: ${socket.id}`);

  // Handle client joining a watch room
  socket.on('join-room', ({ roomId, username }) => {
    const room = rooms[roomId];
    if (!room) {
      socket.emit('error-msg', { message: 'Room not found.' });
      return;
    }

    currentRoom = roomId;
    currentUsername = username || `Guest_${socket.id.substring(0, 5)}`;

    // Join the Socket.io room channel
    socket.join(roomId);
    console.log(`${currentUsername} joined room: ${roomId}`);

    // Calculate sync diff at the instant of join
    const timeDiffSeconds = Math.floor((Date.now() - new Date(room.scheduledStartTime).getTime()) / 1000);

    // Reply to the joining client with initial room details and timing status
    socket.emit('room-details', {
      roomId: room.roomId,
      movieTitle: room.movieTitle,
      embedUrl: room.embedUrl,
      embedSources: room.embedSources,
      scheduledStartTime: room.scheduledStartTime,
      timeDiffSeconds,
      serverTime: new Date().toISOString()
    });

    // Broadcast a system message to the room announcing the new user
    io.to(roomId).emit('chat-message', {
      type: 'system',
      text: `📢 ${currentUsername} has joined the lobby!`,
      timestamp: new Date().toISOString()
    });
  });

  // Handle client chat message
  socket.on('chat-message', (text) => {
    if (!currentRoom || !currentUsername) return;

    // Broadcast user chat message to the room
    io.to(currentRoom).emit('chat-message', {
      type: 'user',
      username: currentUsername,
      text: text.trim(),
      timestamp: new Date().toISOString()
    });
  });

  // Handle disconnect
  socket.on('disconnect', () => {
    console.log(`Socket disconnected: ${socket.id}`);
    if (currentRoom && currentUsername) {
      // Broadcast a system message that the user left
      io.to(currentRoom).emit('chat-message', {
        type: 'system',
        text: `🚪 ${currentUsername} has left the lobby.`,
        timestamp: new Date().toISOString()
      });
    }
  });
});

// Start the server
server.listen(PORT, () => {
  console.log(`==================================================`);
  console.log(`🎬 Watch Party Lobby Server is running on port ${PORT}`);
  console.log(`🔗 Local Address: http://localhost:${PORT}`);
  console.log(`==================================================`);
});
