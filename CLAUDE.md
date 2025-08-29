# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Rails Development
- `bundle install` - Install Ruby gems
- `bundle exec rails server` - Start development server
- `bundle exec rails console` - Open Rails console
- `bundle exec rails db:migrate` - Run database migrations
- `bundle exec rails db:seed` - Seed the database

### Testing
- `bundle exec rails test` - Run the test suite
- `bundle exec rails test:system` - Run system tests

### Database
- `bundle exec rails db:create` - Create database
- `bundle exec rails db:reset` - Reset database (drop, create, migrate, seed)
- `bundle exec rails db:rollback` - Rollback last migration

### Asset Pipeline
- `bundle exec rake assets:precompile` - Precompile assets
- `bundle exec rake assets:clean` - Clean precompiled assets

### Deployment
- `./bin/render-build.sh` - Build script for Render deployment (runs bundle install, asset precompilation, and migrations)

## Architecture Overview

ReelParty is a Rails 7.1 application for social media sharing where users create sessions to collaboratively build media playlists from various platforms (YouTube, TikTok, Instagram, etc.).

### Core Models
- **Session**: Represents a party/gathering with a host_name
- **Playlist**: Belongs to a session, contains media items
- **Medium**: Individual media items (videos/audio) with URL validation and embed codes

### Model Relationships
```
Session (1) -> Playlist (1) -> Media (many)
```

### Key Controllers
- **SessionsController**: Manages session creation and display (sessions#new, sessions#create, sessions#show)
- **MediaController**: Handles adding/removing media to playlists with real-time broadcasting
- **PlaylistsController**: Basic CRUD for playlists

### Real-time Features
- Uses Action Cable with `PlaylistChannel` for live updates
- Broadcasting on media add/remove operations
- WebSocket connections for collaborative playlist updates

### Media Platform Support
The `MediaHelper` module handles:
- Platform detection from URLs (YouTube, Vimeo, Instagram, TikTok, Spotify, SoundCloud)
- Embed code generation for each platform
- ID extraction from platform-specific URL formats

### Frontend Stack
- Rails with Turbo/Stimulus (Hotwire)
- Bootstrap 5.3 for styling
- Action Cable for WebSocket functionality
- Import maps for JavaScript modules

### Database
- PostgreSQL with the following tables:
  - `sessions` (host_name, timestamps)
  - `playlists` (session_id, timestamps)
  - `media` (title, url, embed_code, session_id, playlist_id, timestamps)

### Environment Configuration
- Development: SQLite/PostgreSQL with Redis for Action Cable
- Production: PostgreSQL on Render with Redis
- Build process defined in `render.yaml` and `bin/render-build.sh`

## Key Features
1. **Session Management**: Users create named sessions for their gatherings
2. **Media Integration**: Supports multiple platforms with automatic embed code generation
3. **Real-time Collaboration**: Live playlist updates across all connected clients
4. **URL Validation**: Ensures valid URLs before adding to playlists
5. **Platform Detection**: Automatically identifies media platform and generates appropriate embeds