# Devdigest

Send out Spreedly's GitHub activity on a daily basis.

## Development

To setup the app locally, copy the sample config:

```bash
$ cp .env.sample .env
```

Then use `heroku local` to load up the env and run one of the rake tasks:

```bash
$ heroku local:run bundle exec rake digest
```

## Configuration

*Assumes you are a collaborator on the `spreedly-devdigest` Heroku app*

### Heroku remote

In order for the `heroku` CLI to run, you need to have the `heroku` git remote configured locally. Do so with:

```bash
$ heroku git:remote -a spreedly-devdigest
```

### Add a new repository

To add a new repo to monitor:

```session
$ heroku config:set GITHUB_REPOS="`heroku config:get GITHUB_REPOS`,new-repo-name"
```

You will then also need to give the `spreedly-bot` GitHub user access to the new repo since that's the account used by devdigest to fetch activity via the GH API. Login to GitHub as a Spreedly admin (ping @rwdaigle or @ntalbott if you're not one so they can do it for you) and go to the ["Bots" team repository list](https://github.com/orgs/spreedly/teams/bots/repositories). Add the new repo there:

![](http://cl.ly/YuTV/Image%202014-12-10%20at%209.58.34%20AM.png)

## Usage

The app on Heroku is configured to send out an email once per weekday. To manually invoke this task you can run:

```session
$ heroku run bundle exec rake daily_email
```

If you want to see the (markdown) contents of the digest email without sending an email:

```session
$ heroku run bundle exec rake digest
```
