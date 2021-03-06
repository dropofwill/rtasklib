# rtasklib

## Public API


rtasklib::

For now require `task --version` > 2.4.0, we can work on backwards
compatibility later.

### TaskWarrior Direct

* #filter(filter_string)
  just send random shit to task and handle the probable errors properly
  `task #{filter_string} export`

* add(

### ActiveRecord API

#### Required

* #where()
  takes string or hash arguments
  strings get past directly to `task <filter> export`
  returns a chainable relationship, instead of the raw objects of #find

* #find(uuid | id)
  #find([uuid | id, ...])

* #take(num=1)

* #first(num=1)
  #last(num=1)
  Num is how many to return
  Should this be by urgency or id or uuid?

* #find_by(key: value)
  e.g. #find_by(project: "LinuxDev") which is the same as
  #where(project: "LinuxDev").take or .first

  #find_by!(key: value) is the same, but throws an error

* #all()

* #order()
  either sql style string or AR style hash:
  "created at DESC" or created_at: :desc
  Chainable on relations from #where

* #select() alias #project()
  same as #order()
  Only returns the listed columns

* #distinct()
  same as #take() but for selection/projections

* #limit(num)
  maximum number of rows to return

* #offset(num)
  change the starting point of a query

* #readonly()

* #find_or_create_by(), #find_or_create_by!()

* #count alias #size, #length

* #pluck()

* #exists?()

* #explain() show underlying command structure


#### Probs should, but nah

* Optimistic or Pessimistic locking to prevent race conditions

* Eager loading

* Scopes


#### Maybe

* #average(), #minimum(), #maximum(), #sum()

* #none(), returns an empty relation, useful in chains perhaps?

* #find_each(), #find_in_batches()
  load all tasks in in batches, unnecessary for the task interface?

* #joins()? Maybe for dependencies?

* #group()? Out of scope probably? Needs a motivating use case.

* #having()? Require group to be working first

* #unscope, #only, #reorder, #reverse_order, #rewhere
  These exist for performance reasons in SQL, probably not necessary for us.



## [TaskWarrior 3rd-Party Guidelines]()

Taskwarrior can be extended by means of a third-party application. There are script examples of import and export add-ons that support many different formats (clone the repository, look in task.git/scripts/add-ons). Then there are more sophisticated applications such as Vit that provide a complete replacement UI.

All of these provide interesting new features and improve ease of use for different kinds of users. We encourage you to create such add-ons, but in doing so, there are some rules that must be followed, which will not only protect the users data from mistreatment, but also your application from being sensitive to changes in Taskwarrior.

### Rules

* Produce, consume and handle UTF8 text properly. UTF8 is the only text encoding supported by Taskwarrior.

* Don't attempt to parse the pending.data file. Here's why: the .data file format is currently on its fourth version. The very first version was never released, so if you want to read Taskwarrior data properly, you will need to parse the three supported formats. Those formats are not documented. Additionally, you will need to handle the GC operations, implement the task "unwait" feature, observe user defined attribute handling restrictions, and implement recurring task synthesis all of which require .taskrc and default value access. You would essentially be rewriting the data access and configuration portion of Taskwarrior, which is a major undertaking. To support filters you would also need to evaluate the supported clauses, provide DOM access and implement aliases. Then there is also the fifth data format, which is planned...

* Use the export command to query data from Taskwarrior. The export command implements filters which you can use, or you can omit a filter, get all the data, and implement your own filtering. JSON parsing is very well supported in all relevant programming languages, which means you should be using Taskwarrior itself to query the data, with a commodity JSON parser in conjunction. While the JSON format will be tweaked over time, the general form will not.

* Use the command line interface to put data into Taskwarrior. Composing a valid command line is a simple way to put data in to Taskwarrior, and the ONLY way to modify data in Taskwarrior.

* Verify feature support by running task --version. This command returns the version number, which will help you determine whether or not a particular feature is supported. Note that this command does not scan for a configuration file, and is therefore safe to run if Taskwarrior is not yet set up.

* UDAs (User Defined Attributes) must be preserved in the data. When reading the JSON for a task, there may be attributes that you have never encountered before. If this is the case, you must not modify them in any way. This not only makes your application future-proof, but allows it to tolerate UDAs from other data sources. It also prevents the Taskserver from stripping out your data.
Guidelines

* If you need to store additional data, consider putting your own data file in the ~/.task directory. Just don't use the file names pending.data, completed.data, backlog.data, undo.data or synch.key.

* There are many helper commands designed to assist add-on scripts such as shell completion scripts. These commands all begin with an underscore, see them with this command: `task help | grep ' _'`.

* Familiarize yourself with the means of forcing color on or off, disabling word wrapping, disabling bulk operation limitations, disabling confirmation, disabling gc, modifying verbosity and so on. There are ways around almost all the restrictions, and while these don't make sense for regular users, they can be critical for add-on authors.

## Classes

```
TaskWarriorException =>     optional?, TaskException


ReadOnlyDictView =>         external, possibly IceNine

    Deepcopies data to enforce immutability


SerializingObject =>        internal, Serializer

    TaskResource, TaskFilter < SerialObject

    This is the key user-input -> data step

    Serializing method should hold the following contract:
        - any empty value (meaning removal of the attribute) is deserialized into a empty string

        - None denotes a empty value for any attribute

    Deserializing method should hold the following contract:
        - None denotes an empty value for any attribute (however, this is here as a safeguard, TaskWarrior currently does not export empty-valued attributes) if the attribute is not iterable (e.g. list or set), in which case a empty iterable should be used.

    Normalizing methods should hold the following contract:
        - They are used to validate and normalize the user input. Any attribute value that comes from the user (during Task initialization, assignign values to Task attributes, or filtering by user-provided values of attributes) is first validated and normalized using the normalize_{key} method.

        - If validation or normalization fails, normalizer is expected
        to raise ValueError.

    Normalize/Serialize/Deserialize the following data inputs:
        - timestamps, should be localized, so to UTC before string: '%Y%m%dT%H%M%SZ'

        - datetimes/dates, should be localized, default time=midnight

        - annotations, should be an array of hashes

        - tags, 'blah, blah'.split(',')

        - depends, uuid

        - possibly an array of data structure shoehorned into string since UDA doesn't

    - Possible cool use case for meta-programming here.

TaskResource =>     internal, TaskResource

    inherits from Serializer

TaskFilter =>       internal, TaskFilter

    inherits from Serializer

TaskAnnotation =>   internal, TaskAnnotation

    inherits from TaskResource

Task =>             internal, Task

    inherits from TaskResource

TaskQuerySet =>     internal, TaskLazyLook | TaskLookup

    Lazy lookup for a task object

TaskWarrior =>      internal, TaskWarrior

    The main shebang


```
