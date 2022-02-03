I generated this profile pack using https://ffprofile.com/

To use it I just have to open firefox once to have it generate a profile, make
sure its closed then dig into ~/.mozilla/firefox for the profile. The one I was
looking for was named `wfunt4nm.default-release`. Delete everything in there
and unzip this file into that directory.

I still needed to go through and change a bunch of settings such as preferred
search and where it was getting recommendations as well as the home page, and
get my extra addons in there.

I might be able to make this 'complete' at some point but it wasn't worth the
time for me right now.

Other changes I've made:

* `dom.storage_access.enabled` -> true
* `network.captive-portal-service.enabled` -> true
