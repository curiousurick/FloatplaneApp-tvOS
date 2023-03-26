# FloatplaneApp-tvOS
My test app for floatplane


# To test

1. Rename `UserConfiguration.swift.bak` to `UserConfiguration.swift`
2. Put your own session cookie as the value for `cookie`.
3. CMD+R to install the app on your target device or simulator.

# To get a session cookie.
1. Go to floatplane.com
2. Login
3. Inspect the site and refresh the page.
4. Go to the network tab and browse the cookies.
5. Look for the cookie with key `_cfuvid`
6. Grab the value.
