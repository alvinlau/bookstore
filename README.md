# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things that are changed or different from the tutorial sample code:

* I switched to Postgres instead of the default Sqlite from Rails, just change the database name, username and password in `config/database.yml`

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
