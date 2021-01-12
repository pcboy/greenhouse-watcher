# Greenhouse watcher

I found annoying that there is no way to subscribe to greenhouse.io company job boards and be alerted of changes.  
So I made my own script doing exactly that.  

## Configuration

See [watcher.yml](watcher.yml), it's pretty straightforward:

```
organizations:
  - github # List of organizations you want to listen to
mail:
  pony_via: :smtp # Pony gem configuration
  pony_via_options:
    address: 'smtp.mailgun.org'
    port: 587
    user_name: ''
    password: ''
    authentication: plain
  to: 'test@example.com' # to email field
  from: 'test@example.com' # from email field
filters:
  location: 'Anywhere|Japan|Remote' # Regexp for filtering the location
  title: 'Engineer|Manager' # Regexp for filtering the job title
```

Each time you run watcher.rb with `bundle exec ruby watcher.rb` the script will check for new jobs, and save the `last updated at` date inside a 'watcher.log` file (so you don't constantly receive the same jobs in your mailbox..).  
You now simply have to run this script regularly.

## Docker solution

There is a Dockerfile at the root of the repository, which includes a `runner.sh` script that will run the `watcher.rb` script for you every 12 hours.  
In order to use it you can simply do:  

```
$> docker build -t greenhouse_watcher .
$> docker run -d --rm -t greenhouse_watcher
```

Then the docker container in background will run the `watcher.rb` script every 12 hours for you.