# Xoggl

Simple Toggl command line client

## Installation
`gem install xoggl`

## Usage
Create a `~/.toggl` file containing your API token (found in your [Toggl profile](https://toggl.com/app/profile))

### Insert vacation days entries
`xoggl vacation 2016-01-01 2016-01-15`

### Insert work days entries
`xoggl work [project_name] 2016-01-01 2016-01-15`

## Development
Install dependencies
`bundle install`

Run tests
`rake spec`
