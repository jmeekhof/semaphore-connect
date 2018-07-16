# Semaphore Connect #

This application is designed to manage a CPF pipelines for a Smartlogic Classification Server on a MarkLogic database.

Creating and maintaining pipeline code can be troublesome. This application abstracts each pipeline with a config document that can be edited and deployed.

The name of the elements and their namespaces are all configurable with this application.

## Setup ##

1. Clone this repository, and give it a name related to whichever project you're working on.
```bash
git clone <repo-url> <project-slc>
```

2. Configure your project
- First configure the parent project's database by setting up a triggers database for that database. If you're using mlGradle this will look something like this:

`src/main/ml-config/databases/triggers-database.json`
```json
{
  "database-name": "%%TRIGGERS_DATABASE%%"
}
```
and like this:

`src/main/ml-config/databases/content-database.json`
```json
{
  "database-name" : "%%DATABASE%%",
  "triggers-database": "%%TRIGGERS_DATABASE%%"
}
```
- Enable Content Processing Framework on the parent project's content database. This is done by creating some more config files.

`src/main/ml-config/cpf/cpf-configs/cpf.json`
```json
{
  "domain-name": "%%NAME%%-Default",
  "eval-module": "%%SCS_MODULES_DATABASE%%",
  "eval-root": "/",
  "restart-user-name": "admin",
  "conversion-enabled": false
}
```
- Create the domains that you'll need for processing.

`src/main/ml-config/cpf/domains/default.json`
```json
{
  "domain-name": "%%NAME%%-Default",
  "description": "Default Domain",
  "scope": "directory",
  "uri": "/",
  "depth": "infinity",
  "eval-module": "%%SCS_MODULES_DATABASE%%",
  "eval-root": "/"
}
```
You'll also need to add something like:

`build.gradle`
```groovy
ext {
  mlAppConfig{
    customTokens.put("%%SCS_MODULES_DATABASE%%", mlSlcModulesDatabase)
  }
}
```
- Configure _this_ project's content database to be the _triggers_ database for the parent project's content database.

`gradle.properties`
```properties
mlContentDatabaseName=<triggers_database>
```



3. Deploy
- Deploy _this_ project first. The parent project depend on this projects modules database.
```bash
gradle mlDeploy
```

- Deploy parent project, with cpf.
```bash
gradle mlDeploy mlDeployCpf
```
