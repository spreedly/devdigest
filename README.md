# Devdigest

Send out Spreedly's GitHub activity on a (week)daily basis.

## Configuration

*Assumes you are a collaborator on the `spreedly-devdigest` Heroku app*

To add a new repo to monitor:

```session
$ heroku config:set GITHUB_REPOS="`heroku config:get GITHUB_REPOS`,new-repo-name"
```

This will monitor the given repos *only* for the activity of a set of users. To add a new user to the set of users:

```session
$ heroku config:set GITHUB_USERS="`heroku config:get GITHUB_USERS`,new-user"
```

A bunch of other settings can be found with `heroku config`.

## Usage

The app on Heroku is configured to send out an email once per weekday. To manually invoke this task you can run:

```session
$ heroku run bundle exec rake daily_email
```

If you want to see the (markdown) contents of the digest email without sending an email:

```session
$ heroku run bundle exec rake digest
```
