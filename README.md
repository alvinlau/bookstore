# README


## How To Run


1. Setup PostgresSQL

`PostgreSQL` should be installed and running, with the database and user setup. For example, in `config/database.yml`:

```
development:
  adapter: postgresql
  encoding: unicode
  database: bookstore_dev
  pool: 5
  username: alvin
  password: paywith
  timeout: 5000
```
Edit this file and specify `database`, `username`, `password` that matches what is on your system. We are expecting the default port `5432` to be used.


2. Run rails server

Run `bin/rails s` in the root directory of this project

3. Run ember client

Run `ember server --proxy http://localhost:3000` in the `bookstore` subdirectory

4. Open browser client

Go to `http://localhost:4200` in the browser.  The details in the UI are outlined in the tutorial.  In summary, the root page shows list of books, click 'Show More' to view full more books.  Clicking on any book will show the modal purchase dialog.  Clicking on an author will redirect to the author page with their published books.


## Creating Authors Using Github Issues

1. Go to the issues page of this repo (https://github.com/alvinlau/bookstore/issues) and create new issues via `New Issue` button

2. Enter the author name as the title of the issue, and the author bio in the description (initial comment) of the issue.

## Fetch changes to authors

At any point in time, the rake task can be run to fetch new changes to authors on Github Issues

`bin/rake authors:refresh`
 
This will detect new authors and any modifications and update them in the database.

## Modifying Authors

Similar to creating authors, existing authors created on Github Issues can be changed by editing the issue title and/or description (initial comment).  Run the rake task again to import the change.

## Deleting Authors

Deleting authors on Github Issues and then running the rake task will also result in the authors being deleted in the database.



# How it works

In our rake task `authors:refresh`, we call the Github Issues API using the `github_api`.  Using the API we make calls to get list of issues and issue events, after a certain `since` timestamp.  We process the issues and events and make relevant changes in our database, and if everything completes to the end, we store the timestamp in the `Settings` table in the `github_update` entry.  This timestamp marks the point in time where every issue and event before it has been processed and added to your database, so the next call can use this timestamp as the `since` parameter to the Github Issues API.

This process is idempotent, if something fails during part of the rake task and does not reach the end, the `github_update` timestamp in our database simply does not get updated.  In this case when the rake task gets run again, some of the issues and events we processed before the failure would be processed again but they will not have duplicate effects (including create, update, delete).  Only when all the issues and events are succesfully processed then we update the `github_update` timestamp.

For each author in our database, we added the field `github_issue_num` to tracks which issue on Github the author is fetched from.  It is unique, starts at 1 for a new repo, so I picked it over Github Issue Id which is a long number.  In this situation, The Github Issues list becomes the source of truth, and entries our `Authors` are here to reflect that.

## Github issues response behavior

During development and testing of this feature, we found that the call to get issues will return ONE issue response for each of these things that happens to an issue:
- New issue is opened
- Issue is renamed (title change)
- Issue description changed (edit or add comment)
- Issue is reopened (previously closed)

This heavily influenced the way the rake task is written and is the justification for all of the actions.

## Github issue events response behavior

Similar to the call to get issues, the call to get issue events also takes a `since` timestamp.  Unfortunately, events are only returned for issue `closed` events, but not for new issues and issue description (comment) changes.  We still rely on it to prcoess `renamed` (author name change) events.

## Additional changes and details

- I made the `Bio` section not display on the author page if the author has no bio
- Github Issues API also return pull requests as issues, and they are denoted as such by having the `pull_request` field.  I simply filter the issues containing the `pull_request` field so we only look at real issues
- Since an author has one (created automatically as per requirement) or more books, when we delete an author through the rake task, we also cascade delete books associated with the author as well.  As future work we could create a `No author` author and assign the orphaned books to that dummy user, if we want to preserve the books data
- Time format: Github takes time format in `iso8601` format, e.g. `2020-09-28T07:22:29Z`.  It is why I used expressions like `0.days.ago.iso8601` in the code instead of `Time.now` because it gives time values like `2020-09-28 07:22:29.120376` which Github outright rejects

## Further Improvements

- Making use the `since` and `state: closed` params, we could process delete authors without using issue events, but that is still risky in case no event is generated or if it is not marked with the closed time from Github, since we need it to happen after our previous update timestamp
- Since issues that have been renamed also show up in list of updated issues, we could just use that instead of using the `renamed` event
- Authentication: add config to specific authenticating as Github user used in the Github API calls, right now the unauthenticated calls is rate limited to 60 requests per hour.  Here is the doc that describes it https://docs.github.com/en/free-pro-team@latest/rest/overview/resources-in-the-rest-api#rate-limiting
  ```
  For unauthenticated requests, the rate limit allows for up to 60 requests per hour. Unauthenticated requests are associated with the originating IP address, and not the user making requests.
  ```
- Use webhooks! https://docs.github.com/en/free-pro-team@latest/developers/webhooks-and-events/about-webhooks.  It seems some of the events we are looking for, are generated if we use webhooks.  To use it we will need to make another POST endpoint that Github will call.  We also need to register our host address on Github.  We could put it up on Heroku or Digital Ocean and paste the public IP each time we run the app, in order to demo it.
- Write tests but we would have to move the code to actual class/controllers in the app, in order to mock/instantiate them for testing.


# Tutorial Notes


Things that are changed or different from the tutorial sample code:

* I switched to Postgres instead of the default Sqlite from Rails, just change the database name, username and password in `config/database.yml`

* I ended up putting the Ember project as a git submodule (not intended), in the `bookstore` directory

* I ended up using the latest version of Ember from following the tutorial

* I changed the publishing house's `discount` column to have a precision of 5 digits, because it wouldn't accept whole integer values like in the seeds, maybe it's a rejection from Postgres.  I meant for `discount` precision of 5 to accept values like `40.00` for example, but after the change it took `40` as well

* The current Ember component structure now seem to expect both the `.hbs` template AND `.js` definition to be in the components folder, as opposed to being in the having the `.hbs` file in the `templates` folder;  In fact, the behavior wasn't working until I added the `.js` file in the `components` folder later in the tutorial

* Many of the js extensions that the handlers use in the tutorial, are now in the form of 

```
export default class BooksController extends Controller {
}
```

I'm not too familiar with the function-as-object difference in js, so I used the older way in the tutorial and it still works

```
export default Controller.extend({
  queryParams: ["limit"],
  limit: 5,

  ...
});
```

This didn't work syntax wise

```
export default class BooksController extends Controller {
  queryParams: ["limit"],
  limit: 5,

  ...
}
```
