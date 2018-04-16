# Devdigest

Send out Spreedly's GitHub activity on a daily basis. This one repo powers two digests - the devdigest and the opsdigest (detailed further below)

## Development

To setup the app locally, copy the sample config (and make appropriate edits for secrets, dev addresses etc...):

```bash
$ cp .env.sample .env
```

Then use `heroku local` to load up the env and run one of the rake tasks:

```bash
$ heroku local:run bundle exec rake digest
```

## Deployment

*Assumes you are a collaborator on the `spreedly-devdigest` and `spreedly-opsdigest` Heroku app*

In order for the `heroku` CLI to run, you need to have the `heroku` git remote configured locally. Do so with:

```bash
$ heroku git:remote -a spreedly-devdigest -r devdigest
$ heroku git:remote -a spreedly-opsdigest -r opsdigest
```

To deploy a new version, simply use `git push` to the correct remote:

```bash
$ git push devdigest master
$ git push opsdigest master
```

## Add a new repository

The digest is a ruby script that uses the Github API to list all commits for specific repositories. You must tell the digest which repos to monitor.

To add a new repo to monitor (switch *both* `-r devdigest` flags if you need to make an opsdigest change):

```session
$ heroku config:set GITHUB_REPOS="`heroku config:get GITHUB_REPOS -r devdigest`,new-repo-name" -r devdigest
```
<!--
_This doesn't appear to be necessary anymore?_

You will then also need to give the `spreedly-bot` GitHub user access to the new repo since that's the account used by devdigest to fetch activity via the GH API. Login to GitHub as a Spreedly admin (ping @rwdaigle or @ntalbott if you're not one so they can do it for you) and go to the ["Bots" team repository list](https://github.com/orgs/spreedly/teams/bots/repositories). Add the new repo there:

![](http://cl.ly/YuTV/Image%202014-12-10%20at%209.58.34%20AM.png)
-->

## Usage

The app on Heroku is configured to send out an email once per weekday. To manually invoke this task you can run:

```session
$ heroku run bundle exec rake daily_email -r devdigest
```

If you want to see the (markdown) contents of the digest email without sending an email:

```session
$ heroku run bundle exec rake digest -r devdigest
```
