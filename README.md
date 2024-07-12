# Weather Forecast

After your've Git cloned this repo...

### Pre-requisites

#### Ruby version
See `.ruby-version` or `Gemfile` file

#### Weather API Key
- Get a OpenWeatherMap API key from https://openweathermap.org (e.g. create a user account)
- Generate a Rails master key and edit your Rails crendetials by running `./bin/rails credentials:edit`
- Store you OpenWeatherMap API key in the Rails credentials:
```
openweathermap:
    api_key: YOU_OPENWEATHERMAP_API_KEY_GOES_HERE
```

### How to run the test suite
There is no use of models in this app. Therefore, there are no unit tests.

However, there are integration tests.

In your shell, from the root of the application folder, run:
```
./bin/rails test
```

### How to run this app
In your shell, from the root of the application folder, to enable caching in development mode, first run:
```
 ./bin/rails dev:cache
 ```
 ...then, to run the dev server, run:
```
./bin/dev
```

### Other
Command used to generate app:

```
rails new . --database=sqlite3 --asset-pipeline=propshaft --javascript=esbuild --css=tailwind --skip-jbuilder --skip-spring
```