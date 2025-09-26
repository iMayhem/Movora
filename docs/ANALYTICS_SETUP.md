# Firebase Analytics Setup for Movora

This document explains how Firebase Analytics is set up in your Movora app to track user behavior and app usage.

## What's Tracked

### User Authentication
- **Sign-ins**: Anonymous and Google sign-ins
- **Sign-outs**: When users log out
- **User sessions**: Start and end of app usage

### Screen Navigation
- **Screen views**: All app screens (home, search, detail, etc.)
- **Navigation patterns**: How users move through the app

### Content Interactions
- **Movie/TV show views**: When users view content details
- **Play actions**: When users start watching content
- **Search queries**: What users search for

### App Performance
- **Error tracking**: App crashes and error events
- **Feature usage**: Which app features are most popular

## How to View Analytics

### 1. Firebase Console (Primary Method)
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your Movora project
3. Navigate to **Analytics** in the left sidebar
4. View real-time and historical data

### 2. In-App Analytics Dashboard
1. Open the app drawer (hamburger menu)
2. Tap **Analytics Dashboard**
3. View basic app information and tracking details

## Key Metrics You'll See

### User Engagement
- **Daily/Monthly Active Users**: How many people use your app
- **Session duration**: How long users stay in the app
- **Screen views**: Most popular screens

### Content Performance
- **Popular searches**: What users are looking for
- **Content views**: Which movies/shows get most attention
- **Play rates**: How often content is actually watched

### User Behavior
- **Navigation patterns**: How users explore your app
- **Feature adoption**: Which features are used most
- **Retention**: How many users come back

## Privacy & Data Collection

- **Anonymous tracking**: No personal information is collected
- **User IDs**: Only anonymous Firebase UIDs are tracked
- **Content IDs**: Only TMDB content IDs (no personal data)
- **Search terms**: Only search queries (no user identification)

## Custom Events

The app tracks these custom events:

```dart
// User authentication
'user_sign_in' - When users sign in
'user_sign_out' - When users sign out
'app_session_start' - When app session begins
'app_session_end' - When app session ends

// Content interaction
'content_interaction' - Movie/TV show views and plays
'search_query' - User search terms
'category_view' - Category screen visits

// App usage
'screen_view' - Screen navigation
'feature_usage' - Feature interactions
'app_error' - Error events
```

## Setting Up Firebase Analytics

### 1. Dependencies Added
```yaml
firebase_analytics: ^10.8.0
```

### 2. Initialization
```dart
// In main.dart
await UserAnalyticsService.initialize();

// Add navigator observer
navigatorObservers: [
  FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
],
```

### 3. Automatic Tracking
- Screen views are automatically tracked
- Navigation events are logged
- App lifecycle events are monitored

## Troubleshooting

### Analytics Not Showing
1. Check Firebase Console for data delay (can take 24-48 hours)
2. Verify Firebase configuration files
3. Check internet connectivity

### Missing Events
1. Ensure analytics service is initialized
2. Check for error logs in console
3. Verify event names match Firebase requirements

## Best Practices

1. **Don't over-track**: Only track meaningful user actions
2. **Respect privacy**: Never collect personal information
3. **Test locally**: Use Firebase Console to verify events
4. **Monitor performance**: Analytics shouldn't slow down the app

## Next Steps

1. **Set up goals**: Define what success looks like
2. **Create audiences**: Group users by behavior
3. **A/B testing**: Test different app features
4. **Performance monitoring**: Track app crashes and errors

## Support

For Firebase Analytics issues:
1. Check [Firebase Documentation](https://firebase.google.com/docs/analytics)
2. Review [Flutter Firebase Guide](https://firebase.flutter.dev/docs/analytics/overview/)
3. Check Firebase Console for error logs
