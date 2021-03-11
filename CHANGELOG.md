# Changelog

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 1.2.1

* Fix mail sending in Redmine 4

## 1.2.0 - 2020-08-14
### Added

* Allow head branches to be automatically deleted after a merge
* Add permissions to manage pull's watchers

### Fixed

* Reviewers and watchers are now assigned on pull creation on Redmine 3.4.x
* Compatibility with latest Redmine Checklist plugin


## 1.1.0 - 2019-10-17
### Added

* Fill description from templates on pull request creation
* Integration tests of the plugin
* Display related pull requests in the issue view
* Ability to configure the default branch
* Redmine 4 support
* Display Redmine compatibility in the README
* Display actionable pull request count in the menu bar
* Display some statistics in the user's profile
* Ability to select the repository when creating a pull request

### Changed

* Normalize diff columns alignment
* Only show the application menu when the user is authorized to access it

### Fixed

* Reviewer count in the sidebar
* Invalid merge when not on the master branch

## 1.0.0 - 2018-10-24
### 🎉 Added

* Create a pull request for commits in the project's main repository
* List and filters pull requests
* See commits and changes of a pull request
* Ability to leave comments to a pull request
* Actions on a pull requests are journalized
* Ability to close and reopen a pull request
* Ability to leave review to a pull request
* Ability to ask someone to review a pull request
* Ability to watch a pull request
* Display conflicted files in the merge box
* Merge a pull request directly from the interface
* Detect when a pull request is manually merged
* Deleting the head branch
* Restoring the head branch
