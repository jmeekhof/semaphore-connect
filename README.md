Semaphore Connect
###

This application is designed to manage a CPF pipelines for a Smartlogic Classification Server on a MarkLogic database.

Setup
###

1. Clone this repository, and give it a name related to whichever project you're working on.
```bash
git clone <repo-url> <project-slc>
```

2. Configure your projects
  a. First configure the parent project's database by setting up a triggers database for that database.
  b. Enable Content Processing Framework on the parent project's content database.
  c. Create the domains that you'll need for processing.
  d. Configure _this_ project's content database to be the _triggers_ database for the parent project's content database.

3. deploy
