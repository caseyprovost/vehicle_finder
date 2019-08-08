# README

URL: https://vehicle-finder.herokuapp.com

## Welcome to the Vehicle Finder

This is a utility that allows you to find vehicles in Fleetio. If you enter a valid VIN, you should always get back some vehicle details.

### Notes for reviewer
I really enjoyed this exercise. To be honest I have been living in SPA and APIs world for a couple of years now and it felt good to get back into a Rails-native front-end. I even decided to get a little risky and give tailwind a try here. I'm using it in a personal project and thought it would add some nice curb appeal.

Please note that sign up does not work. Sadly time expired before I could get to building out and polishing the authentication flow.

While building this I made a few assumptions:

* Vehicles should be cached locally (even when a user does not save them)
* Fuel entries don't need to be cached, as they have a 1-time use
* Users cannot browser all vehicles...only search by a VIN
* Searches by VIN are less useful if partially-matched...so exact match was favored

### Things I like
* The design, TailwindCSS is pretty awesome
* The helpful information text
* Handling of empty/null states
* Unit test coverage

### Things I would change/improve
* Increase system test coverage
* Should indicator in UI when fuel efficiency is being calculated
* DRY-up the Fleetio client and better handle non-successful responses
* Add logging of errors (if this was prod)
* Address responsive concerns

### Helful Bits

Below is some info that will make testing and usage of the app a little easier.

User Credentials:

```
email: tony.stark@avengers.net
password: iamironman
```

Some valid vin numbers:

```
1GCZGTCG7E11519I7
JTDKBRFU9J30593O7
D177BI2256K
```

