# FloatplaneApp-tvOS
My tvOS app for floatplane.

# Supported Features
Below are the features implemented in the app.

## Finding something to watch
- Browse your subscribed creators' videos.
- Search for videos by your active creator.

## Watching videos
- Watch VOD videos with video metadata in the build-in now playing bar.
- Change video quality of VOD videos during playback.
- Set a default playback quality between 360p, 480p, 720p, and 1080p.

## Livestreams
- Watch your selected creators' livestream when they are online.
- Displays the offline banner when the creator is offline.

## Login
- Allows customers to login with their username and password.
- Gives error message when login fails with whatever result comes from server.
- Allows customers to logout from the settings tab.
- Moves focus to the login button when customers finish typing their password.
    - Note that there's a focus issue if the customer goes back to the password field. For some reason it only focuses the login button if the customer starts typing from the username field.
    
## Local progress store
- The app keeps track of how far into each video you are. This is local because Floatplane's cloud does not support tracking video progress.
- This means that if you watch videos in the tvOS app, it'll keep track of all those videos, but it won't translate to the iPhone or Android apps, or the website. The same is true in reverse and the tvOS app won't be able to pick up where you leave a video on another app.

## Data storage
- The default data quality is store in the device's UserDefaults. This means default quality level will remain the same when you logout and login to another account.
- The user information received on Login is stored in Keychain.
- The session information is maintained by NSURLConnection.

## Networking
- Alamofire and AlamofireImage is used for easy network operation handling. The Operation protocol is a wrapper around Alamofire's Request functionality that turns completion block pattern into async/await pattern.
- Image caching allows the app to cache up to 150MB of thumbnails and other images.
- Most operations are cached for 5 minutes with a limit of 50 items. However, the search operation is cached with a limit of 500 items and 30 minutes.
- The Search feature doesn't actually make a network call until the customer has entered 3 characters.
    
## Design
- Follows generic video app with tabs at the top.
    - Browse tab is the default when app opens. It displays the feed of the first creator that the customer is subscribed to.
        - The sidebar for the browse page lets the customer update the active creator. This active creator currently impacts all tabs. For example, the search tab filters the active creator's feed.
    - Live tab is left of the browse tab. If the active creator is livestreaming, it immediately plays and hides the tab bar. If not, then it displays the offline banner.
    - The search tab lets the customer filter the active creator's feed by a search query.
        - Searching and browsing currently excludes image-only, text-only, or audio-only posts.
    - Settings tab has two features.
        - Default video quality, 360p, 480p, 720p, and 1080p.
        - Logout

# Backlog
- Animate and expand sidebar for creators to show the name of the creators when customer moves focus to the sidebar.
- Support non-video type posts. Audio, Image, Text posts.
- Consider support for filters and sort order in search tab
- Add video duration to the browse and search cell.
- Add support for lint and swift format.
- Add code coverage requirements.
- Add UI tests to the app target.
- Add Unit tests to the app target.
