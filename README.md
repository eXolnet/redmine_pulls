# Redmine Pulls

[![Build Status](https://img.shields.io/travis/eXolnet/redmine-pulls/master.svg?style=flat-square)](https://travis-ci.org/eXolnet/redmine-pulls)
[![Latest Release](https://img.shields.io/github/release/eXolnet/redmine-pulls.svg?style=flat-square)](https://github.com/eXolnet/redmine-pulls/releases)
[![Software License](https://img.shields.io/badge/license-MIT-8469ad.svg?style=flat-square)](LICENSE)

**Warning! This project is a work in progress.**

Allows users to create pull requests for repositories linked to projects.

## Compatibility

This plugin version is compatible only with Redmine 3.3 and later.

## Installation

1. Download the .ZIP archive, extract files and copy the plugin directory into `#{REDMINE_ROOT}/plugins`.

2. Install the plugin's dependencies:

    ```
    bundle install
    ```

3. Make a backup of your database, then run the following command to update it:

    ```
    bundle exec rake redmine:plugins:migrate RAILS_ENV=production NAME=redmine_pulls
    ```
    
4. Restart Redmine.

5. Login and enable the "Pulls" module on projects you want to use it.

### Uninstall

1. Make a backup of your database, then run the following command to update it:
   
       ```
       bundle exec rake redmine:plugins:migrate RAILS_ENV=production NAME=redmine_pulls VERSION=0
       ```
       
2. Remove the plugin's folder from `#{REDMINE_ROOT}/plugins`.

## Usage

Explain how to use your package.

## Testing

Run tests using the following command:

```bash
bundle exec rake redmine:plugins:test NAME=redmine_pulls RAILS_ENV=development
```

## Contributing

Please see [CONTRIBUTING](CONTRIBUTING.md) and [CODE OF CONDUCT](CODE_OF_CONDUCT.md) for details.

## Security

If you discover any security related issues, please email security@exolnet.com instead of using the issue tracker.

## Credits

- [Alexandre D'Eschambeault](https://github.com/xel1045)
- [All Contributors](../../contributors)

## License

This code is licensed under the [MIT license](http://choosealicense.com/licenses/mit/).
Please see the [license file](LICENSE) for more information.
